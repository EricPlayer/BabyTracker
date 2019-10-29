//
//  VolumeVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/18.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class VolumeVC: UIViewController {

    @IBOutlet weak var millimeterRadio: RadioButton!
    @IBOutlet weak var ounceRadio: RadioButton!
    
    var volume = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volume = Instance.appDel.getVolumeType()
        
        if volume == 0 {
            millimeterRadio.isChecked = true
        } else {
            ounceRadio.isChecked = true
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "ok"), style: .done, target: self, action: #selector(changeVolume))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "volumes")
    }
    
    @objc func changeVolume() {
        Instance.appDel.setVolumeType(value: volume)
        Instance.appDel.volume = volume
        let currentNavIdx = navigationController?.viewControllers.firstIndex(of: self)
        let previousViewController = navigationController?.viewControllers[currentNavIdx!-1]
        previousViewController?.navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "settings")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectMillimeter(_ sender: RadioButton) {
        volume = 0
        ounceRadio.isChecked = false
    }
    
    @IBAction func selectOunce(_ sender: RadioButton) {
        volume = 1
        millimeterRadio.isChecked = false
    }
}
