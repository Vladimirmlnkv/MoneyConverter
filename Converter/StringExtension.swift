//
//  StringExtension.swift
//  Converter
//
//  Created by Владимир Мельников on 23/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import Foundation

extension String {
    var doubleValue: Double? {
        var value: Double?
        let nf = NSNumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.numberFromString(self) {
            value = result.doubleValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.numberFromString(self) {
                value = result.doubleValue
            }
        }
        return value
    }
}