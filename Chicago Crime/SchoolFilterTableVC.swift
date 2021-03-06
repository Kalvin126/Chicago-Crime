//
//  SchoolFilterTableVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 12/2/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class SchoolFilterTableVC: UITableViewController {
    var schoolLevelsDropped:Bool = true
    var selectedSchoolLevels:[SchoolLevel] = []
    var levelFilterOn:Bool = true

    var heatmapAttribDropped: Bool = true
    var selectedHeatmapAttrib: SchoolAttribute?
    var heatmapAttribOn: Bool = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedSchoolLevels += [SchoolLevel.HighSchool]
    }

    func tappedSchoolLevels(recognizer: UITapGestureRecognizer) {
        let button = recognizer.view!.viewWithTag(3) as! UIButton

        schoolLevelsDropped = !schoolLevelsDropped;
        UIView.animateWithDuration(0.3) { () -> Void in
            button.transform = CGAffineTransformMakeRotation((self.schoolLevelsDropped ? 1 : -1)*CGFloat(M_PI / 2.0))
        }

        let schoolLevelCells = (0...SchoolLevel.allRawValues.count-1).map{ NSIndexPath(forRow: $0, inSection: 0) }

        if schoolLevelsDropped {
            tableView.insertRowsAtIndexPaths(schoolLevelCells, withRowAnimation: .Fade)
        }
        else {
            tableView.deleteRowsAtIndexPaths(schoolLevelCells, withRowAnimation: .Fade)
        }
    }

    func tappedHeatMapAttrib(recognizer: UITapGestureRecognizer) {
        let button = recognizer.view!.viewWithTag(3) as! UIButton

        heatmapAttribDropped = !heatmapAttribDropped
        UIView.animateWithDuration(0.3) { () -> Void in
            button.transform = CGAffineTransformMakeRotation((self.heatmapAttribDropped ? 1 : -1)*CGFloat(M_PI / 2.0))
        }

        let heatmapAttribCells = (0...SchoolAttribute.allRawValues.count-1).map{ NSIndexPath(forRow: $0, inSection: 1) }

        if heatmapAttribDropped {
            tableView.insertRowsAtIndexPaths(heatmapAttribCells, withRowAnimation: .Fade)
        }
        else {
            tableView.deleteRowsAtIndexPaths(heatmapAttribCells, withRowAnimation: .Fade)
        }
    }

    func toggledLevelFilter(sender: UISwitch!) {
        levelFilterOn = sender.on
    }

    func toggledHeatMapAttrib(sender: UISwitch!) {
        heatmapAttribOn = sender.on
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 0 {    // School Levels
            if cell.accessoryType == .None {
                selectedSchoolLevels.removeAll()
                selectedSchoolLevels += [(SchoolLevel(rawValue:(cell.textLabel?.text)!))!]

                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            }
        }
        else if indexPath.section == 1 {    // HeatMap Attribs
            if cell.accessoryType == .None {
                selectedHeatmapAttrib = SchoolAttribute(rawValue:(cell.textLabel!.text)!)

                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)

                let schoolFilterVC = parentViewController as! SchoolFilterVC
                schoolFilterVC.delegate?.schoolFilterVC(schoolFilterVC, didChangeHeatMapAttrib: selectedHeatmapAttrib!)
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
            discButton.transform = CGAffineTransformMakeRotation((schoolLevelsDropped ? 1 : -1)*CGFloat(M_PI / 2.0))

            let tapRecog = UITapGestureRecognizer(target: self, action: "tappedSchoolLevels:")
            headerView!.addGestureRecognizer(tapRecog)

            querySwitch.addTarget(self, action: "toggledLevelFilter:", forControlEvents: .TouchUpInside)

            return headerView
        }
        else if section == 1 {
            label.text = "Heat Map Attribute"
            discButton.transform = CGAffineTransformMakeRotation((heatmapAttribDropped ? 1 : -1)*CGFloat(M_PI / 2.0))

            let tapRecog = UITapGestureRecognizer(target: self, action: "tappedHeatMapAttrib:")
            headerView!.addGestureRecognizer(tapRecog)

            querySwitch.addTarget(self, action: "toggledHeatMapAttrib:", forControlEvents: .TouchUpInside)

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
        else if section == 1 {
            return (heatmapAttribDropped ? SchoolAttribute.allRawValues.count : 0)
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
        else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "heatmapAttribCell")
            cell.textLabel?.text = SchoolAttribute.allRawValues[indexPath.row]

            if selectedHeatmapAttrib == SchoolAttribute.allValues[indexPath.row] {
                cell.accessoryType = .Checkmark
            }

            return cell
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath:indexPath)
    }
}
