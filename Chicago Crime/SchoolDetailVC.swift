//
//  SchoolDetailVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/3/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class SchoolDetailVC: UIViewController {
    var school: School?

    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!

    @IBOutlet var statLabels: [UILabel]!

    @IBOutlet weak var safetyLabel: UILabel!
    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var attendenceLabel: UILabel!

    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var parentLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!

    @IBOutlet weak var passAlgebraLabel: UILabel!
    @IBOutlet weak var graduationLabel: UILabel!
    @IBOutlet weak var collegeEnrollLabel: UILabel!

    @IBOutlet weak var actLabel: UILabel!
    @IBOutlet weak var cpsPerfLabel: UILabel!
    @IBOutlet weak var misconductLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .CurrentContext
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if school != nil {
            setup()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let circleRadius = statLabels[0].frame.height/2
        for label in statLabels {
            label.layer.cornerRadius = circleRadius
            label.layer.masksToBounds = true
        }
    }

    func setup() {
        schoolNameLabel.text = school!.name
        addressLabel.text = school!.fullAddress
        phoneNumberLabel.text = school!.phone
        districtLabel.text = school!.networkManager

        if let score = school!.safetyScore {
            safetyLabel.text = "\(Int(score))"
            safetyLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            safetyLabel.text = "NDA"
            safetyLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.environmentScore {
            environmentLabel.text = "\(Int(score))"
            environmentLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            environmentLabel.text = "NDA"
            environmentLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.avgStudentAttend {
            attendenceLabel.text = "\(Int(score))"
            attendenceLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            attendenceLabel.text = "NDA"
            attendenceLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.familyInvolveScore {
            familyLabel.text = "\(Int(score))"
            familyLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            familyLabel.text = "NDA"
            familyLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.parentEngScore {
            parentLabel.text = "\(Int(score))"
            parentLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            parentLabel.text = "NDA"
            parentLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.teacherScore {
            teacherLabel.text = "\(Int(score))"
            teacherLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            teacherLabel.text = "NDA"
            teacherLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.algebraPassing {
            passAlgebraLabel.text = "\(Int(score))"
            passAlgebraLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            passAlgebraLabel.text = "NDA"
            passAlgebraLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.graduationRate {
            graduationLabel.text = "\(Int(score))"
            graduationLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            graduationLabel.text = "NDA"
            graduationLabel.backgroundColor = UIColor.blackColor()
        }

        if let score = school!.collegeEnrollRate {
            collegeEnrollLabel.text = "\(Int(score))"
            collegeEnrollLabel.backgroundColor = gradLayer?.colorForRatio(CGFloat(score/100.0))
        } else {
            collegeEnrollLabel.text = "NDA"
            collegeEnrollLabel.backgroundColor = UIColor.blackColor()
        }

        actLabel.text = school!.actScore != nil ? "\(Int(school!.actScore!))" : "NDA"
        cpsPerfLabel.text = school!.cpsPerformanceLvl != "Not Enough Data" ? school!.cpsPerformanceLvl : "NDA"
        misconductLabel.text = school!.misconduct100 != nil ? "\(Int(school!.misconduct100!))" : "NDA"
    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
