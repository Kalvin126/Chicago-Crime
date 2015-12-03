//
//  SplitViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

class SplitViewController: UISplitViewController, MKMapViewDelegate, FilterDelegate, School1FilterDelegate {

    var mapVC:MapVC?
    var tabBarC:UITabBarController?

    weak var reportDVC:ReportDetailVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapVC = self.viewControllers[0] as? MapVC
        mapVC?.mapView.delegate = self

        tabBarC = self.viewControllers[1] as? UITabBarController

        for navVC in tabBarC!.viewControllers! {
            let vc = (navVC as! UINavigationController).viewControllers[0]
            switch vc {
            case is FilterVC:
                (vc as? FilterVC)?.delegate = self;
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
        UIView.animateWithDuration(Double((notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"]?.floatValue)!)) { () -> Void in
            self.tabBarC?.tabBar.frame = frame
        }
    }

    func showReportDVC(forReport report:Report) {
        if reportDVC == nil {
            reportDVC = storyboard!.instantiateViewControllerWithIdentifier("reportDetail") as? ReportDetailVC

            let selectedNav = tabBarC?.viewControllers![(tabBarC?.selectedIndex)!] as! UINavigationController
            selectedNav.presentViewController(reportDVC!, animated: true, completion: nil)
        }

        reportDVC?.setup(withReport: report)

        tabBarC?.tabBar.hidden = true // can't animate this :(
    }

    // MARK: Filter VC Delegate

    func filter(filterVC: FilterVC, didCommitFilter results: Array<Report>) {
        mapVC?.mapView.removeAnnotations((mapVC?.mapView.annotations)!)
        mapVC?.mapView.addAnnotations(results)
    }

    // MARK: SchoolFilterVC Delegate

//    func settings(settingsVC: SettingsVC, didChangeMapType mapType: MKMapType) {
//        mapVC?.mapView.mapType = mapType
//    }
    /*
    Color palete:   (City of chicago flag colors)
    red #FF0000
    sky blue #B3DDF2
    white
    */

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, didSelectAnnotationView annotView: MKAnnotationView) {
        showReportDVC(forReport: (annotView.annotation as! Report))

        annotView.highlighted = true
    }
}
