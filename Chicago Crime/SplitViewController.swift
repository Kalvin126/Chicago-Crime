//
//  SplitViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

var gradLayer:CAGradientLayer?

class SplitViewController: UISplitViewController, MapVCDelegate, CrimeFilterDelegate, School1FilterDelegate {

    var mapVC:MapVC?
    var tabBarC:UITabBarController?

    weak var reportDVC:ReportDetailVC?
    weak var schoolDVC:SchoolDetailVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        gradLayer = CAGradientLayer()
        gradLayer!.colors = [UIColor.redColor().CGColor, UIColor.orangeColor().CGColor,UIColor.yellowColor().CGColor,UIColor.yellowColor().CGColor,UIColor.greenColor().CGColor]
        gradLayer!.locations = [0.0 ,0.3,0.65,0.68, 1.0]
        gradLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        
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
        UIView.animateWithDuration(Double((notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"]?.floatValue)!)) {
            () -> Void in
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
            self.schoolDVC?.school = school

            selectedNav.dismissViewControllerAnimated(true, completion: nil)
            selectedNav.presentViewController(schoolDVC!, animated: true, completion: nil)
        }else if selectedNav.presentedViewController == nil {
            self.schoolDVC?.school = school

            selectedNav.presentViewController(schoolDVC!, animated: true, completion: nil)
        }else{
            schoolDVC?.school = school
            schoolDVC?.setup()
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

    func crimeFilterVCDidClearFilter() {
        mapVC?.clearReports()
    }

    // MARK: SchoolFilterVC Delegate

    func schoolFilterVC(filterVC: SchoolFilterVC, didCommitFilterWithResults results: Array<School>) {
        mapVC?.schoolHeatMapAttrib = filterVC.tableVC!.heatmapAttribOn ? filterVC.tableVC?.selectedHeatmapAttrib : nil
        mapVC?.addSchools(results)
    }

    func schoolFilterVCDidClearFilter() {
        mapVC?.clearSchools()
    }

    func schoolFilterVC(filterVC: SchoolFilterVC, didChangeHeatMapAttrib attrib: SchoolAttribute) {
        mapVC?.schools.forEach({ (school) -> () in
            school.setAttribute(SelectedAttribute: attrib)
            
            let annot = mapVC?.mapView.viewForAnnotation(school)
            annot?.tintColor = school.tintColor()
        })
    }

    /*
    Color palete:   (City of chicago flag colors)
    red #FF0000
    sky blue #B3DDF2
    white
    */
}
