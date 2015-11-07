//
//  MapVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

protocol MapVCDelegate {

}

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var crimes:Array<Report> = Array()

    override func viewDidLoad() {
        super.viewDidLoad()

        func assign(elements:Array<Report>) {
            self.crimes = elements

            // add annotation
            mapView.addAnnotations(crimes)
            print("Plotted points")
        }

        Server.shared.getstuff(assign)

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.8570092871228, -87.6975366951543)
        let span = MKCoordinateSpanMake(0.4, 0.7)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    //
    //    }
}
