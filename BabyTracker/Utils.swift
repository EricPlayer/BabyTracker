//
//  Utils.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/21.
//  Copyright © 2019 fatih. All rights reserved.
//

import Foundation

class Utils {
    static func subString(string: String, to: Int) -> String {
        let index = string.index(string.startIndex, offsetBy: to)
        let substring = string.prefix(upTo: index)
        return String(substring)
    }
}
