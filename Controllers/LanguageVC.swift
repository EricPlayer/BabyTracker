//
//  LanguageVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/18.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class LanguageVC: UIViewController {

    @IBOutlet weak var englishRadio: RadioButton!
    @IBOutlet weak var frenchRadio: RadioButton!
    @IBOutlet weak var germanyRadio: RadioButton!
    @IBOutlet weak var italianRadio: RadioButton!
    @IBOutlet weak var koreanRadio: RadioButton!
    @IBOutlet weak var engLabel: UILabel!
    @IBOutlet weak var fchLabel: UILabel!
    @IBOutlet weak var gerLabel: UILabel!
    @IBOutlet weak var ityLabel: UILabel!
    @IBOutlet weak var korLabel: UILabel!
    
    var lang = 0
    var radioGroup = [RadioButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lang = Instance.appDel.getLangType()
        radioGroup = [englishRadio, frenchRadio, germanyRadio, italianRadio, koreanRadio]
        
        for i in (0...radioGroup.count-1) {
            if i == lang {
                radioGroup[i].isChecked = true
                break
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "ok"), style: .done, target: self, action: #selector(changeLanguage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "languages")
        engLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "english")
        fchLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "french")
        gerLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "germany")
        ityLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "italian")
        korLabel.text = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "korean")
    }
    
    @objc func changeLanguage() {
        Instance.appDel.setLangType(value: lang)
        Instance.appDel.lang = lang
        let currentNavIdx = navigationController?.viewControllers.firstIndex(of: self)
        let previousViewController = navigationController?.viewControllers[currentNavIdx!-1]
        previousViewController?.navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "settings")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectEnglish(_ sender: RadioButton) {
        lang = 0
        for radio in radioGroup {
            if radio != englishRadio {
                radio.isChecked = false
            }
        }
    }
    
    @IBAction func selectFrench(_ sender: RadioButton) {
        lang = 1
        for radio in radioGroup {
            if radio != frenchRadio {
                radio.isChecked = false
            }
        }
    }
    
    @IBAction func selectGermany(_ sender: RadioButton) {
        lang = 2
        for radio in radioGroup {
            if radio != germanyRadio {
                radio.isChecked = false
            }
        }
    }
    
    @IBAction func selectItalian(_ sender: RadioButton) {
        lang = 3
        for radio in radioGroup {
            if radio != italianRadio {
                radio.isChecked = false
            }
        }
    }
    
    @IBAction func selectKorean(_ sender: RadioButton) {
        lang = 4
        for radio in radioGroup {
            if radio != koreanRadio {
                radio.isChecked = false
            }
        }
    }
}
