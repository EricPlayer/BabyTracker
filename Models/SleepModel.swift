//
//  SleepModel.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 fatih. All rights reserved.
//

import Foundation

class SleepModel {
    var key: String
    var start: Date
    var date: String
    
    init() {
        self.key = ""
        self.start = Date()
        self.date = ""
    }
    
    init(babyKey: String, startTime: Date, date: String) {
        self.key = babyKey
        self.start = startTime
        self.date = date
    }
    
    func getBabyKey() -> String {
        return key
    }
    
    func getStartTime() -> Date {
        return start
    }
    
    func getDate() -> String {
        return date
    }
}
