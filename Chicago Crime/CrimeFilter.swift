//
//  Filter.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 12/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

class CrimeFilter: NSObject {
    
    private var primaryType:String?
    private var dateWindow:String?
    private var limit:Int?
    private var year:Int?
    var timeFilter:((Array<Report>)->Array<Report>)?
    var dayOfWeekFilter:((Array<Report>)->Array<Report>)?
    
    private var buffer:School?
    private var radius:Int?
    
    func url() -> String {
        
        var url:String = CrimeAPI
        
        if primaryType != nil || dateWindow != nil || year != nil || limit != nil {
            url+="?"
        }
        
        if let date = dateWindow {
            url+="$where=\(date)"
        }
        
        if let type = primaryType {
            if dateWindow == nil {
                url+="$where="
            } else {
                url+="+and+"
            }
            url+=type
        }
        
        if let school = buffer, r = radius {
            if dateWindow == nil && primaryType == nil {
                url+="$where="
            } else {
                url+="+and+"
            }
            
            url+="within_circle(location,+\(school.coordinate.latitude),+\(school.coordinate.longitude),+\(r))"
        }
        
        
        if let l = limit {
            if url.characters.last != "=" {
                url+="&"
            }
            url+="$limit=\(l)"
        }
        
        
        if let y = year {
            if url.characters.last != "=" {
                url+="&"
            }
            url+="year=\(y)"
        }
        
        
        NSLog("requesting url \"\(url)\"")
        return url
    }
    
    func setSchoolWithRadius(school s:School, radius r:Int) {
        buffer = s
        radius = r
    }
    
    func setDateWindow(lowerBound l:NSDateComponents, upperBound u:NSDateComponents) {
        // template
        // $where=(date+between+'2015-01-10T12:00:00'+and+'2015-01-10T14:00:00')
        
        let dateWin:String = String(format: "date+between+'\(l.year)-%02i-%02iT%02i:00:00'+and+'\(u.year)-%02i-%02iT%02i:00:00'", arguments: [l.month,l.day,l.hour,u.month,u.day,u.hour])
        dateWindow = dateWin;
    }
    
    func setPrimaryType(primarytypes pt:Array<PrimaryType>) {
        //    primary_type+in('THEFT','ROBBERY')
        if pt.count == 0 {
            primaryType = nil;
            return
        }
        var allTypes:Array<String> = Array<String>()
        for type:PrimaryType in pt {
            let urlType:String = type.rawValue.stringByReplacingOccurrencesOfString(" ", withString: "+")
            allTypes.append(urlType)
            
        }
        
        var url:String = "primary_type+in('"
        
        for type:String in allTypes {
            url+=type
            url+="',+'"
        }
        url = url.substringToIndex(url.endIndex.predecessor().predecessor().predecessor())
        
        url+=")"
        primaryType = url;
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
    
    func setTimeOfDay(lowerHour24:Int,lowerMinute:Int,upperHour24:Int,upperMinute:Int) {
        func filter(allCrimes:Array<Report>) -> Array<Report> {
            var retVal:Array<Report> = Array<Report>()
            
            for oneCrime:Report in allCrimes {
                let h:Int? = oneCrime.dateComp?.hour
                let m:Int? = oneCrime.dateComp?.minute
                if h <= upperHour24 && h >= lowerHour24 && m <= upperMinute && m >= lowerMinute {
                    retVal.append(oneCrime)
                }
            }
            print("time of day filter chose \(retVal.count) out of \(allCrimes.count)")
            
            return retVal
        }
        timeFilter = filter
    }
    
    func setDaysOfWeek(days:Array<Day>) {
        func filter(allCrimes:Array<Report>) -> Array<Report> {
            var retVal:Array<Report> = Array<Report>()
            
            
            for oneCrime:Report in allCrimes {
                
                
                let d:Int = (oneCrime.dateComp?.weekday)!
                let dayOfCrime:Day = Day(rawValue: d)!
                if days.contains(dayOfCrime) {
                    retVal.append(oneCrime)
                }
            }
            
            print("day of week filter chose \(retVal.count) out of \(allCrimes.count)")
            
            return retVal
        }
        dayOfWeekFilter = filter
    }
    
}