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
    var layoutAdapter: DrawerLayoutAdapter
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
        let remains = layoutAdapter.supportedPositions.filter { $0.rawValue > state.rawValue }
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

    init(_ drawerContainerVC: DrawerContainerViewController, layout: DrawerLayout, behavior: DrawerBehavior) {
        self.drawerContainerVC = drawerContainerVC
        self.surfaceView = DrawerSurfaceView()
        self.surfaceView.backgroundColor = .white

        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = .black
        self.backgroundView.alpha = 0.0

        self.layoutAdapter = DrawerLayoutAdapter(surfaceView: surfaceView,
                                                 backgroundView: backgroundView,
                                                 layout: layout)
        self.behavior = behavior
        self.panGestureRecognizer = DrawerPanGestureRecognizer()
        panGestureRecognizer.name = "DrawerSurface"

        super.init()
        self.panGestureRecognizer.drawerView = self
        self.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))
        self.panGestureRecognizer.delegate = self

    }

    // MARK: - Gesture handling
    @objc func handle(panGesture: UIPanGestureRecognizer) {
        // TODO: 実装する
    }
}

extension DrawerView: UIGestureRecognizerDelegate {

}

extension DrawerView: UIScrollViewDelegate {

}


final class DrawerPanGestureRecognizer: UIPanGestureRecognizer {
    fileprivate weak var drawerView: DrawerView?
}
