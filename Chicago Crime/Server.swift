//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

let CrimeAPI:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json"
let CrimeAPITest:String = "https://data.cityofchicago.org/resource/6zsd-86xi.json?$where=date+between+'2013-10-02T00:00:00'+and+'2015-10-02T20:00:00'+AND+primary_type+in('THEFT','ROBBERY')+AND+within_circle(location,%2041.82814609,%20-87.63279369,%201609)&year=2014"
let CrimeAPIWITHTOKEN:String = "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=\(APPTOKEN)"

let SchoolAPI:String = "https://data.cityofchicago.org/resource/9xs2-f89t.json"
let SchoolAPITest:String = "https://data.cityofchicago.org/resource/9xs2-f89t.json"

let APPTOKEN = "mhVvMlbuAc0Cx3SRZcoL8wuKP"
let APPSECRET = "pfxRm9La0A4R1_s5N9O7rMrzJpqTqYFpkP2L"

class Server {
    static let shared = Server()
    
    private var crimeArray:Array<Report> = Array()
    private var schoolArray:Array<School> = Array();
    
    func formatter()->NSDateFormatter {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone(abbreviation: "GMT")
        f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        return f
    }
    
    func getSchools(params:SchoolFilter, complete: (result: Array<School>, interval: NSTimeInterval) -> Void) {
        self.schoolArray.removeAll()
        let sesh = NSURLSession.sharedSession()
        let timeStart:NSDate = NSDate()
        let datatask = sesh.dataTaskWithURL(NSURL(string: params.url())!) { data, response, error in
            let json:NSArray? = JSON(data:data!).rawArray;
            if let err = error {
                print(err)
                return
            }
            
            let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(timeStart)
            print("\(json!.count) schools returned in \(interval) seconds")
            
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.schoolArray.append(School(info: info))
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                complete(result: self.schoolArray, interval: interval)
            })
            
        }
        datatask.resume()
    }

    func getCrimes(params:CrimeFilter, complete: (result: Array<Report>, interval: NSTimeInterval) -> Void) {
        self.crimeArray.removeAll()
        let sesh = NSURLSession.sharedSession()
        let timeStart:NSDate = NSDate()
        let datatask = sesh.dataTaskWithURL(NSURL(string: params.url())!) { data, response, error in
            let json:NSArray? = JSON(data:data!).rawArray;
            if let err = error {
                print(err)
            }
            
            let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(timeStart)
            print("\(json!.count) crimes returned in \(interval) seconds")
            
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.crimeArray.append(Report(info: info))
            }
            
            if let filter = params.dayOfWeekFilter {
                self.crimeArray = filter(self.crimeArray)
            }
            if let filter = params.timeFilter {
                self.crimeArray = filter(self.crimeArray)
            }

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                complete(result: self.crimeArray, interval: interval)
            })
        }
        datatask.resume()
    }
}