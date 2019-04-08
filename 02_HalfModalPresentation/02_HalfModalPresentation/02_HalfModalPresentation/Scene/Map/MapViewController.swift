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
    //private var drawerContainerVC: DrawerContainerViewController!
    private var searchVC: SearchViewController!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        drawerContainerVC = DrawerContainerViewController()
//        drawerContainerVC.delegate = self

        guard let searchViewController = UIStoryboard(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as? SearchViewController else {
            return
        }

        searchVC = searchViewController

        //drawerContainerVC.set(contentViewController: searchVC)
        //drawerContainerVC.track(scrollView: searchVC.tableView)

        setupMap()

        self.addChild(searchVC)
        self.view.addSubview(searchVC.view)
        searchVC.didMove(toParent: self)

        setupLayout(subView: searchVC.view)

        //
        searchVC.searchBar.delegate = self


        searchVC.tableView.panGestureRecognizer.addTarget(self, action: #selector(handle(panGesture:)))
        searchVC.view.addGestureRecognizer(panGestureRecognizer)
        //setupPanGesture(view: searchVC.view)

    }

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(panGesture:)))
        return pan
    }()

    // 現在のハーフモーダルビューの状態。
    private var currentMode: DrawerPositionType = .half


    @objc private func handle(panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: panGesture.view)
        //panGesture.translation(in: view)
        switch panGesture {
        case searchVC.tableView.panGestureRecognizer:
            let location = panGesture.location(in: panGesture.view)
            
            break
        case panGestureRecognizer:
            break
        default:
            break
        }
    }

    private func setupLayout(subView: UIView) {
        // autolayoutで設定する
        subView.translatesAutoresizingMaskIntoConstraints = false
        guard let distanceTop = distanceFromTop(position: currentMode) else { return }
        subView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -distanceTop).isActive = true
        subView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        subView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        subView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0.0).isActive = true
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Add FloatingPanel to a view with animation.

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

    func distanceFromTop(position: DrawerPositionType) -> CGFloat? {
        switch position {
        case .full: return 18.0
        case .half: return 262.0
        case .tip: return 69.0
        }
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
