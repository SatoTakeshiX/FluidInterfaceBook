//
//  DrawerLayout.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

public enum DrawerPositionType: Int {
    case full //最大限表示
    case half //半分
    case tip //検索フィールドのみ出ている
    case hidden //非表示
}

//// FloatingPanelLayoutをプロトコルで定義
//protocol DrawerLayout {
////    /// Returns the initial position of a floating panel.
////    var initialPosition: DrawerPositionType { get }
//
//    /// Returns a set of FloatingPanelPosition objects to tell the applicable
//    /// positions of the floating panel controller.
//    ///
//    /// By default, it returns all position except for `hidden` position. Because
//    /// it's always supported by `FloatingPanelController` so you don't need to return it.
////    var supportedPositions: Set<DrawerPositionType> { get }
//
//    /// Return the interaction buffer to the top from the top position. Default is 6.0.
////    var topInteractionBuffer: CGFloat { get }
//
//    /// Return the interaction buffer to the bottom from the bottom position. Default is 6.0.
////    var bottomInteractionBuffer: CGFloat { get }
//
//    /// Returns a CGFloat value to determine a Y coordinate of a floating panel for each position(full, half, tip and hidden).
//    ///
//    /// Its returning value indicates a different inset for each position.
//    /// For full position, a top inset from a safe area in `FloatingPanelController.view`.
//    /// For half or tip position, a bottom inset from the safe area.
//    /// For hidden position, a bottom inset from `FloatingPanelController.view`.
//    /// If a position isn't supported or the default value is used, return nil.
////    func insetFor(position: DrawerPositionType) -> CGFloat?
//
//    /// Returns X-axis and width layout constraints of the surface view of a floating panel.
//    /// You must not include any Y-axis and height layout constraints of the surface view
//    /// because their constraints will be configured by the floating panel controller.
//    /// By default, the width of a surface view fits a safe area.
////    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint]
//
//    /// Returns a CGFloat value to determine the backdrop view's alpha for a position.
//    ///
//    /// Default is 0.3 at full position, otherwise 0.0.
//    //func backdropAlphaFor(position: DrawerPositionType) -> CGFloat
//}


// 縦のデフォルトレイアウト　縦のみ対応
final class DrawerLayout {
    init() {}

    var topInteractionBuffer: CGFloat { return 6.0 }
    var bottomInteractionBuffer: CGFloat { return 6.0 }
    var supportedPositions: Set<DrawerPositionType> {
        return Set([.full, .half, .tip])
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
        ]
    }

    func backdropAlphaFor(position: DrawerPositionType) -> CGFloat {
        return position == .full ? 0.3 : 0.0
    }

    var initialPosition: DrawerPositionType {
        return .half
    }

    func insetFor(position: DrawerPositionType) -> CGFloat? {
        switch position {
        case .full:
            return 18.0
        case .half:
            return 262.0
        case .tip:
            return 69.0
        case .hidden:
            return nil
        }
    }
}

final class DrawerLayoutAdapter {
    // vcとドロワーと背景のviewを保持している。
    weak var vc: UIViewController!
    private weak var surfaceView: DrawerSurfaceView!
    private weak var backgroundView: UIView!
    var layout: DrawerLayout

    var safeAreaInsets: UIEdgeInsets = .zero

    private var initialConst: CGFloat = 0.0

    // 各状態によって制約をためている
    private var fixedConstraints: [NSLayoutConstraint] = []
    private var fullConstraints: [NSLayoutConstraint] = []
    private var halfConstraints: [NSLayoutConstraint] = []
    private var tipConstraints: [NSLayoutConstraint] = []
    private var offConstraints: [NSLayoutConstraint] = []
    private var interactiveTopConstraint: NSLayoutConstraint?

    private var heightConstraint: NSLayoutConstraint?

    private var fullInset: CGFloat {
        return layout.insetFor(position: .full) ?? 0.0
    }
    private var halfInset: CGFloat {
        return layout.insetFor(position: .half) ?? 0.0
    }
    private var tipInset: CGFloat {
        return layout.insetFor(position: .tip) ?? 0.0
    }
    private var hiddenInset: CGFloat {
        return layout.insetFor(position: .hidden) ?? 0.0
    }



    init(surfaceView: DrawerSurfaceView,
         backgroundView: UIView,
         layout: DrawerLayout) {
        self.layout = layout
        self.surfaceView = surfaceView
        self.backgroundView = backgroundView
    }

    var supportedPositions: Set<DrawerPositionType> {
        var supportedPositions = layout.supportedPositions
        supportedPositions.remove(.hidden)
        return supportedPositions
    }

    // Y position
    var topY: CGFloat {
        if supportedPositions.contains(.full) {
            return safeAreaInsets.top + fullInset
        } else {
            return middleY
        }
    }

    var middleY: CGFloat {
        return surfaceView.superview!.bounds.height - (safeAreaInsets.bottom + halfInset)
    }

    var bottomY: CGFloat {
        if supportedPositions.contains(.tip) {
            return surfaceView.superview!.bounds.height - (safeAreaInsets.bottom + tipInset)
        } else {
            return middleY
        }
    }

    var hiddenY: CGFloat {
        return surfaceView.superview!.bounds.height
    }

    func positionY(for pos: DrawerPositionType) -> CGFloat {
        switch pos {
        case .full:
            return topY
        case .half:
            return middleY
        case .tip:
            return bottomY
        case .hidden:
            return hiddenY
        }
    }

    // layout 更新　autolayoutでやってるみたいだな
    func activateLayout(of state: DrawerPositionType) {
        defer {
            surfaceView.superview!.layoutIfNeeded()
        }

        var state = state

        setBackdropAlpha(of: state)

        // Must deactivate `interactiveTopConstraint` here
        if let interactiveTopConstraint = interactiveTopConstraint {
            NSLayoutConstraint.deactivate([interactiveTopConstraint])
            self.interactiveTopConstraint = nil
        }
        NSLayoutConstraint.activate(fixedConstraints)

        if supportedPositions.union([.hidden]).contains(state) == false {
            state = layout.initialPosition
        }

        NSLayoutConstraint.deactivate(fullConstraints + halfConstraints + tipConstraints + offConstraints)
        switch state {
        case .full:
            NSLayoutConstraint.activate(fullConstraints)
        case .half:
            NSLayoutConstraint.activate(halfConstraints)
        case .tip:
            NSLayoutConstraint.activate(tipConstraints)
        case .hidden:
            NSLayoutConstraint.activate(offConstraints)
        }
    }

    private func setBackdropAlpha(of target: DrawerPositionType) {
        if target == .hidden {
            backgroundView.alpha = 0.0
        } else {
            backgroundView.alpha = layout.backdropAlphaFor(position: target)
        }
    }
}
