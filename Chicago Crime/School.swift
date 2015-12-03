//
//  School.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation
import MapKit
class School : NSObject, MKAnnotation {
    
    // basic info
    var lat:Double?
    var lon:Double?
    var name:String
    var schoolType:String
    var address:String
    var phone:String
    
    // student report
    var actScore:Double?
    
    // graduation/college
    var collegeEligibility:Double?
    var graduationRate:Double?
    var collegeEnrollRate:Double?
    var collegeEnrollNum:Int?
    
    // school report
    var adequateYearlyProgress:String
    var cpsPerformanceLvl:String
    
    var safetyIcon:Icon
    var safetyScore:Double?
    
    var familyInvolveIcon:Icon
    var familyInvolveScore:Double?
    
    var instructionIcon:Icon
    var instructionScore:Double?
    
    var teacherIcon:Icon
    var teacherScore:Double?
    
    var parentEngIcon:Icon
    var parentEngScore:Double?
    
    var avgStudentAttend:Double?
    var misconduct100:Double?
    
    var teacherAttend:Double
    
    var algebraTaking:Int?
    var algebraPassing:Double?
    var coordinate: CLLocationCoordinate2D {
        guard let latitude = lat, longitude = lon else {
            //print("opps, Report has no lat/long for case \(caseNumber)")
            return CLLocationCoordinate2D(latitude: 0, longitude: 0);
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    init(info:Dictionary<String,AnyObject>) {
        func textToDouble(text:String?) -> Double? {
            if text == nil {
                return nil
            }
            if text! == "NDA" {
                return nil
            } else {
                return Double(text!)
            }
        }
        
        // basic info
        lat = Double(info["latitude"] as! String)!
        lon = Double(info["longitude"] as! String)!
        phone = info["phone_number"] as! String
        name = info["name_of_school"] as! String
        schoolType = info["elementary_or_high_school"] as! String
        address = info["street_address"] as! String
        
        print(name)
        print("school type \(schoolType)")
        print("")
        
        
        // college things
        
        collegeEligibility = textToDouble(info["college_eligibility_"] as? String)
        graduationRate = textToDouble(info["graduation_rate_"] as? String)
        collegeEnrollNum = Int(info["college_enrollment_number_of_students_"] as! String)
        
        
        // school report
        familyInvolveIcon = Icon(rawValue: info["family_involvement_icon"] as! String)!
        familyInvolveScore = textToDouble(info["family_involvement_score"] as? String)
        
        teacherScore = textToDouble(info["teachers_score"] as? String)
        teacherIcon = Icon(rawValue: info["teachers_icon_"] as! String)!
        
        parentEngIcon = Icon(rawValue: info["parent_engagement_icon_"] as! String)!
        parentEngScore = textToDouble(info["parent_engagement_score"] as? String)
        
        instructionIcon = Icon(rawValue: info["instruction_icon_"] as! String)!
        instructionScore = textToDouble(info["instruction_score"] as? String)
        
        safetyScore = textToDouble(info["safety_score"] as? String)
        safetyIcon = Icon(rawValue: info["safety_icon_"] as! String)!

        // non score icon duos
        
        adequateYearlyProgress = info["adequate_yearly_progress_made_"] as! String
        
        algebraPassing = textToDouble(info["students_passing_algebra"] as? String)
        algebraTaking = Int(info["students_taking_algebra"] as! String)
        
        misconduct100 = Double(info["rate_of_misconducts_per_100_students_"] as! String)
        avgStudentAttend = textToDouble(info["average_student_attendance"] as? String)
        teacherAttend = Double(info["average_teacher_attendance"] as! String)!
        
        
        cpsPerformanceLvl = info["cps_performance_policy_level"] as! String
        
    }
    
    
    func mapAnnotationView() -> MKAnnotationView {
        let annot = MKPinAnnotationView(annotation: self, reuseIdentifier: "annot")
        annot.enabled = true
        annot.canShowCallout = true
        annot.tintColor = UIColor.blueColor()
        
        // disclosure button
        let discButton = UIButton(type:.DetailDisclosure)
        discButton.addTarget(self, action: "discButtonPressed:", forControlEvents: .TouchUpInside)
        annot.rightCalloutAccessoryView = discButton as UIView
        
        return annot
    }
    
    
}








































