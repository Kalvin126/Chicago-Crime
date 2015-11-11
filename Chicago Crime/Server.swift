//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation
import MapKit

let API:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json"
let APITest:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json?$where=(date+between+'2015-01-10T12:00:00'+and+'2015-01-10T14:00:00')&primary_type=BURGLARY"
let APIWITHTOKEN:String = "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=\(APPTOKEN)"

let APPTOKEN = "mhVvMlbuAc0Cx3SRZcoL8wuKP"
let APPSECRET = "pfxRm9La0A4R1_s5N9O7rMrzJpqTqYFpkP2L"



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

        // Date
        var dateString:String = (info["date"] as! String)
        let index = dateString.endIndex.advancedBy(-4)
        dateString = dateString.substringToIndex(index)
        date = Server.shared.formatter().dateFromString(dateString)!
        
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
        annot.canShowCallout = true

        // disclosure button
        let discButton = UIButton(type:.DetailDisclosure)
        discButton.addTarget(self, action: "discButtonPressed:", forControlEvents: .TouchUpInside)
        annot.rightCalloutAccessoryView = discButton as UIView

        return annot
    }

}


class Filter: NSObject {
    
    private var primaryType:String?
    private var dateWindow:String?
    private var limit:Int?
    private var year:Int?
    
    func url() -> String {
        
        var url:String = API
        
        if primaryType != nil || dateWindow != nil || year != nil || limit != nil {
            url = url.stringByAppendingString("?")
        }
        
        if let date = dateWindow {
            url = url.stringByAppendingString("$where=\(date)")
        }
        
        if let type = primaryType {
            if dateWindow != nil {
                url = url.stringByAppendingString("&")
            }
            url = url.stringByAppendingString(type)
        }
        
        if let l = limit {
            if dateWindow != nil || primaryType != nil {
                url = url.stringByAppendingString("&")
            }
            url = url.stringByAppendingString("$limit=\(l)")
        }
        
        
        if let y = year {
            if dateWindow != nil || primaryType != nil || limit != nil {
                url = url.stringByAppendingString("&")
            }
            url = url.stringByAppendingString("year=\(y)")
        }
        
        
        NSLog("requesting url \"\(url)\"")
        return url
    }
    
    func setDateWindow(lowerBound l:NSDateComponents, upperBound u:NSDateComponents) {
        // template
        // $where=(date+between+'2015-01-10T12:00:00'+and+'2015-01-10T14:00:00')
        
        
        let afterWhere:String = String(format: "date+between+'\(l.year)-%02i-%02iT%02i:00:00'+and+'\(u.year)-%02i-%02iT%02i:00:00'", arguments: [l.month,l.day,l.hour,u.month,u.day,u.hour])
        dateWindow = afterWhere;
        print("url after set func \(dateWindow!)")
    }
    
    func setPrimaryType(primarytype pt:String) -> Bool {
        if PrimaryTypes.contains(pt) {
            let urlType:String = pt.stringByReplacingOccurrencesOfString(" ", withString: "+")
            primaryType = String(format:"primary_type=\(urlType)" , arguments:[])
            return true
        }
        return false
    }
    
    func setLimit(limit:Int) {
        var l:Int
        if limit > 50000 {
            l = 50000
        } else {
            l = limit
        }
        
        self.limit = l
    }
    
    func setYear(year:Int) {
        self.year = year
    }
}

class Server {
    static let shared = Server()
    
    private var rootArray:Array<Report> = Array()
    
    private func formatter()->NSDateFormatter {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone(abbreviation: "GMT")
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return f
    }
    
    func getstuff(complete:(Array<Report>->Void), params:Filter) {
        self.rootArray.removeAll()
        let sesh = NSURLSession.sharedSession()
        
        let URL:NSURL! = NSURL(string: params.url())
        let datatask = sesh.dataTaskWithURL(URL!) { data, response, error in
            var json:NSArray?
            json = JSON(data:data!).rawArray;
            if let err = error {
                print(err)
                
            }
            
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.rootArray.append(Report(info: info))
            }
            complete(self.rootArray)
        }
        datatask.resume()
    }
    
    func getstuff(complete:(Array<Report>->Void)){
        getstuff(complete, params: Filter())
    }
    
}