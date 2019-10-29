//
//  SettingVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/18.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var multiLabel: UILabel!
    @IBOutlet weak var byNamelabel: UILabel!
    @IBOutlet weak var byKeyLabel: UILabel!
    @IBOutlet weak var premiumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "settings")
        self.navigationController?.navigationBar.backItem?.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "main")
        langLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "languages")
        volLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "volumes")
        multiLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "mybabies")
        byNamelabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "addbyname")
        byKeyLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "addbykey")
        premiumLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "buypremium")
    }
    
    @IBAction func onLanguage(_ sender: UIButton) {
        let langVC = storyboard?.instantiateViewController(withIdentifier: "LanguageVCID") as! LanguageVC
        navigationController?.pushViewController(langVC, animated: true)
    }
    
    @IBAction func onVolume(_ sender: UIButton) {
        let volVC = storyboard?.instantiateViewController(withIdentifier: "VolumeVCID") as! VolumeVC
        navigationController?.pushViewController(volVC, animated: true)
    }
    
    @IBAction func onMultiple(_ sender: UIButton) {
        let babiesVC = storyboard?.instantiateViewController(withIdentifier: "MyBabyVCID") as! MyBabyVC
        navigationController?.pushViewController(babiesVC, animated: true)
    }
    
    @IBAction func onAddByName(_ sender: UIButton) {
        let addNameVC = storyboard?.instantiateViewController(withIdentifier: "AddByNameVCID") as! AddByNameVC
        navigationController?.pushViewController(addNameVC, animated: true)
    }
    
    @IBAction func onAddByKey(_ sender: UIButton) {
        let addKeyVC = storyboard?.instantiateViewController(withIdentifier: "AddByKeyVCID") as! AddByKeyVC
        navigationController?.pushViewController(addKeyVC, animated: true)
    }
}
