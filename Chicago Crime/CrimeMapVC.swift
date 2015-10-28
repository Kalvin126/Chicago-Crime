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
    @IBAction func pressedbutton(sender: AnyObject) {
        let region = mapView.region
        let cencoord = mapView.centerCoordinate
        print("region \(region)  \(cencoord)");
    }

//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//
//    }
}
