//
//  FilterVC.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 11/1/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import Foundation

import UIKit

protocol FilterDelegate {
    // this func is not yet finish in terms of purpose
    // the string should be replaced by what ever type we want to pass filter types through
    // i.e. the url appendage format so we can just append filterStr to the API url (...json?year=2014)
    func filter(filterVC: FilterVC, didCommitFilter filterStr: String)
}

class FilterVC: UIViewController {

    var delegate: FilterDelegate?

    override func viewDidLoad() {
        self.navigationItem.title = "Settings"
    }

}