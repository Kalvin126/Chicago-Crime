//
//  FilterTableVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/21/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class FilterTableVC: UITableViewController {

    var crimeTypesDropped:Bool

    var startTimeWindow:NSDate
    var endTimeWindow:NSDate

    @IBOutlet weak var startWindowCell: UITableViewCell!
    @IBOutlet weak var endWindowCell: UITableViewCell!

    required init?(coder aDecoder: NSCoder) {
        crimeTypesDropped = false

        // OK to hard code time since it is not being used for record
        startTimeWindow = NSDate().dateByAddingTimeInterval(-604800.0)
        endTimeWindow = NSDate()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startWindowCell.detailTextLabel?.text = stringForDate(startTimeWindow)
        endWindowCell.detailTextLabel?.text = stringForDate(endTimeWindow)
    }

    func tappedCrimeTypes(recognizer: UITapGestureRecognizer) {
        let button = (recognizer.view as! UITableViewCell).accessoryView as! UIButton

        crimeTypesDropped = !crimeTypesDropped
        UIView.animateWithDuration(0.3) { () -> Void in
            button.transform = CGAffineTransformMakeRotation((self.crimeTypesDropped ? -1 : 1)*CGFloat(M_PI / 2.0))
        }

        var crimeTypeCells:[NSIndexPath] = []
        for i in 0...PrimaryType.allRawValues.count-1 {
            let index = NSIndexPath(forRow: i, inSection: 1)

            crimeTypeCells += [index]
        }

        if crimeTypesDropped {
            tableView.insertRowsAtIndexPaths(crimeTypeCells, withRowAnimation: .Fade)
        }
        else {
            tableView.deleteRowsAtIndexPaths(crimeTypeCells, withRowAnimation: .Fade)
        }
    }

    func stringForDate(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, yyyy ha"

        return formatter.stringFromDate(date)
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 0 {
            let dateDialog = DatePickerDialog()
            dateDialog.show("Select a \((cell.textLabel?.text!.lowercaseString)!) time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: UIDatePickerMode.DateAndTime)
                { (date) -> Void in
                    cell.detailTextLabel?.text = "\(date)"

                    if cell.textLabel?.text == "Start" {
                        self.startTimeWindow = date
                        self.startWindowCell.detailTextLabel?.text = self.stringForDate(self.startTimeWindow)
                    }else{
                        self.endTimeWindow = date
                        self.endWindowCell.detailTextLabel?.text = self.stringForDate(self.endTimeWindow)

                    }
            }
        }
        else if indexPath.section == 1 {
            cell.accessoryType = cell.accessoryType == .None ? .Checkmark : .None
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "CrimeTypesView")
            cell.textLabel!.text = "Crime Types"

            let button = UIButton(type: .DetailDisclosure)
            let image = UIImage(named: "Detail Disclosure")
            button.setImage(image, forState: .Normal) // Need to make this aspect fit..
            button.imageView?.contentMode = .ScaleAspectFit // this does not work
            button.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 2.0))
            cell.accessoryView = button

            let tapRecog = UITapGestureRecognizer(target: self, action: "tappedCrimeTypes:")
            cell.addGestureRecognizer(tapRecog)

            return cell
        }

        return nil
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat(43)
        }

        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 43.0;
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return (crimeTypesDropped ? PrimaryType.allRawValues.count : 0)
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "crimeTypeCell")
            cell.textLabel?.text = PrimaryType.allRawValues[indexPath.row].capitalizedString

            return cell
        }

        return super.tableView(tableView, cellForRowAtIndexPath:indexPath)
    }
}
