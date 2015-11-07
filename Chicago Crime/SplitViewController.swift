//
//  SplitViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

class SplitViewController: UISplitViewController, SettingsDelegate {

    var mapVC:MapVC?
    var filterVC:FilterVC?
    var settingVC:SettingsVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapVC = self.viewControllers[0] as? MapVC
        let tabBarC = self.viewControllers[1] as! UITabBarController
        for navVC in tabBarC.viewControllers! {
            let vc = (navVC as! UINavigationController).viewControllers[0]
            switch vc {
            case vc as FilterVC:
                filterVC = vc as? FilterVC
                break
            case vc as SettingsVC:
                settingVC = vc as? SettingsVC
                break
            default:
                break
            }
        }
        
        settingVC?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        let screenWidth = self.view.frame.width
        let kMasterViewWidth:CGFloat = screenWidth - (screenWidth)/3

        let masterViewController = self.viewControllers[0]
        let detailViewController = self.viewControllers[1]

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
            
            masterViewController.view.setNeedsLayout()
            detailViewController.view.setNeedsLayout()
        }
    }

    // MARK: Settings Delegate

    func settings(settingsVC: SettingsVC, didChangeMapType mapType: MKMapType) {
        mapVC?.mapView.mapType = mapType
    }

}
