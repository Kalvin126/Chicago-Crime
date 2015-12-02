//
//  FilterVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

import UIKit

protocol FilterDelegate {
    func filter(filterVC: FilterVC, didCommitFilter results:Array<Report> )
}

class FilterVC: UIViewController {
    var filter: CrimeFilter
    var delegate: FilterDelegate?

    @IBOutlet weak var resultButton: UIBarButtonItem!

    @IBOutlet weak var limitTextField: UITextField!

    var tableVC:FilterTableVC?

    required init?(coder aDecoder: NSCoder) {
        filter = CrimeFilter()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? FilterTableVC

        limitTextField.text = "10"

        commitFilter()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    func commitFilter() {
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
        filter.setPrimaryType(primarytypes: (tableVC?.selectedCrimeTypes)!)

        func assign(elements:Array<Report>) {
            // getstuff returns on a seperate thread must go back on main
            dispatch_async(dispatch_get_main_queue()) {
                if elements.count > 0 {
                    let newTitle = String(elements.count) + (elements.count > 1 ? " Results" : " Result")
                    self.resultButton.title = newTitle
                }else{
                    self.resultButton.title = "No Results"
                }

                self.delegate?.filter(self, didCommitFilter: elements)
            }
        }

        Server.shared.getCrimes(assign, params: filter)
    }

    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }
}