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

//    private func directionalPosition(at currentY: CGFloat, with translation: CGPoint) -> DrawerPositionType {
//        return getPosition(at: currentY, with: translation, directional: true)
//    }

//    private func redirectionalPosition(at currentY: CGFloat, with translation: CGPoint) -> DrawerPositionType {
//        return getPosition(at: currentY, with: translation, directional: false)
//    }

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



}

extension DrawerView: UIGestureRecognizerDelegate {

}

extension DrawerView: UIScrollViewDelegate {

}


final class DrawerPanGestureRecognizer: UIPanGestureRecognizer {
    fileprivate weak var drawerView: DrawerView?
}
