//
//  MapViewController.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/27.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    private var searchVC: SearchViewController!
    @IBOutlet weak var mapView: MKMapView!

    //MARK: Layout propaties
    private let modalViewHeight: CGFloat = UIScreen.main.bounds.height - 64
    private var maxDistance: CGFloat {
        return modalViewHeight - 60 - topPositionConstant
    }
    private let topPositionConstant: CGFloat = 0.0
    private var middlePositionConstant: CGFloat {
        return maxDistance * 0.4
    }
    private var bottomPositionConstant: CGFloat {
        return maxDistance
    }
    private var middlePositionFractionValue: CGFloat {
        return bottomToMiddleDistance / maxDistance
    }
    private var bottomToMiddleDistance: CGFloat {
        return maxDistance - middlePositionConstant
    }
    private var middleToTopDistance: CGFloat {
        return maxDistance - bottomToMiddleDistance
    }

    //MARK: for animator
    private var modalAnimator = UIViewPropertyAnimator()
    private var modalAnimatorProgress: CGFloat = 0.0

    private var remainigToMiddleDistance: CGFloat = 0.0
    private var isRunningToMiddle = false
    private var currentMode: DrawerPositionType = .half

    private lazy var panGestureRecognizer: ViewPanGestureRecognizer = {
        let pan = ViewPanGestureRecognizer(target: self, action: #selector(handle(panGesture:)))
        return pan
    }()

    private var modalViewBottomConstraint = NSLayoutConstraint()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let searchViewController = UIStoryboard(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as? SearchViewController else {
            return
        }
        searchVC = searchViewController
        setupMap()

        self.addChild(searchVC)
        self.view.addSubview(searchVC.view)
        searchVC.didMove(toParent: self)

        setupModalLayout()

        searchVC.searchBar.delegate = self
        searchVC.tableView.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))
        searchVC.searchBar.addGestureRecognizer(panGestureRecognizer)
    }

    //
    private func setupModalLayout() {
        // autolayoutで設定する
        let modalView = searchVC.view!
        modalView.translatesAutoresizingMaskIntoConstraints = false

        modalViewBottomConstraint = modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomToMiddleDistance)

        modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        modalViewBottomConstraint.isActive = true
        modalView.heightAnchor.constraint(equalToConstant: modalViewHeight).isActive = true
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Add FloatingPanel to a view with animation.

    }

    private func setupMap() {
        let center = CLLocationCoordinate2D(latitude: 35.6585805,
                                            longitude: 139.7454329)
        let span = MKCoordinateSpan(latitudeDelta: 0.4425100023575723,
                                    longitudeDelta: 0.28543697435880233)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.showsCompass = true
        mapView.showsUserLocation = true
    }

