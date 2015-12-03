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

    @IBOutlet weak var commitButton: UIButton!
    @IBOutlet weak var commitActivtyView: UIActivityIndicatorView!

    var tableVC:SchoolFilterTableVC?

    required init?(coder aDecoder: NSCoder) {
        filter = SchoolFilter()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commitButton.backgroundColor = UIColor.blueColor()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? SchoolFilterTableVC

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

        if tableVC?.selectedSchoolLevels.count != 0 {
            filter.setSchoolLevel((tableVC?.selectedSchoolLevels[0])!)
        }

        Server.shared.getSchools(filter) { (result: Array<School>) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if result.count > 0 {
                    let newTitle = String(result.count) + (result.count > 1 ? " Results" : " Result")
                    self.resultButton.title = newTitle
                }else{
                    self.resultButton.title = "No Results"
                }

                self.delegate?.schoolFilterVC(self, didCommitFilterWithResults: result)

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
