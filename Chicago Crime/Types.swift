//
//  Types.swift
//  Chicago Crime
//
//  Created by Ethan Gates on 10/29/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

enum Icon : String {
    case VERYWEAK = "Very Weak"
    case WEAK = "Weak"
    case AVERAGE = "Average"
    case STRONG = "Strong"
    case VERYSTRONG = "Very Strong"
    case NDA = "NDA"
}

enum SchoolAttribute {
    case SAFETY_SCORE, PARENT_ENG_SCORE, FAMILY_INVOLV_SCORE, INSTRUCTION_SCORE, TEACHER_SCORE, STUDENT_ATD_SCORE, TEACHER_ATD_SCORE, ALGEBRA_PASSING, GRADUATION_RATE
}

enum PrimaryType : String {
    case ARSON                  = "ARSON"
    case ASSAULT                = "ASSAULT"
    case BATTERY                = "BATTERY"
    case BURGLARY               = "BURGLARY"
    case CRIM_DAMAGE            = "CRIMINAL DAMAGE"
    case CRIM_SEXUAL_ASSAULT    = "CRIMINAL SEXUAL ASSAULT"
    case CRIM_TRESPASS          = "CRIMINAL TRESPASS"
    case DECEPTIVE_PRACTICE     = "DECEPTIVE PRACTICE"
    case HOMICIDE               = "HOMICIDE"
    case INTERFERENCE_OFFICER   = "INTERFERENCE WITH PUBLIC OFFICER"
    case INTIMIDATION           = "INTIMIDATION"
    case KIDNAPPING             = "KIDNAPPING"
    case NARCOTICS              = "NARCOTICS"
    case NON_CRIMINAL           = "NON - CRIMINAL"
    case MOTOR_THEFT            = "MOTOR VEHICLE THEFT"
    case OFFENSE_CHILDREN       = "OFFENSE INVOLVING CHILDREN"
    case OTHER_OFFENSE          = "OTHER OFFENSE"
    case PROSTITUTION           = "PROSTITUTION"
    case PUBLIC_PEACE_VIOLATION = "PUBLIC PEACE VIOLATION"
    case ROBBERY                = "ROBBERY"
    case SEX_OFFENSE            = "SEX OFFENSE"
    case THEFT                  = "THEFT"
    case WEAPONS_VIOLATION      = "WEAPONS VIOLATION"

    static let allValues = [ARSON, ASSAULT, BATTERY, BURGLARY, CRIM_DAMAGE, CRIM_SEXUAL_ASSAULT, CRIM_TRESPASS,
        DECEPTIVE_PRACTICE, HOMICIDE, INTERFERENCE_OFFICER, INTIMIDATION, KIDNAPPING, NARCOTICS,
        NON_CRIMINAL, MOTOR_THEFT, OFFENSE_CHILDREN, OTHER_OFFENSE, PROSTITUTION, PUBLIC_PEACE_VIOLATION,
        ROBBERY, SEX_OFFENSE, THEFT, WEAPONS_VIOLATION]
    static let allRawValues = PrimaryType.allValues.map{ $0.rawValue }
}

enum Day : Int {
    
    case Sunday=1,Monday,Tuesday, Wednesday,Thursday,Friday,Saturday
}

enum SchoolLevel : String {
    case Elementary = "ES"
    case JuniorHigh = "MS"
    case HighSchool = "HS"

    static let allValues = [Elementary, JuniorHigh, HighSchool]
    static let allRawValues = SchoolLevel.allValues.map{ $0.rawValue }
}