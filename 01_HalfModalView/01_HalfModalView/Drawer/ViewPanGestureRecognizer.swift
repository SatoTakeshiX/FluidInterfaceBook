//
//  ViewPanGestureRecognizer.swift
//  01_HalfModalView
//
//  Created by satoutakeshi on 2019/04/08.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

/// UIViewに貼り付けるPangesture
class ViewPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        switch state {
        case .began: return
        default:
            super.touchesBegan(touches, with: event)
            state = .began
        }
    }
}
