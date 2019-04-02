//
//  DrawerUserInterface.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

// view関連の操作に責務をになう.viewのinputと表示
final class DrawerView: NSObject {
    weak var drawerContainerVC: DrawerContainerViewController!
    let surfaceView: DrawerSurfaceView
    let backgroundView: UIView
    var layout: DrawerLayout
    var behavior: DrawerBehavior

    weak var scrollView: UIScrollView? {
        didSet {
            guard let scrollView = scrollView else { return }
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))
            scrollBouncable = scrollView.bounces
            scrollIndictorVisible = scrollView.showsVerticalScrollIndicator
        }
    }
    weak var userScrollViewDelegate: UIScrollViewDelegate?

    private(set) var state: DrawerPositionType = .hidden

    private var isBottomState: Bool {
        let remains = layout.supportedPositions.filter { $0.rawValue > state.rawValue }
        return remains.count == 0
    }

    let panGestureRecognizer: DrawerPanGestureRecognizer
    var isRemovalInteractionEnabled: Bool = false

    fileprivate var animator: UIViewPropertyAnimator?
    private var initialFrame: CGRect = .zero
    private var initialTranslationY: CGFloat = 0
    private var initialLocation: CGPoint = CGPoint(x: CGFloat.nan,
                                                   y: CGFloat.nan)
    private var grabberAreaFrame: CGRect {
        let grabberAreaFrame = CGRect(x: surfaceView.bounds.origin.x,
                                      y: surfaceView.bounds.origin.y,
                                      width: surfaceView.bounds.width,
                                      height: DrawerSurfaceView.topGrabberBarHeight * 2)
        return grabberAreaFrame
    }

    var interactionInProgress: Bool = false
    var isDecelerating: Bool = false

    // Scroll handling
    private var initialScrollOffset: CGPoint = .zero
    private var initialScrollFrame: CGRect = .zero
    private var stopScrollDeceleration: Bool = false
    private var scrollBouncable = false
    private var scrollIndictorVisible = false

    //let panGestureRecognizer: Drawer

    init(_ drawerContainerVC: DrawerContainerViewController, behavior: DrawerBehavior) {
        self.drawerContainerVC = drawerContainerVC
        self.surfaceView = DrawerSurfaceView()
        self.surfaceView.backgroundColor = .white

        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = .black
        self.backgroundView.alpha = 0.0

        self.layout = DrawerLayout(surfaceView: surfaceView,
                                                 backgroundView: backgroundView)
        self.behavior = behavior
        self.panGestureRecognizer = DrawerPanGestureRecognizer()
        panGestureRecognizer.name = "DrawerSurface"

        super.init()
        self.panGestureRecognizer.drawerView = self
        self.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))
        self.panGestureRecognizer.delegate = self

    }

    // MARK: - Layout update

    private func updateLayout(to target: DrawerPositionType) {
        layout.activateLayout(of: target)
    }

    // MARK: - Gesture handling
    @objc func handle(panGesture: UIPanGestureRecognizer) {
        // TODO: 実装する
        let velocity = panGesture.velocity(in: panGesture.view)

        switch panGesture {
        case scrollView?.panGestureRecognizer:
            guard let scrollView = scrollView else { return }
            handleScrollPanGesture(velocity: velocity, panGesture: panGesture, scrollView: scrollView)
        case panGestureRecognizer:
            handleDrawerPanGesture(velocity: velocity, panGesture: panGesture)
        default:
            break
        }
    }

    /// fullサイズのときにTable Viewをスクロールできるように実装
    private func handleScrollPanGesture(velocity: CGPoint, panGesture: UIPanGestureRecognizer, scrollView: UIScrollView) {
        let location = panGesture.location(in: surfaceView)
        // 実際の表面画面の一番上のほうが、レイアウトの一番上よりも大きい（下にある。）
        let isBelowTop = surfaceView.frame.minY > layout.topY

        if isBelowTop {
            // scrollをさせる
            switch (state, interactionInProgress) {
            case (.full, true):
                scrollView.setContentOffset(initialScrollOffset, animated: false)

            case (.full, false):
                if grabberAreaFrame.contains(location) {
                    // ドロワーのタブ画面をスワイプしていたらfull のときにscroll viewのcontent offsetを動かさない
                    scrollView.contentOffset.y = initialScrollOffset.y
                } else {
                    if scrollView.contentOffset.y < 0 {
                        // 下に限界まで引っ張った場合
                        fitToBounds(scrollView: scrollView)
                        let translation = panGesture.translation(in: panGestureRecognizer.view!.superview)
                        // fullから他のタイプに変え始める
                        startInteraction(with: translation, at: location)
                    }
                }
            case (.half, _):
                guard scrollView.isDecelerating == false else {
                    // scroll viewにてユーザーが指を離したあとにコンテンツがうごいていない場合。
                    // halfとtipから動く際にスクロールオフセットを修正しないでください。
                    //　それはスクロールしなくなる可能性があります。なぜならstateがhullからのユーザー動作で移動先のタイプ（half, tip)になるからです
                    return
                }
                // Fix the scroll offset in moving the panel from half and tip.
                scrollView.contentOffset.y = initialScrollOffset.y
            case (.tip, _):
                guard scrollView.isDecelerating == false else {
                    return
                }
                scrollView.contentOffset.y = initialScrollOffset.y
            case (.hidden, _):
                break

            }
            if interactionInProgress {
                lockScrollView()
            }
        } else {
            // スクロールのインジケーターはトップになっている
            if interactionInProgress {
                unlockScrollView()
            } else {
                // stateがhullでcontent offsetがマイナス（下に限界まで引っ張った）であり、ユーザーがまだ移動している。
                if state == .full, scrollView.contentOffset.y < 0, velocity.y > 0 {
                    fitToBounds(scrollView: scrollView)
                    let translation = panGesture.translation(in: panGestureRecognizer.view!.superview)
                    startInteraction(with: translation, at: location)
                }
            }
        }

    }

    private func handleDrawerPanGesture(velocity: CGPoint, panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: panGestureRecognizer.view!.superview)
        let location = panGesture.location(in: panGesture.view)



        if let animator = self.animator {
            if animator.isInterruptible {
                animator.stopAnimation(false)
                animator.finishAnimation(at: .current)
            }

            self.animator = nil

            // A user can stop a panel at the nearest Y of a target position
            if abs(surfaceView.frame.minY - layout.topY) < 1 {
                surfaceView.frame.origin.y = layout.topY
            }
        }


        if interactionInProgress == false {
            return
        }

        if panGesture.state == .began {
            panningBegan(at: location)
            return
        }

        if shouldScrollViewHandleTouch(scrollView, point: location, velocity: velocity) {
            return
        }

        switch panGesture.state {
        case .changed:
            if interactionInProgress == false {
                startInteraction(with: translation, at: location)
            }
            panningChange(with: translation)
        case .ended, .cancelled, .failed:
            panningEnd(with: translation, velocity: velocity)
        default:
            break
        }

    }

    private func shouldScrollViewHandleTouch(_ scrollView: UIScrollView?, point: CGPoint, velocity: CGPoint) -> Bool {
        // When no scrollView, nothing to handle.
        guard let scrollView = scrollView else { return false }

        // For _UISwipeActionPanGestureRecognizer
        if let scrollGestureRecognizers = scrollView.gestureRecognizers {
            for gesture in scrollGestureRecognizers {
                guard gesture.state == .began || gesture.state == .changed
                    else { continue }

                if gesture !=  scrollView.panGestureRecognizer {
                    return true
                }
            }
        }

        guard
            state == .full,                   // When not .full, don't scroll.
            interactionInProgress == false,   // When interaction already in progress, don't scroll.
            surfaceView.frame.minY == layout.topY
            else {
                return false
        }

        // When the current and initial point within grabber area, do scroll.
        if grabberAreaFrame.contains(point), !grabberAreaFrame.contains(initialLocation) {
            return true
        }

        guard
            scrollView.frame.contains(initialLocation), // When initialLocation not in scrollView, don't scroll.
            !grabberAreaFrame.contains(point)           // When point within grabber area, don't scroll.
            else {
                return false
        }

        let offset = scrollView.contentOffset.y - CGPoint(x: 0.0, y: 0.0 - scrollView.contentInset.top).y
        // 10 pt is introduced from my testing(there might be better one)
        // It should be low as possible because a user scroll view frame will
        // change as far as the specified value temporarily.
        // The zero offset is an exception because the offset is usually zero
        // when a panel moves from half or tip position to full.
        if  offset > -10.0, offset != 0.0 {
            return true
        }
        if scrollView.isDecelerating {
            return true
        }
        if velocity.y <= 0 {
            return true
        }

        return false
    }

    private func panningBegan(at location: CGPoint) {
        // A user interaction does not always start from Began state of the pan gesture
        // because it can be recognized in scrolling a content in a content view controller.
        // So here just preserve the current state if needed.
        initialLocation = location
        switch state {
        case .full:
            if let scrollView = scrollView {
                initialScrollFrame = scrollView.frame
            }
        default:
            if let scrollView = scrollView {
                initialScrollOffset = scrollView.contentOffset
            }
        }
    }

    private func panningChange(with translation: CGPoint) {
        let pre = surfaceView.frame.minY
        let dy = translation.y - initialTranslationY

        layout.updateInteractiveTopConstraint(diff: dy,
                                                     allowsTopBuffer: allowsTopBuffer(for: dy))

        //preserveContentVCLayoutIfNeeded()

        let didMove = (pre != surfaceView.frame.minY)
        guard didMove else { return }

        drawerContainerVC.delegate?.DrawerDidMove(drawerContainerVC)
    }

    private func panningEnd(with translation: CGPoint, velocity: CGPoint) {

        if state == .hidden {
            return
        }

        stopScrollDeceleration = (surfaceView.frame.minY > layout.topY) // Projecting the dragging to the scroll dragging or not

        let targetPosition = self.targetPosition(with: velocity)
        let distance = self.distance(to: targetPosition)

        endInteraction(for: targetPosition)



        drawerContainerVC.delegate?.DrawerDidEndDragging(drawerContainerVC, withVelocity: velocity, targetPosition: targetPosition)

        startAnimation(to: targetPosition, at: distance, with: velocity)
    }

    // みつけた。ここだ
    private func startAnimation(to targetPosition: DrawerPositionType, at distance: CGFloat, with velocity: CGPoint) {

        isDecelerating = true
        drawerContainerVC.delegate?.drawerWillBeginDragging(drawerContainerVC)

        let velocityVector = (distance != 0) ? CGVector(dx: 0, dy: min(abs(velocity.y)/distance, 30.0)) : .zero
        let animator =  behavior.interactionAnimator(to: targetPosition, with: velocityVector)
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            self.state = targetPosition

            self.updateLayout(to: targetPosition)
        }
        animator.addCompletion { [weak self] pos in
            guard let self = self else { return }
            self.finishAnimation(at: targetPosition)
        }
        self.animator = animator
        animator.startAnimation()
    }

    private func finishAnimation(at targetPosition: DrawerPositionType) {
        self.isDecelerating = false
        self.animator = nil

        stopScrollDeceleration = false
        // Don't unlock scroll view in animating view when presentation layer != model layer
        if targetPosition == .full {
            unlockScrollView()
        }
    }

    private func distance(to targetPosition: DrawerPositionType) -> CGFloat {
        let topY = layout.topY
        let middleY = layout.middleY
        let bottomY = layout.bottomY
        let currentY = surfaceView.frame.minY

        switch targetPosition {
        case .full:
            return CGFloat(abs(currentY - topY))
        case .half:
            return CGFloat(abs(currentY - middleY))
        case .tip:
            return CGFloat(abs(currentY - bottomY))
        case .hidden:
            fatalError("Now .hidden must not be used for a user interaction")
        }
    }

    private func allowsTopBuffer(for translationY: CGFloat) -> Bool {
        let preY = surfaceView.frame.minY
        let nextY = initialFrame.offsetBy(dx: 0.0, dy: translationY).minY
        if let scrollView = scrollView, scrollView.panGestureRecognizer.state == .changed,
            preY > 0 && preY > nextY {
            return false
        } else {
            return true
        }
    }

    private func endInteraction(for targetPosition: DrawerPositionType) {


        interactionInProgress = false

        // Prevent to keep a scroll view indicator visible at the half/tip position
        if targetPosition != .full {
            lockScrollView()
        }
    }






    func move(to: DrawerPositionType, animated: Bool, completion: (() -> Void)? = nil) {
        move(from: state, to: to, animated: animated, completion: completion)
    }

    private func move(from: DrawerPositionType, to: DrawerPositionType, animated: Bool, completion: (() -> Void)? = nil) {
        if to != .full {
            lockScrollView()// full以外はスクロールをさせない
        }
        tearDownActiveInteraction()

        if animated {
            let animator: UIViewPropertyAnimator = behavior.makeAnimator()

            animator.addAnimations { [weak self] in
                guard let self = self else { return }

                self.state = to
                self.updateLayout(to: to)
            }
            animator.addCompletion { [weak self] _ in
                guard let self = self else { return }
                self.animator = nil
                completion?()
            }
            self.animator = animator
            animator.startAnimation()
        } else {
            self.state = to
            self.updateLayout(to: to)
            completion?()
        }
    }

    private func tearDownActiveInteraction() {
        // Cancel the pan gesture so that panningEnd(with:velocity:) is called
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
    }


    // MARK: - ScrollView handling

    private func lockScrollView() {
        guard let scrollView = scrollView else { return }

        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
    }

    private func unlockScrollView() {
        guard let scrollView = scrollView else { return }

        scrollView.isDirectionalLockEnabled = false
        scrollView.bounces = scrollBouncable
        scrollView.showsVerticalScrollIndicator = scrollIndictorVisible
    }

    private func fitToBounds(scrollView: UIScrollView) {

        surfaceView.frame.origin.y = layout.topY - scrollView.contentOffset.y
        scrollView.transform = CGAffineTransform.identity.translatedBy(x: 0.0,
                                                                       y: scrollView.contentOffset.y)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: -scrollView.contentOffset.y,
                                                        left: 0.0,
                                                        bottom: 0.0,
                                                        right: 0.0)
    }

    private func settle(scrollView: UIScrollView) {

        surfaceView.transform = .identity
        scrollView.transform = .identity
        scrollView.frame = initialScrollFrame
        scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0 - scrollView.contentInset.top)
        scrollView.scrollIndicatorInsets = .zero
    }

    private func getPosition(at currentY: CGFloat, with translation: CGPoint, directional: Bool) -> DrawerPositionType {
        let supportedPositions: Set = layout.supportedPositions
        if supportedPositions.count == 1 {
            return state
        }
        let isForwardYAxis = (translation.y >= 0)
        switch supportedPositions {
        case [.full, .half]:
            return (isForwardYAxis == directional) ? .half : .full
        case [.half, .tip]:
            return (isForwardYAxis == directional) ? .tip : .half
        case [.full, .tip]:
            return (isForwardYAxis == directional) ? .tip : .full
        default:
            let middleY = layout.middleY
            if currentY > middleY {
                return (isForwardYAxis == directional) ? .tip : .half
            } else {
                return (isForwardYAxis == directional) ? .half : .full
            }
        }
    }

    private func startInteraction(with translation: CGPoint, at location: CGPoint) {
        /* Don't lock a scroll view to show a scroll indicator after hitting the top */
        guard interactionInProgress == false else { return }

        initialFrame = surfaceView.frame
        if state == .full, let scrollView = scrollView {
            if grabberAreaFrame.contains(location) {
                initialScrollOffset = scrollView.contentOffset
            } else {
                settle(scrollView: scrollView)
                initialScrollOffset = CGPoint(x: 0.0,
                                              y: 0.0 - scrollView.contentInset.top)// scrollView.contentOffsetZero
            }
        }

        initialTranslationY = translation.y
        drawerContainerVC.delegate?.drawerWillBeginDragging(drawerContainerVC)
        layout.startInteraction(at: state)
        interactionInProgress = true
    }

    private func targetPosition(with velocity: CGPoint) -> DrawerPositionType {
        let currentY = surfaceView.frame.minY

        let topY = layout.topY
        let middleY = layout.middleY
        let bottomY = layout.bottomY

        let nextState: DrawerPositionType
        let forwardYDirection: Bool

        /*
         full <-> half <-> tip
         */
        switch state {
        case .full:
            nextState = .half
            forwardYDirection = true
        case .half:
            nextState = (currentY > middleY) ? .tip : .full
            forwardYDirection = (currentY > middleY)
        case .tip:
            nextState = .half
            forwardYDirection = false
        case .hidden:
            fatalError("Now .hidden must not be used for a user interaction")
        }

        let redirectionalProgress = max(min(behavior.redirectionalProgress(), 1.0), 0.0)

        let th1: CGFloat
        let th2: CGFloat

        if forwardYDirection {
            th1 = topY + (middleY - topY) * redirectionalProgress
            th2 = middleY + (bottomY - middleY) * redirectionalProgress
        } else {
            th1 = middleY - (middleY - topY) * redirectionalProgress
            th2 = bottomY - (bottomY - middleY) * redirectionalProgress
        }

        let decelerationRate = behavior.momentumProjectionRate()

        let baseY = abs(bottomY - topY)
        let vecY = velocity.y / baseY
        let pY = project(initialVelocity: vecY, decelerationRate: decelerationRate) * baseY + currentY

        switch currentY {
        case ..<th1:
            switch pY {
            case bottomY...:
                return behavior.shouldProjectMomentum(drawerContainerVC, for: .tip) ? .tip : .half
            case middleY...:
                return .half
            case topY...:
                return .full
            default:
                return .full
            }
        case ...middleY:
            switch pY {
            case bottomY...:
                return behavior.shouldProjectMomentum(drawerContainerVC, for: .tip) ? .tip : .half
            case middleY...:
                return .half
            case topY...:
                return .half
            default:
                return .full
            }
        case ..<th2:
            switch pY {
            case bottomY...:
                return .tip
            case middleY...:
                return .half
            case topY...:
                return .half
            default:
                return behavior.shouldProjectMomentum(drawerContainerVC, for: .full) ? .full : .half
            }
        default:
            switch pY {
            case bottomY...:
                return .tip
            case middleY...:
                return .tip
            case topY...:
                return .half
            default:
                return behavior.shouldProjectMomentum(drawerContainerVC, for: .full) ? .full : .half
            }
        }
    }

    // Distance travelled after decelerating to zero velocity at a constant rate.
    // Refer to the slides p176 of [Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/)
    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGFloat {
        return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
    }
}

extension DrawerView: UIGestureRecognizerDelegate {

}

extension DrawerView: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if stopScrollDeceleration {
            targetContentOffset.pointee = scrollView.contentOffset
            stopScrollDeceleration = false
        } else {
            let targetOffset = targetContentOffset.pointee
            userScrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
            // Stop scrolling on tip and half
            if state != .full, targetOffset == targetContentOffset.pointee {
                targetContentOffset.pointee.y = scrollView.contentOffset.y
            }
        }
    }
}


final class DrawerPanGestureRecognizer: UIPanGestureRecognizer {
    fileprivate weak var drawerView: DrawerView?
}
