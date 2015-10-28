//
//  CrimeMapVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/27/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

class CrimeMapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.996101696641887, -87.950124889717827)
        let span = MKCoordinateSpanMake(0.5, 1.0)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)

        // add annotation
        //mapView.addAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//
//    }
}
