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

    /// Constants indicating how safe area insets are added to the adjusted content inset.
    enum ContentInsetAdjustmentBehavior: Int {
        case always
        case never
    }

    /// The delegate of the floating panel controller object.
    weak var delegate: DrawerContainerViewControllerDelegate?{
        didSet{
            //didUpdateDelegate()
        }
    }

    /// The current position of the floating panel controller's contents.
    var position: DrawerPositionType {
        return drawerView.state
    }

    // ジェスチャー操作を管理するインスタンス
    private(set) var drawerView: DrawerView!

    private(set) var contentViewController: UIViewController?

    /// The behavior for determining the adjusted content offsets.
    ///
    /// This property specifies how the content area of the tracking scroll view is modified using `adjustedContentInsets`. The default value of this property is FloatingPanelController.ContentInsetAdjustmentBehavior.always.
    let contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior = .always

    init(delegate: DrawerContainerViewControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        drawerView = DrawerView(self,
                                layout: DrawerLayout(),
                                behavior: DrawerBehavior())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawerView = DrawerView(self,
                                layout: DrawerLayout(),
                                behavior: DrawerBehavior())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// Returns the y-coordinate of the point at the origin of the surface view
    public func originYOfSurface(for positionType: DrawerPositionType) -> CGFloat {
        switch positionType {
        case .full:
            return drawerView.layoutAdapter.topY
        case .half:
            return drawerView.layoutAdapter.middleY
        case .tip:
            return drawerView.layoutAdapter.bottomY
        case .hidden:
            return drawerView.layoutAdapter.hiddenY
        }
    }

    /// Sets the view controller responsible for the content portion of the floating panel..
    /// チャイルドビューコントローラを組み込んでいる
    func set(contentViewController: UIViewController) {

        addChild(contentViewController)
        let surfaceView = drawerView.surfaceView
        surfaceView.add(contentView: contentViewController.view)
        contentViewController.didMove(toParent: self)
        self.contentViewController = contentViewController
    }

    // MARK: - Scroll view tracking

    /// Tracks the specified scroll view to correspond with the scroll.
    ///
    /// - Parameters:
    ///     - scrollView: Specify a scroll view to continuously and seamlessly work in concert with interactions of the surface view or nil to cancel it.
    /// - Attention:
    ///     The specified scroll view must be already assigned to the delegate property because the controller intermediates between the various delegate methods.
    public func track(scrollView: UIScrollView?) {

        guard let scrollView = scrollView else {
            drawerView.scrollView = nil
            return
        }

        drawerView.scrollView = scrollView
        if scrollView.delegate !== drawerView {
            drawerView.userScrollViewDelegate = scrollView.delegate
            scrollView.delegate = drawerView
        }
        switch contentInsetAdjustmentBehavior {
        case .always:
            scrollView.contentInsetAdjustmentBehavior = .never
        default:
            break
        }
    }

}
