//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

let API = NSURL(string:"https://data.cityofchicago.org/resource/ijzp-q8t2.json")
let types:Array = ["ARSON","BATTERY","INTERFERENCE WITH PUBLIC OFFICER","HOMICIDE","OTHER OFFENSE","BURGLARY","PROSTITUTION","CRIM SEXUAL ASSAULT","SEX OFFENSE","KIDNAPPING","OFFENSE INVOLVING CHILDREN","NON - CRIMINAL","ASSAULT","THEFT","CRIMINAL DAMAGE","MOTOR VEHICLE THEFT","CRIMINAL TRESPASS","ROBBERY","WEAPONS VIOLATION","INTIMIDATION","PUBLIC PEACE VIOLATION","DECEPTIVE PRACTICE","NARCOTICS"]


class report {
    
    var lon:Double?
    var lat:Double?
    
    var id:Int = Int()
    var description:String
    var block:String
    var primaryType:String
    var date:NSDate?
    var arrest:Bool
    var domestic:Bool
    var locationDescription:String
    var caseNumber:String
    
    init(info:Dictionary<String,AnyObject>){
        if let st = (info["longitude"] as! String?) {
            lon = Double(st)
        }
        if let st = (info["latitude"] as! String?) {
            lat = Double(st)
        }
        id = Int(info["id"] as! String)!
        description = info["description"] as! String
        block = info["block"] as! String
        primaryType = info["primary_type"] as! String
        
        date = Server.shared.formatter().dateFromString(info["date"] as! String)
        
        arrest = info["arrest"] as! Bool
        domestic = info["domestic"] as! Bool
        
        locationDescription = info["location_description"] as! String
        caseNumber = info["case_number"] as! String
    }
    
}



class Server {
    static let shared = Server()
    
    var rootArray:Array<report> = Array()
    
    func formatter()->NSDateFormatter {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone(abbreviation: "GMT")
        //f.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return f
    }
    
    func getstuff(complete:(Array<report>->Void)){
        let sesh = NSURLSession.sharedSession()
        let datatask = sesh.dataTaskWithURL(API!) { data, response, error in
            var json:NSArray?
            json = JSON(data:data!).rawArray;
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.rootArray.append(report(info: info))
            }
            complete(self.rootArray)
        }
        datatask.resume()
    }
    
}