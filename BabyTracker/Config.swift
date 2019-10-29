//
//  Config.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/19.
//  Copyright © 2019 fatih. All rights reserved.
//

import Foundation
import UIKit

struct Instance {
    static let appDel =  UIApplication.shared.delegate as! AppDelegate
}

struct ApiConfig {
    
    static let serverUrl: String = "https://unilica.com/api/"
    
    //MARK:>>>>>> endpoints
    
    //Authentication
    static let addParent: String = "parent/add"
    static let addBabyByName: String = "baby/addByName"
    static let addBabyByKey = "baby/addByKey"
    static let babyList = "baby/list"
    static let removeBaby = "baby/remove"
    static let activityList = "activity/list"
    static let addActivity = "activity/add"
    static let removeActivity = "activity/remove"
    static let updateActivity = "activity/update"
}
