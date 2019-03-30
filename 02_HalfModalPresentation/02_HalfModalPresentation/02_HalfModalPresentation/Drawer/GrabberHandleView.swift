//
//  GrabberHandleView.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

final class GrabberHandleView: UIView {
    struct Default {
        static let width: CGFloat = 36.0
        static let height: CGFloat = 5.0
        static let barColor: UIColor = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }

    init() {
        let size = CGSize(width: Default.width,
                          height: Default.height)
        super.init(frame: CGRect(origin: .zero, size: size))
        self.backgroundColor = Default.barColor
        render()
    }

    private func render() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.height * 0.5
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
