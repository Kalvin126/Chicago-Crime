//
//  SchoolFilterVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

protocol School1FilterDelegate {
    func schoolFilterVC(filterVC: SchoolFilterVC, didCommitFilterWithResults results:Array<School> )
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
        Server.shared.getSchools(filter) { (result: Array<School>) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if result.count > 0 {
                    let newTitle = String(result.count) + (result.count > 1 ? " Results" : " Result")
                    self.resultButton.title = newTitle
                }else{
                    self.resultButton.title = "No Results"
                }

                self.delegate?.schoolFilterVC(self, didCommitFilterWithResults: result)
            }
        }
    }
    
    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }

}
