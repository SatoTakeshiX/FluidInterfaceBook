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
    private var drawerContainerVC: DrawerContainerViewController!
    private var searchVC: SearchViewController!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        drawerContainerVC = DrawerContainerViewController()
        drawerContainerVC.delegate = self

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

        // Must be here
        searchVC.searchBar.delegate = self

    }

    private func setupLayout(subView: UIView) {
        // autolayoutで設定する
        subView.translatesAutoresizingMaskIntoConstraints = false
        guard let distanceTop = distanceFromTop(position: .half) else { return }
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
        case .hidden: return nil
        }
    }
}

extension MapViewController: DrawerContainerViewControllerDelegate {
    func DrawerDidMove(_ drawerVC: DrawerContainerViewController) {
        let y = drawerVC.drawerView.surfaceView.frame.origin.y
        let tipY = drawerVC.originYOfSurface(for: .tip)
        if y > tipY - 44.0 {
            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
            self.searchVC?.tableView.alpha = progress
        }
    }

    func drawerWillBeginDragging(_ vc: DrawerContainerViewController) {
        if vc.position == .full {
            searchVC.searchBar.showsCancelButton = false
            searchVC.searchBar.resignFirstResponder()
        }
    }

    func DrawerDidEndDragging(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint, targetPosition: DrawerPositionType) {
        if targetPosition != .full {
            searchVC.hideHeader()
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {[weak self] in
                        guard let self = self else { return }
                        if targetPosition == .tip {
                            self.searchVC.tableView.alpha = 0.0
                        } else {
                            self.searchVC.tableView.alpha = 1.0
                        }
        }, completion: nil)
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        searchVC.hideHeader()
        //drawerContainerVC.move(to: .half, animated: true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchVC.showHeader()
        searchVC.tableView.alpha = 1.0
        //drawerContainerVC.move(to: .full, animated: true)
    }
}