//    func distanceFromTop(position: DrawerPositionType) -> CGFloat? {
//        switch position {
//        case .full: return 18.0
//        case .half: return 262.0
//        case .tip: return 69.0
//        }
//    }

    @objc private func handle(panGesture: UIPanGestureRecognizer) {

        if panGesture == searchVC.tableView.panGestureRecognizer {
            lockScrollView(scrollView: searchVC.tableView)
        }


        switch panGesture.state {
        case .began:
            beganInteractionAnimator()
            activeAnimator()
        case .changed:
            // パンジェスチャーが動いている
            // どのぐらい動いたのかをつくる
            let translation = panGesture.translation(in: searchVC.view)
            // 今の位置はどこのポジションか？
            switch currentMode {
            case .tip:
                // animatorのパーセンテージを計算。
                modalAnimator.fractionComplete = -translation.y / maxDistance + modalAnimatorProgress

            case .full:
                modalAnimator.fractionComplete = translation.y / maxDistance + modalAnimatorProgress
            case .half: fatalError()
            }
        case .ended:
            // velocityをつくる
            let velocity = panGesture.velocity(in: searchVC.view)

            continueInteractionAnimator(velocity: velocity)


        default:
            ()
        }
    }

    private func beganInteractionAnimator() {

        if !modalAnimator.isRunning {
            // animatorが実行中ではない
            if currentMode == .half {
                // middleならbottomに変更する
                currentMode = .tip
                // 制約を変えて
                modalViewBottomConstraint.constant = bottomPositionConstant
                view.layoutIfNeeded()
                modalAnimatorProgress = middlePositionFractionValue
            } else {
                modalAnimatorProgress = 0.0
            }
            // animatorを作る。プロパティを更新
            generateAnimator()
        } else if isRunningToMiddle {

            // animatorがisRunning中でrunning to middleがtrue ->どういう状態？
            //　topか、bottomだけどmiddleに向かっているってことか
            modalAnimator.pauseAnimation()
            isRunningToMiddle.toggle()
            let currentConstantPoint: CGFloat //制約の数値を計算
            switch currentMode {
            case .tip:
                currentConstantPoint = bottomToMiddleDistance - remainigToMiddleDistance * (1 - modalAnimator.fractionComplete)
                modalViewBottomConstraint.constant = bottomPositionConstant
            case .full:
                currentConstantPoint = (middleToTopDistance - remainigToMiddleDistance) + remainigToMiddleDistance * modalAnimator.fractionComplete
                modalViewBottomConstraint.constant = topPositionConstant
            case .half: fatalError()
            }
            // 進捗状態を作成
            // 今の制約すうw割る（modalViewHeight - 60）　高さマイナス60の値を
            modalAnimatorProgress = currentConstantPoint / maxDistance
            stopModalAnimator()

            // animatorを作り直す
            generateAnimator()
        } else {
            // animatorがランニング中で真ん中に行くわけでもない
            // animatorをポーズする
            modalAnimator.pauseAnimation()
            // アニメーターの進捗を計算
            modalAnimatorProgress = modalAnimator.isReversed ? 1 - modalAnimator.fractionComplete : modalAnimator.fractionComplete
            if modalAnimator.isReversed {
                // 反対のアニメーションになっていたら変える
                modalAnimator.isReversed.toggle()
            }
        }
    }



    private func generateAnimator(duration: TimeInterval = 1.0) {

        if modalAnimator.state == .active {
            stopModalAnimator()
        }

        modalAnimator = generateModalAnimator(duration: duration)

    }

    private func generateModalAnimator(duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {[weak self] in
            guard let self = self else { return }
            switch self.currentMode {
            case .tip:
                self.modalViewBottomConstraint.constant = self.topPositionConstant
            case .full:
                self.modalViewBottomConstraint.constant = self.bottomPositionConstant
            case .half: fatalError()
            }
            self.view.layoutIfNeeded()
        }
        animator.addCompletion {[weak self] position in
            guard let self = self else { return }
            switch self.currentMode {
            case .tip:
                if position == .start {
                    self.modalViewBottomConstraint.constant = self.bottomPositionConstant
                    self.currentMode = .tip
                } else if position == .end {
                    self.modalViewBottomConstraint.constant = self.topPositionConstant
                    self.currentMode = .full
                }
            case .full:
                if position == .start {
                    self.modalViewBottomConstraint.constant = self.topPositionConstant
                    self.currentMode = .full
                } else if position == .end {
                    self.modalViewBottomConstraint.constant = self.bottomPositionConstant
                    self.currentMode = .tip
                }
            case .half: fatalError()
            }
            self.view.layoutIfNeeded()
        }
        return animator
    }

    /// モーダルのアニメーターとオーバーレイのアニメーターをスタートさせてポーズする
    private func activeAnimator() {
        modalAnimator.startAnimation()
        modalAnimator.pauseAnimation()
    }

    private func stopModalAnimator() {
        modalAnimator.stopAnimation(false)
        modalAnimator.finishAnimation(at: .current)
    }

    /// パンジェスチャーの終わりに呼ばれる
    private func continueInteractionAnimator(velocity: CGPoint) {
        // bottomとhullの場合に、同じ位置にいたかどうか
        let fractionComplete = modalAnimator.fractionComplete
        if currentMode.isBeginningArea(fractionPoint: fractionComplete, velocity: velocity, middleAreaBorderPoint: middlePositionFractionValue) {
            //beginning areaならはじめのインタラクションアニメーターを実行
            begginingAreaContinueInteractionAnimator(velocity: velocity)
        } else if currentMode.isEndArea(fractionPoint: fractionComplete, velocity: velocity, middleAreaBorderPoint: middlePositionFractionValue) {
            // bottomとhullの場合に、ミドルを飛び越して他の場所に行ったかどうか
            endAreaContinueInteractionAnimator(velocity: velocity)
        } else {
            middleAreaContinueInteractionAnimator(velocity: velocity)
        }
    }

    private func calculateContinueAnimatorParams(remainingDistance: CGFloat, velocity: CGPoint) -> (timingParameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        if remainingDistance == 0 {
            return (nil, 0)
        }
        let relativeVelocity = abs(velocity.y) / remainingDistance
        let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: relativeVelocity, dy: relativeVelocity))
        let newDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        let durationFactor = CGFloat(newDuration/modalAnimator.duration)
        return (timingParameters, durationFactor)
    }

    private func begginingAreaContinueInteractionAnimator(velocity: CGPoint) {
        let remainingFraction = 1 - modalAnimator.fractionComplete
        let remainingDistance = maxDistance * remainingFraction
        modalAnimator.isReversed = true
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainingDistance, velocity: velocity)
        continueAnimator(parameters: continueAnimatorParams.timingParameters, durationFactor: continueAnimatorParams.durationFactor)
    }

    private func endAreaContinueInteractionAnimator(velocity: CGPoint) {
        let remainingFraction = 1 - modalAnimator.fractionComplete
        let remainingDistance = maxDistance * remainingFraction
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainingDistance, velocity: velocity)
        continueAnimator(parameters: continueAnimatorParams.timingParameters, durationFactor: continueAnimatorParams.durationFactor)
    }

    private func middleAreaContinueInteractionAnimator(velocity: CGPoint) {
        modalAnimator.pauseAnimation()
        let toMiddleDistance = currentMode == .tip ? bottomToMiddleDistance : middleToTopDistance
        remainigToMiddleDistance = toMiddleDistance - (maxDistance * modalAnimator.fractionComplete)

        stopModalAnimator()
        modalAnimator.addAnimations {
            self.modalViewBottomConstraint.constant = self.middlePositionConstant
            self.view.layoutIfNeeded()
        }
        modalAnimator.addCompletion {[weak self] position in
            guard let self = self else { return }
            self.isRunningToMiddle = false
            switch position {
            case .end:
                self.currentMode = .half
                self.modalViewBottomConstraint.constant = self.middlePositionConstant
            case .start, .current: ()
            @unknown default:
                ()
            }
            self.view.layoutIfNeeded()
        }
        isRunningToMiddle = true

        activeAnimator()
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainigToMiddleDistance, velocity: velocity)
        continueAnimator(parameters: continueAnimatorParams.timingParameters, durationFactor: continueAnimatorParams.durationFactor)
    }

    private func continueAnimator(parameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        modalAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor)
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        searchVC.hideHeader()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchVC.showHeader()
        searchVC.tableView.alpha = 1.0
    }
}

extension MapViewController {
    private func lockScrollView(scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
    }

    private func unlockScrollView(scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
    }
}
