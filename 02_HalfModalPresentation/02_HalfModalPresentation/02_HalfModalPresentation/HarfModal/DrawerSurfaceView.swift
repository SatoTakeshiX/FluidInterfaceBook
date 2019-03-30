//
//  DrawerSurfaceView.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

// class FloatingPanelSurfaceContentView: UIView {}

// ドロワー本体
class DrawerSurfaceView: UIView {

    /// A GrabberHandleView object displayed at the top of the surface view.
    ///
    /// To use a custom grabber handle, hide this and then add the custom one
    /// to the surface view at appropriate coordinates.
    public var grabberHandle: GrabberHandleView!

    /// The height of the grabber bar area
    public static var topGrabberBarHeight: CGFloat {
        return Default.grabberTopPadding * 2 + GrabberHandleView.Default.height // 17.0
    }

    /// A root view of a content view controller
    public weak var contentView: UIView!

    private var color: UIColor? = .white { didSet { setNeedsLayout() } }
    var bottomOverflow: CGFloat = 0.0 // Must not call setNeedsLayout()

    public override var backgroundColor: UIColor? {
        get { return color }
        set { color = newValue }
    }

    /// The radius to use when drawing top rounded corners.
    ///
    /// `self.contentView` is masked with the top rounded corners automatically on iOS 11 and later.
    /// On iOS 10, they are not automatically masked because of a UIVisualEffectView issue. See https://forums.developer.apple.com/thread/50854
    public var cornerRadius: CGFloat = 0.0 { didSet { setNeedsLayout() } }

    /// A Boolean indicating whether the surface shadow is displayed.
    public var shadowHidden: Bool = false  { didSet { setNeedsLayout() } }

    /// The color of the surface shadow.
    public var shadowColor: UIColor = .black  { didSet { setNeedsLayout() } }

    /// The offset (in points) of the surface shadow.
    public var shadowOffset: CGSize = CGSize(width: 0.0, height: 1.0)  { didSet { setNeedsLayout() } }

    /// The opacity of the surface shadow.
    public var shadowOpacity: Float = 0.2 { didSet { setNeedsLayout() } }

    /// The blur radius (in points) used to render the surface shadow.
    public var shadowRadius: CGFloat = 3  { didSet { setNeedsLayout() } }

    /// The width of the surface border.
    public var borderColor: UIColor?  { didSet { setNeedsLayout() } }

    /// The color of the surface border.
    public var borderWidth: CGFloat = 0.0  { didSet { setNeedsLayout() } }

    private var backgroundView: UIView!
    private var backgroundHeightConstraint: NSLayoutConstraint!

    private struct Default {
        public static let grabberTopPadding: CGFloat = 6.0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }

    private func render() {
        super.backgroundColor = .clear
        self.clipsToBounds = false

        let backgroundView = UIView()
        addSubview(backgroundView)
        self.backgroundView = backgroundView

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundHeightConstraint = backgroundView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            backgroundHeightConstraint,
            ])


        let grabberHandle = GrabberHandleView()
        addSubview(grabberHandle)
        self.grabberHandle = grabberHandle

        grabberHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberHandle.topAnchor.constraint(equalTo: topAnchor, constant: Default.grabberTopPadding),
            grabberHandle.widthAnchor.constraint(equalToConstant: grabberHandle.frame.width),
            grabberHandle.heightAnchor.constraint(equalToConstant: grabberHandle.frame.height),
            grabberHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
    }

    public override func updateConstraints() {
        super.updateConstraints()
        backgroundHeightConstraint.constant = bottomOverflow
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateLayers()
        updateContentViewMask()

        contentView?.layer.borderColor = borderColor?.cgColor
        contentView?.layer.borderWidth = borderWidth
        contentView?.frame = bounds
    }

    private func updateLayers() {
        backgroundView.backgroundColor = color
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = cornerRadius

        if shadowHidden == false {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        }
    }

    private func updateContentViewMask() {
            // Don't use `contentView.clipToBounds` because it prevents content view from expanding the height of a subview of it
            // for the bottom overflow like Auto Layout settings of UIVisualEffectView in Main.storyboard of Example/Maps.
            // Because the bottom of contentView must be fit to the bottom of a screen to work the `safeLayoutGuide` of a content VC.
            contentView?.layer.masksToBounds = true
            contentView?.layer.cornerRadius = cornerRadius
            contentView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    func add(contentView: UIView) {
        // ビュー階層にいれて、制約を設定する。
        insertSubview(contentView, belowSubview: grabberHandle)
        self.contentView = contentView
        /* contentView.frame = bounds */ // MUST NOT: Because the top safe area inset of a content VC will be incorrect.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        // TODO: ViewControllerの大きさと上下左右０の制約
        // ViewControllerの大きさはつ３つの状態でどう変わっていくのか？何を更新するとドロワー高さが更新されるのか
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            ])
    }

}
