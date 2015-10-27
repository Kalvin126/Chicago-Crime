//
//  Server.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

let API = NSURL(string:"https://data.cityofchicago.org/resource/ijzp-q8t2.json")

class report {
    init(info:Dictionary<String,AnyObject>){
        
    }
}

class Server {
    static let shared = Server()
    
    var rootDictionary:Dictionary<String,AnyObject>
    
    init(){
        rootDictionary = Dictionary()
    }
    
    
    func getstuff(){
        let sesh = NSURLSession.sharedSession()
        let datatask = sesh.dataTaskWithURL(API!) { data, response, error in
            var json:NSArray?
            do{
               json  = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSArray
            } catch {
                
            }
            for root in json! {
                let info:Dictionary = (root as? Dictionary<String,AnyObject>)!
                self.rootDictionary[info["id"] as! String] = report(info: info)
            }
        }
        datatask.resume()
    }
    
}