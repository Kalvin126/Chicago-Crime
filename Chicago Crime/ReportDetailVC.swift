//
//  ReportDetailVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/22/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class ReportDetailVC: UIViewController {

    var report: Report?

    @IBOutlet weak var caseNumberLabel: UILabel!
    @IBOutlet weak var primaryTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var locationDesc: UILabel!

    @IBOutlet weak var descLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .CurrentContext
    }

    func setup(withReport report:Report) {
        self.report = report

        caseNumberLabel.text = report.caseNumber
        primaryTypeLabel.text = report.primaryType

        dateLabel.text = "\(report.date!)"

        locationDesc.text = report.locationDescription
        descLabel.text = report.desc
    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
