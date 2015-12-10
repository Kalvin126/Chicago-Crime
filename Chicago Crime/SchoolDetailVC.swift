//
//  SchoolDetailVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/3/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

protocol SchoolDetailVCDataSource {
    func crimesInArea(schoolDVC: SchoolDetailVC) -> Int;
}

class SchoolDetailVC: UIViewController {
    var school: School?
    var delegate: SchoolDetailVCDataSource?

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

    @IBOutlet weak var crimesArroundLabel: UILabel!
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

        let setScoreLabel = { (let label: UILabel, let val: Double?) -> Void in
            label.textColor = UIColor.whiteColor()

            if let score = val {
                label.text = "\(Int(score))"

                let ratio = score/100.0
                label.backgroundColor = gradLayer?.colorForRatio(CGFloat(ratio))

                if ratio > 0.6 && ratio < 0.8 {
                    label.textColor = UIColor.blackColor()
                }
            } else {
                label.text = "NDA"
                label.backgroundColor = UIColor.blackColor()
            }
        }

        setScoreLabel(safetyLabel, school!.safetyScore)
        setScoreLabel(environmentLabel, school!.environmentScore)
        setScoreLabel(attendenceLabel, school!.avgStudentAttend)

        setScoreLabel(familyLabel, school!.familyInvolveScore)
        setScoreLabel(parentLabel, school!.parentEngScore)
        setScoreLabel(teacherLabel, school!.teacherScore)

        setScoreLabel(passAlgebraLabel, school!.algebraPassing)
        setScoreLabel(graduationLabel, school!.graduationRate)
        setScoreLabel(collegeEnrollLabel, school!.collegeEnrollRate)

        actLabel.text = school!.actScore != nil ? "\(Int(school!.actScore!))" : "NDA"
        cpsPerfLabel.text = school!.cpsPerformanceLvl != "Not Enough Data" ? school!.cpsPerformanceLvl : "NDA"
        misconductLabel.text = school!.misconduct100 != nil ? "\(Int(school!.misconduct100!))" : "NDA"

        if delegate != nil {
            crimesArroundLabel.text = "\(delegate!.crimesInArea(self))";
        }
    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
