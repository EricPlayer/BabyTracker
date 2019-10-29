//
//  MainVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit
import Alamofire
import ProgressHUD
import GoogleMobileAds

class MainVC: UIViewController {

    @IBOutlet weak var spinPrev: UIButton!
    @IBOutlet weak var spinNext: UIButton!
    @IBOutlet weak var babyNameView: UIView!
    @IBOutlet weak var babyNameLabel: UILabel!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var diaperButton: UIButton!
    @IBOutlet weak var breastButton: UIButton!
    @IBOutlet weak var bottleButton: UIButton!
    @IBOutlet weak var searchButtion: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var transparentView = UIView()
    let editTimeView = EditTimeView()
    let editSleepView = EditSleepView()
    let editFoodView = EditFoodView()
    let editBottleView = EditBottleView()
    
    var babyList = [[String: Any]]()
    var activityList = [[String: Any]]()
    var curBabyIndex = 0
    var curBabyKey = ""
    var curSleeping = false, curLBreasting = false, curRBreasting = false
    var timer: Timer?
    var curSleepCell: SleepTVCell?
    var curStartTime = Date()
    var volumes = "ml"
    
    let dateformatter = DateFormatter()
    let screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius = sleepButton.frame.size.width / 2
        
        sleepButton.layer.cornerRadius = radius
        foodButton.layer.cornerRadius = radius
        diaperButton.layer.cornerRadius = radius
        breastButton.layer.cornerRadius = radius
        bottleButton.layer.cornerRadius = radius
        
        searchButtion.layer.borderColor = UIColor(red: 0, green: 153/256, blue: 1, alpha: 1).cgColor
        searchButtion.layer.borderWidth = 1
        
