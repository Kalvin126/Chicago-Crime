//
//  SchoolFilterVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

protocol School1FilterDelegate {
    func filter(filterVC: FilterVC, didCommitFilter results:Array<Report> )
}

class SchoolFilterVC: UIViewController {
    var filter: SchoolFilter
    var delegate: School1FilterDelegate?

    @IBOutlet weak var resultButton: UIBarButtonItem!

    @IBOutlet weak var limitTextField: UITextField!

    var tableVC:SchoolFilterTableVC?

    required init?(coder aDecoder: NSCoder) {
        filter = SchoolFilter()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? SchoolFilterTableVC

        limitTextField.text = "100"
        // TODO: Connect!
        //commitFilter()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    func commitFilter() {


//        func assign(elements:Array<Report>) {
//            // getstuff returns on a seperate thread must go back on main
//            dispatch_async(dispatch_get_main_queue()) {
//                if elements.count > 0 {
//                    let newTitle = String(elements.count) + (elements.count > 1 ? " Results" : " Result")
//                    self.resultButton.title = newTitle
//                }else{
//                    self.resultButton.title = "No Results"
//                }
//
//                //self.delegate?.filter(self, didCommitFilter: elements)
//            }
//        }
//
//        Server.shared.getstuff(assign, params: filter)
    }
    
    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }

}
