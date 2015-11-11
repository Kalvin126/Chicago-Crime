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
        
        
        //===============================================
        // EXAMPLE OF FILTER TECHNIQUES DELETE AS NEEDED
        //===============================================
        let f:Filter = Filter()
        let l:NSDateComponents = NSDateComponents()
        let u:NSDateComponents = NSDateComponents()
        
        l.year = Int(2015)
        l.month = Int(8)
        l.day = Int(2)
        l.hour = Int(0)
        
        u.year = Int(2015)
        u.month = Int(10)
        u.day = Int(5)
        u.hour = Int(0)
        
        f.setDateWindow(lowerBound: l, upperBound: u)
        //f.setPrimaryType(primarytype: PrimaryTypes[4])
        
        f.setLimit(10000)
        
        f.setTimeOfDay(14, lowerMinute: 0, upperHour24: 14, upperMinute: 59)
        f.setDaysOfWeek([Day.Friday])
        
        //===============================================
        //                END OF EXAMPLE
        //===============================================
        
        Server.shared.getstuff(assign, params: f)

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
