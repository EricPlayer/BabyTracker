//
//  AddByKeyVC.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/19.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit
import Alamofire

class AddByKeyVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var babyKeyTxt: UnderlineTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        babyKeyTxt.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "addbykey")
        saveButton.setTitle(Instance.appDel.getLocalization(type: Instance.appDel.lang, key: "save"), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func saveBabyKey(_ sender: UIButton) {
        let apiUrl = ApiConfig.serverUrl + ApiConfig.addBabyByKey
        let headers: HTTPHeaders = ["parent_key": Instance.appDel.parentKey]
        let params: Parameters = ["name": babyKeyTxt.text!]
        Alamofire.request(apiUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                let responseData = response.result.value as! [String: Any]
                let status = responseData["status"] as! String
                if status == "error" {
                    print("response error")
                    return
                }
                Toast().showToast(message: "Success to save baby key.", duration: 1)
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("failed to load babydata: \(error.localizedDescription)")
            }
        }
    }
}
