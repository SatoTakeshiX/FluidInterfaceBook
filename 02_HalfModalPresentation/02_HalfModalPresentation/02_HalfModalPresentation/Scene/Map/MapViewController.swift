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
        setupMap()

        drawerContainerVC = DrawerContainerViewController()

        guard let searchViewController = UIStoryboard.init(name: "SearchViewController", bundle: nil).instantiateInitialViewController() as? SearchViewController else {
            return
        }

        searchVC = searchViewController

        drawerContainerVC.set(contentViewController: searchVC)
        drawerContainerVC.track(scrollView: searchVC.tableView)

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

    func DrawerWillBeginDragging(_ vc: DrawerContainerViewController) {

    }

    func DrawerDidEndDragging(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint, targetPosition: DrawerPositionType) {

    }


}
