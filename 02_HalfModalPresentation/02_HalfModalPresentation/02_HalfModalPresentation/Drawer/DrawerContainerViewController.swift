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

    // MARK: ----
    func DrawerDidMove(_ vc: DrawerContainerViewController) // any surface frame changes in dragging

    // MARK: --------
    // called on start of dragging (may require some time and or distance to move)
    func DrawerWillBeginDragging(_ vc: DrawerContainerViewController)
    // MARK: --------
    // called on finger up if the user dragged. velocity is in points/second.
    func DrawerDidEndDragging(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint, targetPosition: DrawerPositionType)
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

    /// Returns the surface view managed by the controller object. It's the same as `self.view`.
    var surfaceView: DrawerSurfaceView! {
        return drawerView.surfaceView
    }

    /// Returns the background view managed by the controller object.
    var backgroundView: UIView! {
        return drawerView.backgroundView
    }

    /// Returns the scroll view that the controller tracks.
    weak var scrollView: UIScrollView? {
        return drawerView.scrollView
    }

    // The underlying gesture recognizer for pan gestures
    var panGestureRecognizer: UIPanGestureRecognizer {
        return drawerView.panGestureRecognizer
    }

    /// The layout object managed by the controller
    var layout: DrawerLayout {
        return drawerView.layoutAdapter.layout
    }

    /// The behavior object managed by the controller
    var behavior: DrawerBehavior {
        return drawerView.behavior
    }

    /// The content insets of the tracking scroll view derived from this safe area
    var adjustedContentInsets: UIEdgeInsets {
        return drawerView.layoutAdapter.adjustedContentInsets
    }

    // ジェスチャー操作を管理するインスタンス
    private(set) var drawerView: DrawerView!

    private(set) var contentViewController: UIViewController?

    private var safeAreaInsetsObservation: NSKeyValueObservation?

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

    /// Creates the view that the controller manages.
    override public func loadView() {
        assert(self.storyboard == nil, "Storyboard isn't supported")

        let view = DrawerPassThroughView()
        view.backgroundColor = .clear

        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)

        surfaceView.frame = view.bounds
        view.addSubview(surfaceView)

        self.view = view as UIView
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

    private func reloadLayout(for traitCollection: UITraitCollection) {
        //drawerView.layoutAdapter.layout = fetchLayout(for: traitCollection)
        drawerView.layoutAdapter.prepareLayout(in: self)
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

    /// Moves the position to the specified position.
    /// - Parameters:
    ///     - to: Pass a FloatingPanelPosition value to move the surface view to the position.
    ///     - animated: Pass true to animate the presentation; otherwise, pass false.
    ///     - completion: The block to execute after the view controller has finished moving. This block has no return value and takes no parameters. You may specify nil for this parameter.
    /// 外からdrawerViewを直接さわらない。drawerContainerVCを必ず通す
    func move(to: DrawerPositionType, animated: Bool, completion: (() -> Void)? = nil) {
        print("move")
        drawerView.move(to: to, animated: animated, completion: completion)
    }

    /// Adds the view managed by the controller as a child of the specified view controller.
    /// - Parameters:
    ///     - parent: A parent view controller object that displays FloatingPanelController's view. A container view controller object isn't applicable.
    ///     - belowView: Insert the surface view managed by the controller below the specified view. By default, the surface view will be added to the end of the parent list of subviews.
    ///     - animated: Pass true to animate the presentation; otherwise, pass false.
    func addDrawer(toParent parent: UIViewController, belowView: UIView? = nil, animated: Bool = false) {
        guard self.parent == nil else {
            return
        }

        if let belowView = belowView {
            parent.view.insertSubview(self.view, belowSubview: belowView)
        } else {
            parent.view.addSubview(self.view)
        }

        parent.addChild(self)

        view.frame = parent.view.bounds // Needed for a correct safe area configuration
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: parent.view.topAnchor, constant: 0.0),
            self.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor, constant: 0.0),
            self.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor, constant: 0.0),
            self.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0.0),
            ])

        show(animated: animated) { [weak self] in
            guard let `self` = self else { return }
            self.didMove(toParent: self)
        }
    }

    private func setUpLayout() {
        // preserve the current content offset
        let contentOffset = scrollView?.contentOffset

        drawerView.layoutAdapter.setupHeight()
        drawerView.layoutAdapter.activateLayout(of: drawerView.state)

        scrollView?.contentOffset = contentOffset ?? .zero
    }



    // MARK: - Container view controller interface

    /// Shows the surface view at the initial position defined by the current layout
    public func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        // Must apply the current layout here
        reloadLayout(for: traitCollection)
        setUpLayout()


        // Must track the safeAreaInsets of `self.view` to update the layout.
        // There are 2 reasons.
        // 1. This or the parent VC doesn't call viewSafeAreaInsetsDidChange() on the bottom
        // inset's update expectedly.
        // 2. The safe area top inset can be variable on the large title navigation bar(iOS11+).
        // That's why it needs the observation to keep `adjustedContentInsets` correct.
        safeAreaInsetsObservation = self.observe(\DrawerContainerViewController.view.safeAreaInsets, options: [.initial, .new]) { [weak self] (vc, _) in
            self?.update(safeAreaInsets: vc.view.safeAreaInsets)
        }

        move(to: drawerView.layoutAdapter.layout.initialPosition,
             animated: animated,
             completion: completion)
    }

    // セーフエリア含めてのレイアウト更新難しそう。。。
    private func update(safeAreaInsets: UIEdgeInsets) {
        guard
            drawerView.layoutAdapter.safeAreaInsets != safeAreaInsets,
            self.drawerView.isDecelerating == false
            else { return }


        drawerView.layoutAdapter.safeAreaInsets = safeAreaInsets

        setUpLayout()

        switch contentInsetAdjustmentBehavior {
        case .always:
            scrollView?.contentInset = adjustedContentInsets
            scrollView?.scrollIndicatorInsets = adjustedContentInsets
        default:
            break
        }
    }


}

class DrawerPassThroughView: UIView {
    public weak var eventForwardingView: UIView?
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        switch hitView {
        case self:
            return eventForwardingView?.hitTest(self.convert(point, to: eventForwardingView), with: event)
        default:
            return hitView
        }
    }
}
