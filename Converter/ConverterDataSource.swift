//
//  ConverterDataSource.swift
//  Converter
//
//  Created by Владимир Мельников on 20/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import Foundation

struct ExchangeData {
    var baseCurrency: String
    var date: String
    var exchangeRates: [String: Double]
}

class ConverterDataSource {
    
    private let url = "http://api.fixer.io/latest?base=%@"
    private var exchangeData: ExchangeData?
    
    //MARK: - Public API
    
    func getExchangeRate(fromCurrency: String, toCurrency: String, success: (rate: Double) -> Void, failure: (error: ErrorType) -> Void){
        
        if let data = exchangeData, rate = data.exchangeRates[toCurrency] {
            let r = data.baseCurrency == fromCurrency ? rate : 1 / rate
            success(rate: r)
        } else {
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: String(format: url, fromCurrency))!, completionHandler: { data, response, error in
                if error == nil && data != nil {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                        if let rates = json["rates"] as? [String: Double], date = json["date"] as? String, base = json["base"] as? String {
                            self.exchangeData = ExchangeData(baseCurrency: base, date: date, exchangeRates: rates)
                            success(rate: self.exchangeData!.exchangeRates[toCurrency]!)
                        }
                    } catch {
                        failure(error: error)
                    }
                }
            }).resume()
        }
    }
}