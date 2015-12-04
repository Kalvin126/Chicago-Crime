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

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var crimes:Array<Report> = []
    var schools:Array<School> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // set initial mapView position
        let center = CLLocationCoordinate2DMake(41.8570092871228, -87.6975366951543)
        let span = MKCoordinateSpanMake(0.4, 0.7)
        mapView.setRegion(MKCoordinateRegionMake(center, span), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addReports(reports: Array<Report>) {
        mapView.removeAnnotations(self.crimes)

        crimes += reports
        mapView.addAnnotations(reports)
    }

    func addSchools(schools: Array<School>) {
        mapView.removeAnnotations(self.schools)

        self.schools += schools
        mapView.addAnnotations(schools)
    }
}
