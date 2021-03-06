//
//  School.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation
import MapKit


internal extension CALayer {
    func colorForRatio(ratio:CGFloat)->UIColor {
        
        if ratio == CGFloat(-1) {
            return UIColor.blueColor()
        }
        
        let point:CGPoint = CGPoint(x: self.frame.width*ratio, y: 2)
        
        var pixel:[CUnsignedChar] = [0,0,0,0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        
        self.renderInContext(context!)
        
        let red:CGFloat = CGFloat(pixel[0])/255.0
        let green:CGFloat = CGFloat(pixel[1])/255.0
        let blue:CGFloat = CGFloat(pixel[2])/255.0
        let alpha:CGFloat = CGFloat(pixel[3])/255.0
        
        return UIColor(red:red, green: green, blue:blue, alpha:alpha)
    }
}

internal class School : NSObject, MKAnnotation {
    
    var selectedFloat:CGFloat?
    
    // basic info
    var lat:Double?
    var lon:Double?
    var name:String
    var schoolType:String
    var address:String
    var phone:String
    var networkManager:String
    var fullAddress:String {
        return "\(address), \(city), \(state) \(zip)"
    }
    
    var state:String
    var city:String
    var zip:String
    
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
    
    var environmentScore:Double?
    var teacherAttend:Double
    
    var algebraTaking:Int?
    var algebraPassing:Double?

    // Filter Commit Time var
    var crimesInAreaCount: Int = 0
    
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
        networkManager = info["network_manager"] as! String
        
        state = info["state"] as! String
        city = info["city"] as! String
        zip = info["zip_code"] as! String

        // college things
        
        collegeEligibility = textToDouble(info["college_eligibility_"] as? String)
        graduationRate = textToDouble(info["graduation_rate_"] as? String)
        collegeEnrollNum = Int(info["college_enrollment_number_of_students_"] as! String)
        collegeEnrollRate = textToDouble(info["college_enrollment_rate"] as? String)
        
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
        
        environmentScore = textToDouble(info["environment_score"] as? String)
        // non score icon duos
        
        adequateYearlyProgress = info["adequate_yearly_progress_made_"] as! String
        
        algebraPassing = textToDouble(info["students_passing_algebra"] as? String)
        algebraTaking = Int(info["students_taking_algebra"] as! String)
        
        misconduct100 = Double(info["rate_of_misconducts_per_100_students_"] as! String)
        
        avgStudentAttend = textToDouble(info["average_student_attendance"] as? String)
        teacherAttend = Double(info["average_teacher_attendance"] as! String)!
        
        
        cpsPerformanceLvl = info["cps_performance_policy_level"] as! String
        actScore = textToDouble(info["_th_grade_average_act_2011_"] as? String)
    }
    
    func selectedAttributeFloat()-> CGFloat {
        if selectedFloat == nil { return CGFloat(-1) }
        
        return selectedFloat!
    }
    
    func setAttribute(SelectedAttribute s: SchoolAttribute, scale:Int? = nil) {
        switch s {
        case .SAFETY_SCORE:
            selectedFloat = safetyScore != nil ? CGFloat(safetyScore!/100) : nil
            break
        case .PARENT_ENG_SCORE:
            selectedFloat = parentEngScore != nil ? CGFloat(parentEngScore!/100) : nil
            break
        case .FAMILY_INVOLV_SCORE:
            selectedFloat = familyInvolveScore != nil ? CGFloat(familyInvolveScore!/100) : nil
            break
        case .INSTRUCTION_SCORE:
            selectedFloat = instructionScore != nil ? CGFloat(instructionScore!/100) : nil
            break
        case .TEACHER_SCORE:
            selectedFloat = teacherScore != nil ? CGFloat(teacherScore!/100) : nil
            break
        case .STUDENT_ATD_SCORE:
            selectedFloat = avgStudentAttend != nil ? CGFloat(avgStudentAttend!/100) : nil
            break
        case .TEACHER_ATD_SCORE:
            selectedFloat = CGFloat(teacherAttend/100)
            break
        case .ALGEBRA_PASSING:
            selectedFloat = algebraPassing != nil ? CGFloat(algebraPassing!/100) : nil
            break
        case .GRADUATION_RATE:
            selectedFloat = graduationRate != nil ? CGFloat(graduationRate!/100) : nil
        case .CRIMES_NEARBY:
            selectedFloat = CGFloat(1.0 - Double(crimesInAreaCount)/Double(scale!))
            break;
        }
    }

    func tintColor() -> UIColor {
        return selectedFloat != nil ? gradLayer!.colorForRatio(selectedAttributeFloat()) : UIColor.blueColor()
    }

    static let imgBorder:UIImage = UIImage(named: "School_Icon_Border")!
    static let img:UIImage = UIImage(named: "School_Icon")!
    func mapAnnotationView() -> MKAnnotationView {
        let annot = MKAnnotationView(annotation: self, reuseIdentifier: "annot")
        annot.enabled = true
        annot.canShowCallout = false
        annot.tintColor = tintColor()
        
        let subBorder = UIImageView(image: School.imgBorder)
        subBorder.userInteractionEnabled = false
        annot.addSubview(subBorder)
        
        let sub = UIImageView(image: School.img)
        sub.userInteractionEnabled = false
        annot.addSubview(sub)
        
        annot.frame = subBorder.bounds
        
        // disclosure button
        let discButton = UIButton(type:.DetailDisclosure)
        discButton.addTarget(self, action: "discButtonPressed:", forControlEvents: .TouchUpInside)
        annot.rightCalloutAccessoryView = discButton as UIView
        
        return annot
    }
    
    
}
