//
//  ViewController.swift
//  Chicago Crime
//
//  Created by Kalvin Loc on 10/26/15.
//  Copyright © 2015 Kalvin Loc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Server.shared.getstuff()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

