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

    @IBOutlet weak var schoolLevelLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!

    @IBOutlet weak var actScoreLabel: UILabel!
    @IBOutlet weak var cpsPerformanceLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .CurrentContext
    }

    func setup(withSchool school:School) {
        self.school = school

        schoolLevelLabel.text = school.schoolType
        schoolNameLabel.text = school.name
        actScoreLabel.text = "\(school.actScore)"
        cpsPerformanceLabel.text = school.cpsPerformanceLvl
        
    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
