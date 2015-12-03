//
//  SchoolFilterTableVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class SchoolFilterTableVC: UITableViewController {
    var schoolLevelsDropped:Bool
    var selectedSchoolLevels:[SchoolLevel] = []

    required init?(coder aDecoder: NSCoder) {
        schoolLevelsDropped = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tappedSchoolLevels(recognizer: UITapGestureRecognizer) {
        let button = recognizer.view!.viewWithTag(3) as! UIButton

        schoolLevelsDropped = !schoolLevelsDropped;
        UIView.animateWithDuration(0.3) { () -> Void in
            button.transform = CGAffineTransformMakeRotation((self.schoolLevelsDropped ? 1 : -1)*CGFloat(M_PI / 2.0))
        }

        var schoolLevelCells:[NSIndexPath] = []
        for i in 0...SchoolLevel.allRawValues.count-1 {
            let index = NSIndexPath(forRow: i, inSection: 0)

            schoolLevelCells += [index]
        }

        if schoolLevelsDropped {
            tableView.insertRowsAtIndexPaths(schoolLevelCells, withRowAnimation: .Fade)
        }
        else {
            tableView.deleteRowsAtIndexPaths(schoolLevelCells, withRowAnimation: .Fade)
        }
    }
    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 0 {    // School Levels
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark

                selectedSchoolLevels += [(SchoolLevel.valueForRawValue((cell.textLabel?.text)!))!]
            }else{
                cell.accessoryType = .None

                let typeIndex = selectedSchoolLevels.indexOf((SchoolLevel.valueForRawValue((cell.textLabel?.text)!))!)
                selectedSchoolLevels.removeAtIndex(typeIndex!)
            }
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = storyboard?.instantiateViewControllerWithIdentifier("filterVCHeader").view
        let label = headerView?.viewWithTag(1) as! UILabel
        let querySwitch = headerView?.viewWithTag(2) as! UISwitch
        let discButton = headerView?.viewWithTag(3) as! UIButton
        headerView!.backgroundColor = UIColor(white: 2.9/3.0, alpha: 1.0)

        label.textColor = UIColor.darkTextColor()
        label.font = UIFont.boldSystemFontOfSize(17.0)

        if section == 0 {
            label.text = "School Levels"
            discButton.transform = CGAffineTransformMakeRotation((self.schoolLevelsDropped ? 1 : -1)*CGFloat(M_PI / 2.0))

            let tapRecog = UITapGestureRecognizer(target: self, action: "tappedSchoolLevels:")
            headerView!.addGestureRecognizer(tapRecog)

            return headerView

        }

        return nil
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0;
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (schoolLevelsDropped ? SchoolLevel.allRawValues.count : 0)
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "schoolTypeCell")
            cell.textLabel?.text = SchoolLevel.allRawValues[indexPath.row]
            
            if selectedSchoolLevels.contains(SchoolLevel.allValues[indexPath.row]) {
                cell.accessoryType = .Checkmark
            }
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath:indexPath)
    }
}
