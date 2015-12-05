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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let circleRadius = statLabels[0].frame.height/2
        for label in statLabels {
            label.layer.cornerRadius = circleRadius
            label.layer.masksToBounds = true
        }
    }



    func setup(withSchool school:School) {
        self.school = school

        //schoolLevelLabel.text = school.schoolType
//        schoolNameLabel.text = school.name
//        actScoreLabel.text = "\(school.actScore)"
//        cpsPerformanceLabel.text = school.cpsPerformanceLvl

    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
