//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

let API:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json"
let APITest:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json?$where=date+between+'2013-10-02T00:00:00'+and+'2015-10-02T20:00:00'+AND+primary_type+in('THEFT','ROBBERY')&year=2014"
let APIWITHTOKEN:String = "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=\(APPTOKEN)"

let APPTOKEN = "mhVvMlbuAc0Cx3SRZcoL8wuKP"
let APPSECRET = "pfxRm9La0A4R1_s5N9O7rMrzJpqTqYFpkP2L"

class Server {
    static let shared = Server()
    
    private var rootArray:Array<Report> = Array()
    
    func formatter()->NSDateFormatter {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone(abbreviation: "GMT")
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return f
    }
    
    func getstuff(complete:(Array<Report>->Void), params:Filter) {
        self.rootArray.removeAll()
        let sesh = NSURLSession.sharedSession()
        let timeStart:NSDate = NSDate()
        let datatask = sesh.dataTaskWithURL(NSURL(string: params.url())!) { data, response, error in
            let json:NSArray? = JSON(data:data!).rawArray;
            if let err = error {
                print(err)
            }
            
            let timeStop:NSDate = NSDate()
            
            let interval:NSTimeInterval = timeStop.timeIntervalSinceDate(timeStart)
            
            print("\(json!.count) crimes returned in \(interval) seconds")
            
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.rootArray.append(Report(info: info))
            }
            
            if let filter = params.dayOfWeekFilter {
                self.rootArray = filter(self.rootArray)
            }
            if let filter = params.timeFilter {
                self.rootArray = filter(self.rootArray)
            }
            
            
            
            complete(self.rootArray)
        }
        datatask.resume()
    }
    
    func getstuff(complete:(Array<Report>->Void)){
        getstuff(complete, params: Filter())
    }
    
}