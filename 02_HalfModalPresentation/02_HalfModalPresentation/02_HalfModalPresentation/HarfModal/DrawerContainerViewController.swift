//
//  DrawerContainerViewController.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

// Drawerの更新を通知する
protocol DrawerContainerViewControllerDelegate: AnyObject {
//    func DrawerDidChangePosition(_ vc: DrawerContainerViewController) // changed the settled position in the model layer
//
//    /// Asks the delegate if dragging should begin by the pan gesture recognizer.
//    func DrawerShouldBeginDragging(_ vc: DrawerContainerViewController) -> Bool

    // MARK: ----
    func DrawerDidMove(_ vc: DrawerContainerViewController) // any surface frame changes in dragging

    // MARK: --------
    // called on start of dragging (may require some time and or distance to move)
    func DrawerWillBeginDragging(_ vc: DrawerContainerViewController)
    // MARK: --------
    // called on finger up if the user dragged. velocity is in points/second.
    func DrawerDidEndDragging(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint, targetPosition: DrawerPositionType)
//    func DrawerWillBeginDecelerating(_ vc: DrawerContainerViewController) // called on finger up as we are moving
//    func DrawerDidEndDecelerating(_ vc: DrawerContainerViewController) // called when scroll view grinds to a halt
//
//    // called on start of dragging to remove its views from a parent view controller
//    func DrawerDidEndDraggingToRemove(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint)
//    // called when its views are removed from a parent view controller
//    func DrawerDidEndRemove(_ vc: DrawerContainerViewController)
//
//    /// Asks the delegate if the other gesture recognizer should be allowed to recognize the gesture in parallel.
//    ///
//    /// By default, any tap and long gesture recognizers are allowed to recognize gestures simultaneously.
//    func Drawer(_ vc: DrawerContainerViewController, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

final class DrawerContainerViewController: UIViewController {

    /// The delegate of the floating panel controller object.
    weak var delegate: DrawerContainerViewControllerDelegate?{
        didSet{
            //didUpdateDelegate()
        }
    }

    /// The current position of the floating panel controller's contents.
    var position: DrawerPositionType {
        return userInterface.state
    }

    // drawerだけでいいかな？userinterfaceってわかりにくいかな？
    private var userInterface: DrawerView!

    // ジェスチャー操作を管理するインスタンスｓ
    private var drawerGesture: DrawerView!

    init(delegate: DrawerContainerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {

    }
}
