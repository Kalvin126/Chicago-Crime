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
    var filter: Filter
    var delegate: FilterDelegate?

    @IBOutlet weak var resultButton: UIBarButtonItem!

    @IBOutlet weak var limitTextField: UITextField!

    var tableVC:FilterTableVC?
    @IBOutlet weak var tableContainerConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        filter = Filter()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? FilterTableVC
        
        self.automaticallyAdjustsScrollViewInsets = false

        limitTextField.text = "10"

        commitFilter()
    }

    func commitFilter() {
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
        filter.setPrimaryType(primarytype: PrimaryType.allRawValues[4])

        func assign(elements:Array<Report>) {
            if elements.count > 0 {
                // TODO: hmm this does not work...
                let newTitle = String(elements.count) + (elements.count > 1 ? " Results" : " Result")
                self.navigationItem.rightBarButtonItem?.title = newTitle
            }else{
                resultButton.title = "No Results"
            }

            delegate?.filter(self, didCommitFilter: elements)
        }

        Server.shared.getstuff(assign, params: filter)
    }

    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }



}