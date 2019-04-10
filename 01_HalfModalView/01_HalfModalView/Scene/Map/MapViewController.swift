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
    private var modalViewHeight: CGFloat {
        return view.frame.height - view.safeAreaInsets.top
    }
    private var maxDistance: CGFloat {
        return modalViewHeight - fullPositionConstant
    }
    private var fullPositionConstant: CGFloat {
        return view.safeAreaInsets.top
    }
    private var halfPositionConstant: CGFloat {
        return maxDistance * 0.7
    }
    private var tipPositionConstant: CGFloat {
        return maxDistance
    }
    private var halfPositionFractionValue: CGFloat {
        return tipToHalfDistance / maxDistance
    }
    private var tipToHalfDistance: CGFloat {
        return maxDistance - halfPositionConstant
    }
    private var halfToFullDistance: CGFloat {
        return maxDistance - tipToHalfDistance
    }

    //MARK: for animator
    private var modalAnimator = UIViewPropertyAnimator()
    private var modalAnimatorProgress: CGFloat = 0.0 {
        didSet {
            print("modal progress \(modalAnimatorProgress)")
        }
    }

    private var remainigToHalfDistance: CGFloat = 0.0
    private var isRunningToHalf = false
    private var currentMode: DrawerPositionType = .half {
        didSet {
            if currentMode == .full {
                searchVC.showHeader()
            } else {
                searchVC.hideHeader()
            }
        }
    }

    private lazy var panGestureRecognizer: ViewPanGestureRecognizer = {
        let pan =
            ViewPanGestureRecognizer(target: self,
                                     action: #selector(handle(panGesture:)))
        return pan
    }()

    private var modalViewBottomConstraint = NSLayoutConstraint()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let searchViewController =
            UIStoryboard(name: "SearchViewController", bundle: nil)
                .instantiateInitialViewController() as? SearchViewController
            else { return }
        searchVC = searchViewController
        setupMap()

        self.addChild(searchVC)
        self.view.addSubview(searchVC.view)
        searchVC.didMove(toParent: self)

        setupModalLayout()

        searchVC.searchBar.delegate = self
        searchVC.view.addGestureRecognizer(panGestureRecognizer)
    }

    //
    private func setupModalLayout() {

        // autolayoutで設定する
        let modalView = searchVC.view!
        modalView.translatesAutoresizingMaskIntoConstraints = false

        modalViewBottomConstraint =
            modalView
                .bottomAnchor
                .constraint(equalTo: view.bottomAnchor,
                            constant: halfPositionConstant)

        modalView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor).isActive = true
        modalView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor).isActive = true
        modalViewBottomConstraint.isActive = true
        modalView.heightAnchor
            .constraint(equalToConstant: modalViewHeight).isActive = true

        view.layoutIfNeeded()
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

    @objc private func handle(panGesture: UIPanGestureRecognizer) {

        switch panGesture.state {
        case .began:
            beganInteractionAnimator()
            activeAnimator()
        case .changed:
            // パンジェスチャーがどのぐらい動いたのか
            let translation = panGesture.translation(in: searchVC.view)
            // 現状のハーフモーダルビューの状態を確認
            // animatorの進捗をジェスチャーによって変更
            switch currentMode {
            case .tip:
                modalAnimator.fractionComplete =
                    -translation.y / maxDistance + modalAnimatorProgress
            case .full:
                modalAnimator.fractionComplete =
                    translation.y / maxDistance + modalAnimatorProgress
            case .half: fatalError()
            }
        case .ended:
            // ジェスチャーの速度から終了アニメーションを実行
            let velocity = panGesture.velocity(in: searchVC.view)
            continueInteractionAnimator(velocity: velocity)
        default:
            ()
        }
    }

    private func beganInteractionAnimator() {

        if !modalAnimator.isRunning {
            // animatorが実行中ではない(ポーズ状態）
            if currentMode == .half {
                // halfならtipに変更する
                currentMode = .tip
                // 制約をリセット
                modalViewBottomConstraint.constant = tipPositionConstant
                view.layoutIfNeeded()
                // 進捗状態もリセット
                modalAnimatorProgress = halfPositionFractionValue
            } else {
                modalAnimatorProgress = 0.0
            }
            // animatorを作る。プロパティを更新
            generateAnimator()
        } else if isRunningToHalf {
            // animatorがisRunning中でrunning to halfがtrue ->どういう状態？
            //　fullか、tipだけどhalfに向かっているってことか
            modalAnimator.pauseAnimation()
            isRunningToHalf.toggle()
            let currentConstantPoint: CGFloat //制約の数値を計算
            switch currentMode {
            case .tip:
                currentConstantPoint = tipToHalfDistance - remainigToHalfDistance * (1 - modalAnimator.fractionComplete)
                modalViewBottomConstraint.constant = tipPositionConstant
            case .full:
                currentConstantPoint = (halfToFullDistance - remainigToHalfDistance) + remainigToHalfDistance * modalAnimator.fractionComplete
                modalViewBottomConstraint.constant = fullPositionConstant
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
            // アニメーションが始まったら最初に呼ばれるクロージャー
            guard let self = self else { return }
            switch self.currentMode {
            case .tip:
                // tipの場合最終的にいくであろうfullの制約を入れる
                self.modalViewBottomConstraint.constant = self.fullPositionConstant
            case .full:
                // fullの場合も最終的に起こりうるtipのポジションの制約を入れる
                self.modalViewBottomConstraint.constant = self.tipPositionConstant
            case .half: fatalError()
            }
            //制約を変更したので必要
            self.view.layoutIfNeeded()
        }
        animator.addCompletion {[weak self] position in
            guard let self = self else { return }
            // アニメーションが終わったときに呼ばれる
            switch self.currentMode {
            case .tip:
                if position == .start {
                    //tipの状態で開始し、tipのままにとどまった
                    self.modalViewBottomConstraint
                        .constant = self.tipPositionConstant
                    self.currentMode = .tip
                } else if position == .end {
                    //tipの状態で開始し、fullになった
                    self.modalViewBottomConstraint
                        .constant = self.fullPositionConstant
                    self.currentMode = .full
                }
            case .full:
                if position == .start {
                    //fullの状態で開始し、fullのままとどまった
                    self.modalViewBottomConstraint
                        .constant = self.fullPositionConstant
                    self.currentMode = .full
                } else if position == .end {
                    //fullの状態で開始し、tipになった
                    self.modalViewBottomConstraint
                        .constant = self.tipPositionConstant
                    self.currentMode = .tip
                }
            case .half: fatalError()
            }
            //制約を変更したので必要
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
        // tipとhullの場合に、同じ位置にいたかどうか
        let fractionComplete = modalAnimator.fractionComplete
        if currentMode.isBeginningArea(fractionPoint: fractionComplete, velocity: velocity, halfAreaBorderPoint: halfPositionFractionValue) {
            //beginning areaならはじめのインタラクションアニメーターを実行
            begginingAreaContinueInteractionAnimator(velocity: velocity)
        } else if currentMode.isEndArea(fractionPoint: fractionComplete, velocity: velocity, halfAreaBorderPoint: halfPositionFractionValue) {
            // tipとhullの場合に、ミドルを飛び越して他の場所に行ったかどうか
            endAreaContinueInteractionAnimator(velocity: velocity)
        } else {
            halfAreaContinueInteractionAnimator(velocity: velocity)
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
        modalAnimator.continueAnimation(withTimingParameters: continueAnimatorParams.timingParameters,
                                        durationFactor: continueAnimatorParams.durationFactor)
    }

    private func halfAreaContinueInteractionAnimator(velocity: CGPoint) {
        modalAnimator.pauseAnimation()
        let toHalfDistance = currentMode == .tip ? tipToHalfDistance : halfToFullDistance
        remainigToHalfDistance = toHalfDistance - (maxDistance * modalAnimator.fractionComplete)

        stopModalAnimator()
        modalAnimator.addAnimations {
            self.modalViewBottomConstraint.constant = self.halfPositionConstant
            self.view.layoutIfNeeded()
        }
        modalAnimator.addCompletion {[weak self] position in
            guard let self = self else { return }
            self.isRunningToHalf = false
            switch position {
            case .end:
                self.currentMode = .half
                self.modalViewBottomConstraint.constant = self.halfPositionConstant
            case .start, .current: ()
            @unknown default:
                ()
            }
            self.view.layoutIfNeeded()
        }
        isRunningToHalf = true

        activeAnimator()
        let continueAnimatorParams = calculateContinueAnimatorParams(remainingDistance: remainigToHalfDistance, velocity: velocity)
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
