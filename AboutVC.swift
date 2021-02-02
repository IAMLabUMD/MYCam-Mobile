//
//  AboutVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 10/19/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = Functions.createHeaderView(title: "ABOUT")
    }

}
