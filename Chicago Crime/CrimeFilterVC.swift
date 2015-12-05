//
//  CrimeFilterVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

import UIKit

protocol CrimeFilterDelegate {
    func crimeFilter(filterVC: CrimeFilterVC, didCommitFilterWithResult results:Array<Report> )
}

class CrimeFilterVC: UIViewController {
    var filter: CrimeFilter
    var delegate: CrimeFilterDelegate?

    @IBOutlet weak var resultButton: UIBarButtonItem!

    @IBOutlet weak var limitTextField: UITextField!

    @IBOutlet weak var commitButton: UIButton!
    @IBOutlet weak var commitActivtyView: UIActivityIndicatorView!

    var tableVC:CrimeFilterTableVC?

    required init?(coder aDecoder: NSCoder) {
        filter = CrimeFilter()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commitButton.backgroundColor = UIColor.blackColor()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? CrimeFilterTableVC

        limitTextField.text = "100"

        commitFilter()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    func commitFilter() {
        commitButton.titleLabel?.removeFromSuperview()
        commitButton.userInteractionEnabled = false
        commitActivtyView.startAnimating()

        if tableVC?.startTimeWindow.timeIntervalSinceDate((tableVC?.endTimeWindow)!) > 0 {
            let alertController = UIAlertController(title: "Filter", message: "ERROR: Start time must be before end time", preferredStyle: .Alert)

            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }

        let calendar = NSCalendar.currentCalendar()
        let l = NSDateComponents()
        let u = NSDateComponents()

        l.year = calendar.component(.Year, fromDate: (tableVC?.startTimeWindow)!)
        l.month = calendar.component(.Month, fromDate: (tableVC?.startTimeWindow)!)
        l.day = calendar.component(.Day, fromDate: (tableVC?.startTimeWindow)!)
        l.hour = calendar.component(.Hour, fromDate: (tableVC?.startTimeWindow)!)

        u.year = calendar.component(.Year, fromDate: (tableVC?.endTimeWindow)!)
        u.month = calendar.component(.Month, fromDate: (tableVC?.endTimeWindow)!)
        u.day = calendar.component(.Day, fromDate: (tableVC?.endTimeWindow)!)
        u.hour = calendar.component(.Hour, fromDate: (tableVC?.endTimeWindow)!)

        filter.setLimit(Int(limitTextField.text!)!)
        filter.setDateWindow(lowerBound: l, upperBound: u)
        filter.setYear(Int(tableVC!.yearTextField.text!)!)

        filter.setPrimaryType(primarytypes: (tableVC?.selectedCrimeTypes)!)

        Server.shared.getCrimes(filter) { (result: Array<Report>) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if result.count > 0 {
                    let newTitle = String(result.count) + (result.count > 1 ? " Results" : " Result")
                    self.resultButton.title = newTitle
                }else{
                    self.resultButton.title = "No Results"
                }

                self.delegate?.crimeFilter(self, didCommitFilterWithResult: result)

                self.commitActivtyView.stopAnimating()
                self.commitButton.addSubview(self.commitButton.titleLabel!)
                self.commitButton.userInteractionEnabled = true
            }
        }
    }

    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }
}