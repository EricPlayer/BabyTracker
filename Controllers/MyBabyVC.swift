//
//  MyBabyVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/19.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class MyBabyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "mybabies")
    }
}
