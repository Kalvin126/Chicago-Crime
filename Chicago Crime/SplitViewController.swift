//
//  SplitViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

class SplitViewController: UISplitViewController, MapVCDelegate, CrimeFilterDelegate, School1FilterDelegate {

    var mapVC:MapVC?
    var tabBarC:UITabBarController?

    weak var reportDVC:ReportDetailVC?
    weak var schoolDVC:SchoolDetailVC?
    
    var schoolGradient:CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        schoolGradient = CAGradientLayer()
        schoolGradient!.colors = [UIColor.redColor().CGColor, UIColor.orangeColor().CGColor,UIColor.yellowColor().CGColor,UIColor.yellowColor().CGColor,UIColor.greenColor().CGColor]
        schoolGradient!.locations = [0.0 ,0.3,0.65,0.68, 1.0]
        schoolGradient?.startPoint = CGPoint(x: 0.0, y: 0.5)
        schoolGradient?.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        
        mapVC = self.viewControllers[0] as? MapVC
        mapVC!.delegate = self

        tabBarC = self.viewControllers[1] as? UITabBarController

        for navVC in tabBarC!.viewControllers! {
            let vc = (navVC as! UINavigationController).viewControllers[0]
            switch vc {
            case is CrimeFilterVC:
                (vc as? CrimeFilterVC)?.delegate = self;
                break
            case is SchoolFilterVC:
                (vc as? SchoolFilterVC)?.delegate = self;
                break
            default:
                break
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let gradientView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        gradientView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        schoolGradient?.frame = gradientView.bounds
        gradientView.layer.insertSublayer(schoolGradient!, above: view.layer)
        
        mapVC!.view.insertSubview(gradientView, aboveSubview: mapVC!.view)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillToggle:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillToggle:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let screenWidth = self.view.frame.width
        let kMasterViewWidth:CGFloat = screenWidth - (screenWidth)/3.5

        let masterViewController = mapVC!
        let detailViewController = tabBarC!

        if detailViewController.view.frame.origin.x > 0.0 {
            // Adjust the width of the master view
            var masterViewFrame:CGRect = masterViewController.view.frame
            let deltaX:CGFloat = masterViewFrame.size.width - kMasterViewWidth
            masterViewFrame.size.width -= deltaX
            masterViewController.view.frame = masterViewFrame

            // Adjust the width of the detail view
            var detailViewFrame:CGRect = detailViewController.view.frame
            detailViewFrame.origin.x -= deltaX
            detailViewFrame.size.width += deltaX
            detailViewController.view.frame = detailViewFrame

            // Re evaluate Layouts
            masterViewController.view.setNeedsLayout()
            detailViewController.view.setNeedsLayout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Funcs

    func keyboardWillToggle(notification:NSNotification) {
        var frame = tabBarC!.tabBar.frame
        let keyboard = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"]?.CGRectValue

        frame.origin.y = keyboard!.origin.y - frame.size.height
        UIView.animateWithDuration(Double((notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"]?.floatValue)!)) { () -> Void in
            self.tabBarC?.tabBar.frame = frame
        }
    }

    func showReportDVC(forReport report:Report) {
        if reportDVC == nil {
            reportDVC = storyboard!.instantiateViewControllerWithIdentifier("reportDetail") as? ReportDetailVC
        }

        let selectedNav = tabBarC?.viewControllers![(tabBarC?.selectedIndex)!] as! UINavigationController
        if let _ = selectedNav.presentedViewController as? SchoolDetailVC {
            selectedNav.dismissViewControllerAnimated(true, completion: nil)
            selectedNav.presentViewController(reportDVC!, animated: true) { () -> Void in
                self.reportDVC?.setup(withReport: report)
            }
        }else if selectedNav.presentedViewController == nil {
            selectedNav.presentViewController(reportDVC!, animated: true) { () -> Void in
                self.reportDVC?.setup(withReport: report)
            }
        }else{
            reportDVC?.setup(withReport: report)
        }

        tabBarC?.tabBar.hidden = true // can't animate this :(
    }

    func showSchoolDVC(forSchool school:School) {
        if schoolDVC == nil {
            schoolDVC = storyboard!.instantiateViewControllerWithIdentifier("schoolDetail") as? SchoolDetailVC
        }

        let selectedNav = tabBarC?.viewControllers![(tabBarC?.selectedIndex)!] as! UINavigationController

        if let _ = selectedNav.presentedViewController as? ReportDetailVC {
            selectedNav.dismissViewControllerAnimated(true, completion: nil)
            selectedNav.presentViewController(schoolDVC!, animated: true) { () -> Void in
                self.schoolDVC?.setup(withSchool: school)
            }
        }else if selectedNav.presentedViewController == nil {
            selectedNav.presentViewController(schoolDVC!, animated: true) { () -> Void in
                self.schoolDVC?.setup(withSchool: school)
            }
        }else{
            schoolDVC?.setup(withSchool: school)
        }

        tabBarC?.tabBar.hidden = true // can't UIView animate this :(
    }

    // MARK: MapVCDelegate

    func mapVC(mapVC: MapVC, showDetailVCForAnnotation annotation: MKAnnotation) {
        switch annotation {
        case is Report:
            showReportDVC(forReport: annotation as! Report)
            break

        case is School:
            showSchoolDVC(forSchool: annotation as! School)
            break

        default: break
        }
    }

    // MARK: CrimeFilterVCDelegate

    func crimeFilter(filterVC: CrimeFilterVC, didCommitFilterWithResult results: Array<Report>) {
        mapVC?.addReports(results)
    }

    // MARK: SchoolFilterVC Delegate

    func schoolFilterVC(filterVC: SchoolFilterVC, didCommitFilterWithResults results: Array<School>) {
        mapVC?.addSchools(results)
    }

    /*
    Color palete:   (City of chicago flag colors)
    red #FF0000
    sky blue #B3DDF2
    white
    */
}