        babyNameView.layer.borderWidth = 1
        babyNameView.layer.cornerRadius = 5
        babyNameView.layer.borderColor = UIColor.lightGray.cgColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bannerView.adUnitID = "ca-app-pub-1541822078505482/1001384119"
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.backgroundColor = .lightGray
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "main")
        searchButtion.setTitle(Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "search"), for: .normal)
        volumes = (Instance.appDel.getVolumeType() == 0) ? " ml" : " fl oz"
        
        tableView.register(UINib(nibName: "SleepTVCell", bundle: nil), forCellReuseIdentifier: "SleepTVCellID")
        tableView.register(UINib(nibName: "FoodTVCell", bundle: nil), forCellReuseIdentifier: "FoodTVCellID")
        tableView.register(UINib(nibName: "DiaperTVCell", bundle: nil), forCellReuseIdentifier: "DiaperTVCellID")
        tableView.register(UINib(nibName: "BreastTVCell", bundle: nil), forCellReuseIdentifier: "BreastTVCellID")
        tableView.register(UINib(nibName: "BottleTVCell", bundle: nil), forCellReuseIdentifier: "BottleTVCellID")
        
        loadAllBabies()
    }
    
    func loadAllBabies() {
        ProgressHUD.show()
        let apiUrl = ApiConfig.serverUrl + ApiConfig.babyList
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        Alamofire.request(apiUrl, method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
                case .success:
                    let responseData = response.result.value as! [String: Any]
                    let status = responseData["status"] as! String
                    if status == "error" {
                        print("response error")
                        ProgressHUD.dismiss()
                        Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_load_baby_failed"), duration: 1)
                        return
                    }
                    self.babyList = responseData["babyList"] as! [[String: Any]]
                    if self.babyList.count > 0 {
                        let baby = self.babyList[self.curBabyIndex]
                        self.dateformatter.dateFormat = "yyyy-MM-dd"
                        let curDate = self.dateformatter.string(from: self.datePicker.date)
                        self.babyNameLabel.text = (baby["name"] as! String)
                        self.curBabyKey = baby["baby_key"] as! String
                        self.loadAllActivities(babyKey: baby["baby_key"] as! String, curDate: curDate)
                    } else {
                        self.babyNameLabel.text = "--none--"
                        self.babyNameLabel.textColor = UIColor.lightGray
                        ProgressHUD.dismiss()
                }
                case .failure(let error):
                    print("failed to load babydata: \(error.localizedDescription)")
                    ProgressHUD.dismiss()
                    Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_load_baby_failed"), duration: 1)
                    return
            }
        }
    }

    func loadAllActivities(babyKey: String, curDate: String) {
        let apiUrl = ApiConfig.serverUrl + ApiConfig.activityList
        let params: Parameters = ["baby_key": babyKey, "activity_date": curDate]
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]

        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
                case .success:
                    let responseData = response.result.value as! [String: Any]
                    let status = responseData["status"] as! String
                    if status == "error" {
                        Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_load_activity_failed"), duration: 1)
                        return
                    }
                    self.activityList = responseData["activityList"] as! [[String: Any]]
                    self.tableView.reloadData()
                    ProgressHUD.dismiss()
                   
                    for aSleep in Instance.appDel.babySleepTimers {
                        if aSleep.getBabyKey() == self.curBabyKey && aSleep.getDate() == curDate {
                            self.curStartTime = aSleep.getStartTime()
                            self.curSleeping = true
                            guard self.curSleepCell != nil else { return }
                            guard self.timer == nil else { return }
                            self.timer = Timer.scheduledTimer(
                                timeInterval: 1.0,
                                target      : self,
                                selector    : #selector(self.onSleepTimer),
                                userInfo    : nil,
                                repeats     : true)
                            break
                        }
                    }
                case .failure(let error):
                    print("failed to load activity data: \(error.localizedDescription)")
                    Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_load_activity_failed"), duration: 1)
                    return
            }
            ProgressHUD.dismiss()
        }
    }
    
    func onAddActivity(actionType: Int) {
        if !self.validActivity() {
            Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "warning_add_activity"), duration: 1)
            return
        }
        ProgressHUD.show()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let actDate = dateformatter.string(from: Date())
        dateformatter.dateFormat = "hh:mm:ss"
        let actTime = dateformatter.string(from: Date())
        
        let apiUrl = ApiConfig.serverUrl + ApiConfig.addActivity
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        let params: Parameters = ["baby_key": curBabyKey, "activity_type_id": actionType, "activity_date": actDate, "activity_time": actTime, "duration_in_min_1": "0", "duration_in_min_2": "0", "volume_in_mililiter": "0", "is_poop": "Y", "is_wet": "N", "description": ""]
        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                let responseData = response.result.value as! [String: Any]
                let status = responseData["status"] as! String
                if status == "error" {
                    ProgressHUD.dismiss()
                    Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_add_activity_failed"), duration: 1)
                    return
                }
                self.loadAllActivities(babyKey: self.curBabyKey, curDate: actDate)
            case .failure(let error):
                print("failed to load activity data: \(error.localizedDescription)")
                ProgressHUD.dismiss()
                Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_add_activity_failed"), duration: 1)
                return
            }
        }
    }
    
    func onDeleteActivity(actId: String) {
        ProgressHUD.show()
        let apiUrl = ApiConfig.serverUrl + ApiConfig.removeActivity
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        let params: Parameters = ["activity_id": actId, "baby_key": curBabyKey]
        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                let responseData = response.result.value as! [String: Any]
                let status = responseData["status"] as! String
                if status == "error" {
                    ProgressHUD.dismiss()
                    Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_remove_activity_failed"), duration: 1)
                    return
                }
                self.dateformatter.dateFormat = "yyyy-MM-dd"
                let curdate = self.dateformatter.string(from: Date())
                self.loadAllActivities(babyKey: self.curBabyKey, curDate: curdate)
            case .failure(let error):
                print("failed to delete activity: \(error.localizedDescription)")
                ProgressHUD.dismiss()
                Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_remove_activity_failed"), duration: 1)
                return
            }
        }
    }
    
    func onUpdateActivity(actId: Int, key: String, value: String) {
        ProgressHUD.show()
//        let url: String = ApiConfig.serverUrl + ApiConfig.updateActivity
//        let apiUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                let parentKey = Instance.appDel.parentKey
        let apiUrl = ApiConfig.serverUrl + ApiConfig.updateActivity
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        var params: Parameters = [:]
        if key == "time" {
            params = ["baby_key": curBabyKey, "activity_time": value, "activity_id": actId]
        } else if key == "duration" {
            params = ["baby_key": curBabyKey, "duration_in_min_1": value, "activity_id": actId]
        } else if key == "food" {
            params = ["baby_key": curBabyKey, "description": value, "activity_id": actId]
        } else if key == "diaper" {
            if value == "Y" {
                params = ["baby_key": curBabyKey, "is_poop": "Y", "is_wet": "N", "activity_id": actId]
            } else {
                params = ["baby_key": curBabyKey, "is_poop": "N", "is_wet": "Y", "activity_id": actId]
            }
        } else if key == "bottle" {
            params = ["baby_key": curBabyKey, "volume_in_mililiter": value, "activity_id": actId]
        } else if key == "lbreast" {
            params = ["baby_key": curBabyKey, "duration_in_min_1": value, "activity_id": actId]
        } else if key == "rbreast" {
            params = ["baby_key": curBabyKey, "duration_in_min_2": value, "activity_id": actId]
        }
        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
                case .success:
                    let responseData = response.result.value as! [String: Any]
                    let status = responseData["status"] as! String
                    if status == "error" {
                        ProgressHUD.dismiss()
                        Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_update_activity_failed"), duration: 1)
                        return
                    }
                    if key == "duration" {
                        self.curSleeping = false
                    }
                    if key == "lbreast" {
                        self.curLBreasting = false
                    }
                    if key == "rbreast" {
                        self.curRBreasting = false
                    }
                    self.dateformatter.dateFormat = "yyyy-MM-dd"
                    let curdate = self.dateformatter.string(from: Date())
                    self.loadAllActivities(babyKey: self.curBabyKey, curDate: curdate)
                case .failure(let error):
                    print("failed to update activity: \(error.localizedDescription)")
                    ProgressHUD.dismiss()
                    Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_update_activity_failed"), duration: 1)
                    return
            }
        }
    }
    
    func validActivity() -> Bool {
        if curSleeping || curLBreasting || curRBreasting {
            return false
        }
        return true
    }
    
    @objc func onEditSleep(sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        editSleepView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 172)
        editSleepView.confirmButton.tag = sender.tag
        editSleepView.durationStepper.addTarget(self, action: #selector(onSleepStepper), for: .touchUpInside)
        editSleepView.confirmButton.addTarget(self, action: #selector(onUpdateSleep), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.editSleepView)
            self.editSleepView.frame = CGRect(x: 0, y: self.screenSize.height - self.editSleepView.frame.height, width: self.screenSize.width, height: self.editSleepView.frame.height)
        }, completion: nil)
    }
    
    @objc func onEditTime(sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        editTimeView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 262)
        editTimeView.confirmButton.tag = sender.tag
        editTimeView.timePicker.setDate(Date(), animated: true)
        editTimeView.confirmButton.addTarget(self, action: #selector(onUpdateTime), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.editTimeView)
            self.editTimeView.frame = CGRect(x: 0, y: self.screenSize.height - self.editTimeView.frame.height, width: self.screenSize.width, height: self.editTimeView.frame.height)
        }, completion: nil)
    }
    
    @objc func onEditBottle(sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        editBottleView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 172)
        editBottleView.confirmButton.tag = sender.tag
        editBottleView.quantityStepper.addTarget(self, action: #selector(onBottleStepper), for: .touchUpInside)
        editBottleView.confirmButton.addTarget(self, action: #selector(onUpdateBottle), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.editBottleView)
            self.editBottleView.frame = CGRect(x: 0, y: self.screenSize.height - self.editBottleView.frame.height, width: self.screenSize.width, height: self.editBottleView.frame.height)
        }, completion: nil)
        
    }
    
    @objc func onStartStopSleep(sender: UIButton) {
        if !curSleeping {
            sender.setImage(UIImage(named: "icon_stop"), for: .normal)
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            let oneSleep = SleepModel(babyKey: curBabyKey, startTime: Date(), date: curDate)
            Instance.appDel.babySleepTimers.append(oneSleep)
            guard curSleepCell != nil else { return }
            guard timer == nil else { return }
            curStartTime = Date()
            timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target      : self,
                selector    : #selector(onSleepTimer),
                userInfo    : nil,
                repeats     : true)
            curSleeping = true
        } else {
            onStopSleepTimer()
            curSleepCell = nil
            var duration = ""
            var startTime = Date()
            var index = 0
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            for aSleep in Instance.appDel.babySleepTimers {
                if aSleep.getBabyKey() == self.curBabyKey && aSleep.getDate() == curDate {
                    startTime = aSleep.getStartTime()
                    break
                }
                index += 1
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            duration = String(Int(elapsedTime / 60))
            Instance.appDel.babySleepTimers.remove(at: index)
            onUpdateActivity(actId: sender.tag, key: "duration", value: duration)
        }
    }
    
    @objc func onStartStopLBreast(sender: UIButton) {
        if !curLBreasting {
            sender.setImage(UIImage(named: "icon_stop"), for: .normal)
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            let oneBreast = SleepModel(babyKey: curBabyKey, startTime: Date(), date: curDate)
            Instance.appDel.babyLBreastTimers.append(oneBreast)
            curLBreasting = true
        } else {
            var duration = ""
            var startTime = Date()
            var index = 0
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            for aBreast in Instance.appDel.babyLBreastTimers {
                if aBreast.getBabyKey() == self.curBabyKey && aBreast.getDate() == curDate {
                    startTime = aBreast.getStartTime()
                    break
                }
                index += 1
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            duration = String(Int(elapsedTime / 60))
            Instance.appDel.babyLBreastTimers.remove(at: index)
            onUpdateActivity(actId: sender.tag, key: "lbreast", value: duration)
        }
    }
    
    @objc func onStartStopRBreast(sender: UIButton) {
        if !curRBreasting {
            sender.setImage(UIImage(named: "icon_stop"), for: .normal)
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            let oneBreast = SleepModel(babyKey: curBabyKey, startTime: Date(), date: curDate)
            Instance.appDel.babyRBreastTimers.append(oneBreast)
            curRBreasting = true
        } else {
            var duration = ""
            var startTime = Date()
            var index = 0
            dateformatter.dateFormat = "yyyy-MM-dd"
            let curDate = dateformatter.string(from: datePicker.date)
            for aBreast in Instance.appDel.babyRBreastTimers {
                if aBreast.getBabyKey() == self.curBabyKey && aBreast.getDate() == curDate {
                    startTime = aBreast.getStartTime()
                    break
                }
                index += 1
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            duration = String(Int(elapsedTime / 60))
            Instance.appDel.babyRBreastTimers.remove(at: index)
            onUpdateActivity(actId: sender.tag, key: "rbreast", value: duration)
        }
    }
    
    @objc func onStopRBreast(sender: UIButton) {
    }
    
    @objc func onSleepTimer() {
        let elapsedTime = Date().timeIntervalSince(curStartTime)
        let minutes = Int(elapsedTime / 60)
        self.curSleepCell!.durationLabel.text = String(minutes) + ((minutes > 1) ? " mins" : " min")
    }
    
    func onStopSleepTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func onTapTransparent() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.removeFromSuperview()
            self.editSleepView.removeFromSuperview()
            self.editTimeView.removeFromSuperview()
            self.editFoodView.removeFromSuperview()
            self.editBottleView.removeFromSuperview()
        }, completion: nil)
    }
    
    @objc func onSleepStepper(sender: UIStepper) {
        self.editSleepView.durationTxt.text = String(Int(sender.value))
    }
    
    @objc func onBottleStepper(sender: UIStepper) {
        self.editBottleView.quantityTxt.text = String(Int(sender.value))
    }
    
    @objc func onUpdateSleep(sender: UIButton) {
        let duration = self.editSleepView.durationTxt.text!
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.editSleepView.removeFromSuperview()
        }, completion: nil)
        onUpdateActivity(actId: sender.tag, key: "duration", value: duration)
    }
    
    @objc func onUpdateBottle(sender: UIButton) {
        let quantity = self.editBottleView.quantityTxt.text!
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.editBottleView.removeFromSuperview()
        }, completion: nil)
        onUpdateActivity(actId: sender.tag, key: "bottle", value: quantity)
    }
    
    @objc func onUpdateFood(sender: UIButton) {
        let foods = self.editFoodView.foodText.text!
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.editFoodView.removeFromSuperview()
        }, completion: nil)
        onUpdateActivity(actId: sender.tag, key: "food", value: foods)
    }
    
    @objc func onUpdateTime(sender: UIButton) {
        dateformatter.dateFormat = "hh:mm:ss"
        let time = dateformatter.string(from: self.editTimeView.timePicker.date)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.editTimeView.removeFromSuperview()
        }, completion: nil)
        onUpdateActivity(actId: sender.tag, key: "time", value: time)
    }
    
    @objc func onEditFood(sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        editFoodView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 210)
        editFoodView.confirmButton.tag = sender.tag
        editFoodView.foodText.text = ""
        editFoodView.confirmButton.addTarget(self, action: #selector(onUpdateFood), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            window?.addSubview(self.editFoodView)
            self.editFoodView.frame = CGRect(x: 0, y: 0, width: self.screenSize.width, height: self.editFoodView.frame.height)
        }, completion: nil)
    }
    
    @objc func onToggleDiaper(sender: UISwitch) {
        var result = "Y"
        if !sender.isOn {
            result = "N"
        }
        onUpdateActivity(actId: sender.tag, key: "diaper", value: result)
    }
    
    @IBAction func onPrevBaby(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        ProgressHUD.show()
        if curBabyIndex == 0 {
            curBabyIndex = babyList.count - 1
        } else {
            curBabyIndex -= 1
        }
        let baby = self.babyList[self.curBabyIndex]
        babyNameLabel.text = baby["name"] as? String
        curBabyKey = baby["baby_key"] as! String
        dateformatter.dateFormat = "yyyy-MM-dd"
        let curDate = dateformatter.string(from: self.datePicker.date)
        onStopSleepTimer()
        self.loadAllActivities(babyKey: curBabyKey, curDate: curDate)
    }
    
    @IBAction func onNextBaby(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        ProgressHUD.show()
        if curBabyIndex == babyList.count-1 {
            curBabyIndex = 0
        } else {
            curBabyIndex += 1
        }
        let baby = self.babyList[self.curBabyIndex]
        babyNameLabel.text = baby["name"] as? String
        curBabyKey = baby["baby_key"] as! String
        dateformatter.dateFormat = "yyyy-MM-dd"
        let curDate = dateformatter.string(from: self.datePicker.date)
        onStopSleepTimer()
        self.loadAllActivities(babyKey: curBabyKey, curDate: curDate)
    }
    
    @IBAction func onSleep(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        onAddActivity(actionType: 1)
    }
    
    @IBAction func onFood(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        onAddActivity(actionType: 2)
    }
    
    @IBAction func onDiaper(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        onAddActivity(actionType: 3)
    }
    
    @IBAction func onBreast(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        onAddActivity(actionType: 4)
    }
    
    @IBAction func onBottle(_ sender: UIButton) {
        if babyList.count == 0 {
            return
        }
        onAddActivity(actionType: 5)
    }
    
    @IBAction func onNavToSetting(_ sender: UIButton) {
        let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingVCID") as! SettingVC
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func onSearchActivity(_ sender: UIButton) {
        ProgressHUD.show()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let curDate = dateformatter.string(from: self.datePicker.date)
        self.loadAllActivities(babyKey: curBabyKey, curDate: curDate)
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let anActivity = activityList[indexPath.row]
        let actType = Int(anActivity["ACTIVITY_TYPE_ID"] as! String)
        switch actType {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SleepTVCellID", for: indexPath) as! SleepTVCell
                let time = anActivity["ACTIVITY_TIME"] as! String
                cell.timeLabel.text = Utils.subString(string: time, to: 5)
                let duration = anActivity["DURATION_IN_MIN_1"] as! String
                cell.durationLabel.text = duration + " min"
                cell.actId.text = anActivity["ID"] as? String
                cell.timeButton.tag = Int(anActivity["ID"] as! String)!
                cell.timeControlBtn.tag = Int(anActivity["ID"] as! String)!
                cell.DurationBtn.tag = Int(anActivity["ID"] as! String)!
                cell.tag = 1
                if duration != "0" {
                    cell.timeControlBtn.isHidden = true
                    cell.timeControlBtn.isEnabled = false
                } else {
                    self.curSleepCell = cell
                    cell.timeControlBtn.isHidden = false
                    cell.timeControlBtn.isEnabled = true
                    if !curSleeping {
                        cell.timeControlBtn.setImage(UIImage(named: "icon_play")! as UIImage, for: .normal)
                    } else {
                        cell.timeControlBtn.setImage(UIImage(named: "icon_stop")! as UIImage, for: .normal)
//                        cell.timeControlBtn.addTarget(self, action: #selector(onStopSleep), for: .touchUpInside)
                    }
                }
                cell.timeControlBtn.addTarget(self, action: #selector(onStartStopSleep), for: .touchUpInside)
                cell.timeButton.addTarget(self, action: #selector(onEditTime), for: .touchUpInside)
                cell.DurationBtn.addTarget(self, action: #selector(onEditSleep), for: .touchUpInside)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTVCellID", for: indexPath) as! FoodTVCell
                let time = anActivity["ACTIVITY_TIME"] as! String
                cell.timeLabel.text = Utils.subString(string: time, to: 5)
                cell.timeButton.tag = Int(anActivity["ID"] as! String)!
                cell.foodLabel.text = anActivity["DESCRIPTION"] as? String
                cell.actId.text = anActivity["ID"] as? String
                cell.foodButton.tag = Int(anActivity["ID"] as! String)!
                cell.tag = 2
                cell.timeButton.addTarget(self, action: #selector(onEditTime), for: .touchUpInside)
                cell.foodButton.addTarget(self, action: #selector(onEditFood), for: .touchUpInside)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DiaperTVCellID", for: indexPath) as! DiaperTVCell
                let time = anActivity["ACTIVITY_TIME"] as! String
                cell.timeLabel.text = Utils.subString(string: time, to: 5)
                cell.timeButton.tag = Int(anActivity["ID"] as! String)!
                cell.pooToggle.tag = Int(anActivity["ID"] as! String)!
                let poo = anActivity["IS_POOP"] as? String
                let isPoo = (poo == "Y") ? true : false
                cell.pooToggle.isOn = isPoo
                cell.actId.text = anActivity["ID"] as? String
                cell.tag = 3
                cell.pooToggle.addTarget(self, action: #selector(onToggleDiaper), for: .touchUpInside)
                cell.timeButton.addTarget(self, action: #selector(onEditTime), for: .touchUpInside)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BreastTVCellID", for: indexPath) as! BreastTVCell
                let time = anActivity["ACTIVITY_TIME"] as! String
                cell.timeLabel.text = Utils.subString(string: time, to: 5)
                cell.timeButton.tag = Int(anActivity["ID"] as! String)!
                let duration1 = anActivity["DURATION_IN_MIN_1"] as? String
                let duration2 = anActivity["DURATION_IN_MIN_2"] as? String
                cell.bLeftLabel.text = "L: " + duration1! + " mins"
                cell.bRightLabel.text = "R: " + duration2! + " mins"
                cell.actId.text = anActivity["ID"] as? String
                cell.bLeftButton.tag = Int(anActivity["ID"] as! String)!
                cell.bRightButton.tag = Int(anActivity["ID"] as! String)!
                if duration1 != "0" {
                    cell.bLeftView.isHidden = true
                    cell.bLeftButton.isEnabled = false
                    cell.bLeftLabel.isHidden = false
                } else {
                    cell.bLeftView.isHidden = false
                    cell.bLeftButton.isEnabled = true
                    cell.bLeftLabel.isHidden = true
                    if !curLBreasting {
                        cell.bLeftButton.setImage(UIImage(named: "icon_play")! as UIImage, for: .normal)
                    } else {
                        cell.bLeftButton.setImage(UIImage(named: "icon_stop")! as UIImage, for: .normal)
//                        cell.bLeftButton.addTarget(self, action: #selector(onStopLBreast), for: .touchUpInside)
                    }
                }
                if duration2 != "0" {
                    cell.bRightView.isHidden = true
                    cell.bRightButton.isEnabled = false
                    cell.bRightLabel.isHidden = false
                } else {
                    cell.bRightView.isHidden = false
                    cell.bRightButton.isEnabled = true
                    cell.bRightLabel.isHidden = true
                    if !curRBreasting {
                        cell.bRightButton.setImage(UIImage(named: "icon_play")! as UIImage, for: .normal)
                    } else {
                        cell.bRightButton.setImage(UIImage(named: "icon_stop")! as UIImage, for: .normal)
//                        cell.bRightButton.addTarget(self, action: #selector(onStopRBreast), for: .touchUpInside)
                    }
                }
                cell.tag = 4
                cell.bLeftButton.addTarget(self, action: #selector(onStartStopLBreast), for: .touchUpInside)
                cell.bRightButton.addTarget(self, action: #selector(onStartStopRBreast), for: .touchUpInside)
                cell.timeButton.addTarget(self, action: #selector(onEditTime), for: .touchUpInside)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BottleTVCellID", for: indexPath) as! BottleTVCell
                let time = anActivity["ACTIVITY_TIME"] as! String
                cell.timeLabel.text = Utils.subString(string: time, to: 5)
                cell.timeButton.tag = Int(anActivity["ID"] as! String)!
                cell.quantityLabel.text = anActivity["VOLUME_IN_MILILITER"] as! String + self.volumes
                cell.actId.text = anActivity["ID"] as? String
                cell.bottleButton.tag = Int(anActivity["ID"] as! String)!
                cell.tag = 5
                cell.timeButton.addTarget(self, action: #selector(onEditTime), for: .touchUpInside)
                cell.bottleButton.addTarget(self, action: #selector(onEditBottle), for: .touchUpInside)
                return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "delete"), handler: { (action , indexPath) -> Void in
            var activityId = ""
            switch tableView.cellForRow(at: indexPath)!.tag {
                case 1:
                    let cell = tableView.cellForRow(at: indexPath) as! SleepTVCell
                    activityId = cell.actId.text!
                    break
                case 2:
                    let cell = tableView.cellForRow(at: indexPath) as! FoodTVCell
                    activityId = cell.actId.text!
                    break
                case 3:
                    let cell = tableView.cellForRow(at: indexPath) as! DiaperTVCell
                    activityId = cell.actId.text!
                    break
                case 4:
                    let cell = tableView.cellForRow(at: indexPath) as! BreastTVCell
                    activityId = cell.actId.text!
                    break
                default:
                    let cell = tableView.cellForRow(at: indexPath) as! BottleTVCell
                    activityId = cell.actId.text!
                    break
            }
            self.onDeleteActivity(actId: activityId)
        })
        
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
}
