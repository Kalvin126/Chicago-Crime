//
//  Report.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 12/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation
import MapKit

class Report: NSObject, MKAnnotation {
    
    var lon:Double?
    var lat:Double?
    
    var id:Int = Int()
    var desc:String
    var block:String
    var primaryType:String
    var date:NSDate?
    var dateComp:NSDateComponents?
    
    
    var arrest:Bool
    var domestic:Bool
    var locationDescription:String?
    var caseNumber:String
    
    var coordinate: CLLocationCoordinate2D {
        guard let latitude = lat, longitude = lon else {
            //print("opps, Report has no lat/long for case \(caseNumber)")
            return CLLocationCoordinate2D(latitude: 0, longitude: 0);
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(info:Dictionary<String,AnyObject>){
        id = Int(info["id"] as! String)!
        desc = info["description"] as! String
        block = info["block"] as! String
        primaryType = info["primary_type"] as! String
        print(primaryType)
        
        // Date
        var dateString:String = (info["date"] as! String)
        let index = dateString.endIndex.advancedBy(-4)
        dateString = dateString.substringToIndex(index)
        date = Server.shared.formatter().dateFromString(dateString)!
        if date != nil {
            let cal:NSCalendar = NSCalendar.currentCalendar()
            cal.timeZone = NSTimeZone(abbreviation: "GMT")!
            dateComp = cal.components([.Weekday,.Day,.Hour,.Minute,.Year], fromDate: date!)
        }
        print(date)
        
        arrest = info["arrest"] as! Bool
        domestic = info["domestic"] as! Bool
        
        if let ld = info["location_description"] as! String? {
            locationDescription = ld
        }
        caseNumber = info["case_number"] as! String
        super.init()
        
        if let la = (info["latitude"] as! String?), lo = (info["longitude"] as! String?) {
            lon = Double(lo)
            lat = Double(la)
        } else {
            // No lat/long Must geocode block
            // This may not finish by the time all other reports finish though
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(self.block + ", Chicago, IL", completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let location = placemarks?.first?.location?.coordinate {
                    self.lat = location.latitude
                    self.lon = location.longitude
                }
            })
        }
    }
    
    func mapAnnotationView() -> MKAnnotationView {
        let annot = MKPinAnnotationView(annotation: self, reuseIdentifier: "annot")
        annot.enabled = true
        annot.canShowCallout = false
        annot.pinTintColor = UIColor.blackColor()
        
        // disclosure button
        let discButton = UIButton(type:.DetailDisclosure)
        discButton.addTarget(self, action: "discButtonPressed:", forControlEvents: .TouchUpInside)
        annot.rightCalloutAccessoryView = discButton as UIView
        
        return annot
    }
    
}