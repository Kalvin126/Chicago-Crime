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

    required init?(coder aDecoder: NSCoder) {
        filter = Filter()

        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        limitTextField.text = "10"

        commitFilter()
    }

    func commitFilter() {
        let l:NSDateComponents = NSDateComponents()
        let u:NSDateComponents = NSDateComponents()

        l.year = Int(2015)
        l.month = Int(10)
        l.day = Int(2)
        l.hour = Int(0)

        u.year = Int(2015)
        u.month = Int(10)
        u.day = Int(5)
        u.hour = Int(0)

        filter.setLimit(Int(limitTextField.text!)!)
        filter.setDateWindow(lowerBound: l, upperBound: u)
        filter.setPrimaryType(primarytype: PrimaryTypes[4])

        func assign(elements:Array<Report>) {
            if elements.count > 0 {
                resultButton.title = String(elements.count) + (elements.count > 1 ? " Results" : " Result")
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