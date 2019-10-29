//
//  AddByNameVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/19.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit
import Alamofire
import ProgressHUD

class AddByNameVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var babyNameTxt: UnderlineTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        babyNameTxt.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "addbyname")
        saveButton.setTitle(Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "save"), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func saveBabyName(_ sender: UIButton) {
        ProgressHUD.show()
        let apiUrl = ApiConfig.serverUrl + ApiConfig.addBabyByName
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        let params: Parameters = ["name": babyNameTxt.text!]
        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                let responseData = response.result.value as! [String: Any]
                let status = responseData["status"] as! String
                if status == "error" {
                    print("response error")
                    ProgressHUD.dismiss()
                    return
                }
                ProgressHUD.dismiss()
                Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_add_babyname_succed"), duration: 1)
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("failed to load babydata: \(error.localizedDescription)")
                ProgressHUD.dismiss()
                Toast().showToast(message: Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "msg_add_babyname_failed"), duration: 1)
            }
        }
    }
}
