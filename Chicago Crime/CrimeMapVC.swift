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

    var crimes:Array<report> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        func assign(elements:Array<report>) {
            self.crimes = elements
        }
        
        Server.shared.getstuff(assign)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedButton(sender: AnyObject) {

    }
}
