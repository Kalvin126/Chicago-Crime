//
//  SettingsVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import MapKit
import UIKit

protocol SettingsDelegate {
    func settings(settingsVC:SettingsVC, didChangeMapType mapType: MKMapType)
}

class SettingsVC: UITableViewController {
    var delegate: SettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        // this is so clean lol
        tableView.visibleCells.forEach { $0.accessoryType = .None }
        cell?.accessoryType = .Checkmark

        if indexPath.section == 0 {

        } else if indexPath.section == 1 {
            let mapTypeStr:String = (cell?.textLabel?.text)!

            switch mapTypeStr {
            case "Standard":
                delegate?.settings(self, didChangeMapType: .Standard)
                break
            case "Satellite":
                 delegate?.settings(self, didChangeMapType: .Hybrid)
                break
            default:
                break
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}