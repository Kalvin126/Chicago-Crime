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

    @IBOutlet weak var crimeImageView: UIImageView!
    @IBOutlet weak var primaryTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var locationDesc: UILabel!

    @IBOutlet weak var descLabel: UILabel!

    @IBOutlet weak var lastUpdatedLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .CurrentContext
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if report != nil {
            setup()
        }
    }

    func setup() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/d/yyyy, h:mm a"

        caseNumberLabel.text = report?.caseNumber

        dateLabel.text = "\(formatter.stringFromDate((report?.date!)!))"

        crimeImageView.tintColor = (report!.arrest ? UIColor.blackColor() : UIColor.darkGrayColor())
        primaryTypeLabel.text = report?.primaryType
        descLabel.text = report?.desc

        blockLabel.text = report?.block
        locationDesc.text = report?.locationDescription

        lastUpdatedLabel.text = "\(formatter.stringFromDate((report?.updatedDate!)!))"

        descLabel.sizeToFit()
        locationDesc.sizeToFit()
    }

    @IBAction func pressedClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
