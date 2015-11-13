//
//  SplitViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/31/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

class SplitViewController: UISplitViewController, FilterDelegate, SettingsDelegate {

    var mapVC:MapVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapVC = self.viewControllers[0] as? MapVC
        let tabBarC = self.viewControllers[1] as! UITabBarController
        for navVC in tabBarC.viewControllers! {
            let vc = (navVC as! UINavigationController).viewControllers[0]
            switch vc {
            case is FilterVC:
                (vc as? FilterVC)?.delegate = self;
                break
            case is SettingsVC:
                (vc as? SettingsVC)?.delegate = self;
                break
            default:
                break
            }
        }
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

    // MARK: Filter VC Delegate

    func filter(filterVC: FilterVC, didCommitFilter results: Array<Report>) {
        dispatch_async(dispatch_get_main_queue(), {                                         // We don't want to do view animation changes in the background
            self.mapVC?.mapView.removeAnnotations((self.mapVC?.mapView.annotations)!)
            self.mapVC?.mapView.addAnnotations(results)
        })

    }

    // MARK: Settings VC Delegate

    func settings(settingsVC: SettingsVC, didChangeMapType mapType: MKMapType) {
        mapVC?.mapView.mapType = mapType
    }

}
