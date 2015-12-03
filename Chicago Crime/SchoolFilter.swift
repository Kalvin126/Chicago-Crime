//
//  SchoolFilter.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

class SchoolFilter : NSObject {
    
    private var schoolLvl:SchoolLevel?
    
    func setSchoolLevel(lvl:SchoolLevel) {
        schoolLvl = lvl;
    }
    
    func url() ->String {
        var url = SchoolAPI
        
        if let s = schoolLvl {
            url+="?elementary_or_high_school=\(s.rawValue)"
        }
        
        return url
    }
    
    
}


















































