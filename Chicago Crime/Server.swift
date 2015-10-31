//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation
import MapKit

let API = NSURL(string:"https://data.cityofchicago.org/resource/ijzp-q8t2.json")



class Report: NSObject, MKAnnotation {
    
    var lon:Double?
    var lat:Double?
    
    var id:Int = Int()
    var desc:String
    var block:String
    var primaryType:String
    var date:NSDate?
    var arrest:Bool
    var domestic:Bool
    var locationDescription:String
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
        
        date = Server.shared.formatter().dateFromString(info["date"] as! String)
        
        arrest = info["arrest"] as! Bool
        domestic = info["domestic"] as! Bool
        
        locationDescription = info["location_description"] as! String
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
        annot.canShowCallout = true

        // disclosure button
        let discButton = UIButton(type:.DetailDisclosure)
        discButton.addTarget(self, action: "discButtonPressed:", forControlEvents: .TouchUpInside)
        annot.rightCalloutAccessoryView = discButton as UIView

        return annot
    }

}


class Filter: NSObject {
    
    func setPrimaryTypeFilter(types:Array<PrimaryType>) {
        
    }
    
    func setPrimaryTypeFilter(types:Array<String>) {
        
    }
    
}

class Server {
    static let shared = Server()
    
    var rootArray:Array<Report> = Array()
    
    func formatter()->NSDateFormatter {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone(abbreviation: "GMT")
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return f
    }
    
    func getstuff(complete:(Array<Report>->Void)){
        let sesh = NSURLSession.sharedSession()
        let datatask = sesh.dataTaskWithURL(API!) { data, response, error in
            var json:NSArray?
            json = JSON(data:data!).rawArray;
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.rootArray.append(Report(info: info))
            }
            complete(self.rootArray)
        }
        datatask.resume()
    }
    
}