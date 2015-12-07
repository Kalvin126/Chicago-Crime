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
    func crimeFilter(filterVC: CrimeFilterVC, didCommitFilterWithResult results:Array<Report>)
    func crimeFilterVCDidClearFilter()

    func schoolForCrimeFilter(filterVC: CrimeFilterVC) -> School?

    func radiusDidChange(radius: Double)
}

class CrimeFilterVC: UIViewController {
    var delegate: CrimeFilterDelegate?

    @IBOutlet weak var resultButton: UIBarButtonItem!

    @IBOutlet weak var limitTextField: UITextField!

    @IBOutlet weak var fetchTimeLabel: UILabel!
    @IBOutlet weak var commitButton: UIButton!
    @IBOutlet weak var commitActivtyView: UIActivityIndicatorView!

    var tableVC:CrimeFilterTableVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        commitButton.backgroundColor = UIColor.blackColor()

        tableVC = (view.viewWithTag(10) as? UITableView)?.delegate as? CrimeFilterTableVC

        limitTextField.text = "50"

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

        let filter = CrimeFilter()

        if tableVC?.startTimeWindow.timeIntervalSinceDate((tableVC?.endTimeWindow)!) > 0 {
            let alertController = UIAlertController(title: "Filter", message: "ERROR: Start time must be before end time", preferredStyle: .Alert)

            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)

            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }

        let calendar = NSCalendar.currentCalendar()
        let l = calendar.components([.Month, .Day, .Hour], fromDate: (tableVC?.startTimeWindow)!)
        let u = calendar.components([.Month, .Day, .Hour], fromDate: (tableVC?.endTimeWindow)!)
        
        l.year = Int((tableVC?.startYearTextField.text)!)!
        u.year = Int((tableVC?.endYearTextField.text)!)!

        filter.setLimit(Int(limitTextField.text!)!)
        filter.setDateWindow(lowerBound: l, upperBound: u)

        if tableVC!.typeFilterOn {
            filter.setPrimaryType(primarytypes: tableVC!.selectedCrimeTypes)
        }

        if let school = delegate?.schoolForCrimeFilter(self) {
            filter.setSchoolWithRadius(school: school, radius: 1609.0*Double(tableVC!.schoolRadiusTextField.text!)!)
        }
        
        Server.shared.getCrimes(filter) { (result: Array<Report>, interval: NSTimeInterval) -> Void in
            if result.count > 0 {
                let newTitle = String(result.count) + (result.count > 1 ? " Results" : " Result")
                self.resultButton.title = newTitle
            }else{
                self.resultButton.title = "No Results"
            }
            
            self.fetchTimeLabel.text = "\(result.count) crimes fetched in " + String(format: "%.4f", interval) + " seconds"
            
            self.delegate?.crimeFilter(self, didCommitFilterWithResult: result)
            
            self.commitActivtyView.stopAnimating()
            self.commitButton.addSubview(self.commitButton.titleLabel!)
            self.commitButton.userInteractionEnabled = true
        }
    }

    @IBAction func pressedLimitStepper(sender: UIStepper) {
        limitTextField.text = "\(Int(sender.value))"
    }

    @IBAction func pressedClearFilter(sender: AnyObject) {
        delegate?.crimeFilterVCDidClearFilter()
    }

    @IBAction func pressedCommit(sender: AnyObject) {
        commitFilter()
    }
}