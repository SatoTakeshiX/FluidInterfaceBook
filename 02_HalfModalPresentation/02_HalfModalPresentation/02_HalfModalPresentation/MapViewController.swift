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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        
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
