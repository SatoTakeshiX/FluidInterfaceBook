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

    @IBOutlet weak var mapView: MKMapView!
    private var drawerContainerVC: DrawerContainerViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()

        drawerContainerVC = DrawerContainerViewController()

        
    }

    private func setupMap() {
        let center = CLLocationCoordinate2D(latitude: 37.623198015869235,
                                            longitude: -122.43066818432008)
        let span = MKCoordinateSpan(latitudeDelta: 0.4425100023575723,
                                    longitudeDelta: 0.28543697435880233)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.showsCompass = true
        mapView.showsUserLocation = true
    }

//    private func clearMap() {
//        mapView.delegate = nil
//    }


}

extension MapViewController: DrawerContainerViewControllerDelegate {
    func DrawerDidMove(_ drawerVC: DrawerContainerViewController) {
        let y = drawerVC.drawerView.surfaceView.frame.origin.y
        let tipY = drawerVC.originYOfSurface(for: .tip)
        if y > tipY - 44.0 {
            let proÇgress = max(0.0, min((tipY  - y) / 44.0, 1.0))
            //self.searchVC.tableView.alpha = progress
        }
    }

    func DrawerWillBeginDragging(_ vc: DrawerContainerViewController) {

    }

    func DrawerDidEndDragging(_ vc: DrawerContainerViewController, withVelocity velocity: CGPoint, targetPosition: DrawerPositionType) {

    }


}
