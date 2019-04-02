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

// 縦のデフォルトレイアウト　縦のみ対応
final class DrawerLayout {
    // vcとドロワーと背景のviewを保持している。
    weak var vc: UIViewController!
    private weak var surfaceView: DrawerSurfaceView!
    private weak var backgroundView: UIView!
    // var layout: DrawerLayout

    var safeAreaInsets: UIEdgeInsets = .zero

    private var initialConst: CGFloat = 0.0

    var bottomInteractionBuffer: CGFloat { return 6.0 }
    var topInteractionBuffer: CGFloat { return 6.0 }
    var supportedPositions: Set<DrawerPositionType> {
        return Set([.full, .half, .tip])
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
        ]
    }

    /// 初期配置
    var initialPosition: DrawerPositionType {
        return .half
    }

    func insetFor(position: DrawerPositionType) -> CGFloat {
        switch position {
        case .full:
            return 18.0
        case .half:
            return 262.0
        case .tip:
            return 69.0
        case .hidden:
            return 0.0
        }
    }

    // 各状態によって制約をためている
    private var fixedConstraints: [NSLayoutConstraint] = []
    private var fullConstraints: [NSLayoutConstraint] = []
    private var halfConstraints: [NSLayoutConstraint] = []
    private var tipConstraints: [NSLayoutConstraint] = []
    private var offConstraints: [NSLayoutConstraint] = []
    private var interactiveTopConstraint: NSLayoutConstraint?

    private var fullInset: CGFloat {
        return insetFor(position: .full)
    }
    private var halfInset: CGFloat {
        return insetFor(position: .half)
    }
    private var tipInset: CGFloat {
        return insetFor(position: .tip)
    }
    private var hiddenInset: CGFloat {
        return insetFor(position: .hidden)
    }

    var bottomMaxY: CGFloat {
        return surfaceView.superview!.bounds.height - (safeAreaInsets.bottom + hiddenInset)

    }

    init(surfaceView: DrawerSurfaceView,
         backgroundView: UIView) {
        self.surfaceView = surfaceView
        self.backgroundView = backgroundView
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

    var adjustedContentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0.0,
                            left: 0.0,
                            bottom: safeAreaInsets.bottom,
                            right: 0.0)
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

        // Must deactivate `interactiveTopConstraint` here
        if let interactiveTopConstraint = interactiveTopConstraint {
            NSLayoutConstraint.deactivate([interactiveTopConstraint])
            self.interactiveTopConstraint = nil
        }
        NSLayoutConstraint.activate(fixedConstraints)

        if supportedPositions.union([.hidden]).contains(state) == false {
            state = initialPosition
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

    func prepareLayout(in vc: UIViewController) {
        self.vc = vc

        // 制約削除
        NSLayoutConstraint.deactivate(fixedConstraints + fullConstraints + halfConstraints + tipConstraints + offConstraints)

        surfaceView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        // Fixed constraints of surface and background views
        let surfaceConstraints = prepareLayout(surfaceView: surfaceView, in: vc.view!)
        let backgroundConstraints = [
            backgroundView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0.0),
            backgroundView.leftAnchor.constraint(equalTo: vc.view.leftAnchor,constant: 0.0),
            backgroundView.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: 0.0),
            backgroundView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0.0),
        ]

        fixedConstraints = surfaceConstraints + backgroundConstraints

        // Flexible surface constraints for full, half, tip and off
        let topAnchor: NSLayoutYAxisAnchor = {
            return vc.view.safeAreaLayoutGuide.topAnchor
        }()

        fullConstraints = [
            surfaceView.topAnchor.constraint(equalTo: topAnchor,
                                             constant: fullInset),
        ]


        let bottomAnchor: NSLayoutYAxisAnchor = {
            return vc.view.safeAreaLayoutGuide.bottomAnchor
        }()

        halfConstraints = [
            surfaceView.topAnchor.constraint(equalTo: bottomAnchor,
                                             constant: -halfInset),
        ]
        tipConstraints = [
            surfaceView.topAnchor.constraint(equalTo: bottomAnchor,
                                             constant: -tipInset),
        ]

        offConstraints = [
            surfaceView.topAnchor.constraint(equalTo:vc.view.bottomAnchor,
                                             constant: -hiddenInset),
        ]
    }

    // The method is separated from prepareLayout(to:) for the rotation support
    // It must be called in FloatingPanelController.traitCollectionDidChange(_:)
    // よこむき対応のためのもの。今回はいらない？高さを出すために必要
    func setupHeight() {
        guard let vc = vc else { return }

        let heightConstraint = surfaceView.heightAnchor.constraint(equalTo: vc.view.heightAnchor,
                                                                   constant: -(safeAreaInsets.top + fullInset))
        print("sss:\(safeAreaInsets.top + fullInset)")
        NSLayoutConstraint.activate([heightConstraint])

        surfaceView.bottomOverflow = vc.view.bounds.height + topInteractionBuffer

    }

    func startInteraction(at state: DrawerPositionType) {
        NSLayoutConstraint.deactivate(fullConstraints + halfConstraints + tipConstraints + offConstraints)
        guard let vc = vc else { return }
        initialConst = surfaceView.frame.minY - safeAreaInsets.top
        let interactiveTopConstraint = surfaceView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor,
                                                                    constant: initialConst)

        NSLayoutConstraint.activate([interactiveTopConstraint])
        self.interactiveTopConstraint = interactiveTopConstraint
    }

    func updateInteractiveTopConstraint(diff: CGFloat, allowsTopBuffer: Bool) {
        defer {
            surfaceView.superview!.layoutIfNeeded() // MUST call here to update `surfaceView.frame`
        }

        let minY: CGFloat = {

            var ret = fullInset

            if allowsTopBuffer {
                ret -= topInteractionBuffer
            }
            return max(ret, 0.0) // The top boundary is equal to the related topAnchor.
        }()
        let maxY: CGFloat = {

            var ret = bottomY - safeAreaInsets.top

            ret += bottomInteractionBuffer
            return min(ret, bottomMaxY)
        }()
        let const = initialConst + diff

        interactiveTopConstraint?.constant = max(minY, min(maxY, const))
    }
}
