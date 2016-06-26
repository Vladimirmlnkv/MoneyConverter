//
//  ConverterDataSource.swift
//  Converter
//
//  Created by Владимир Мельников on 20/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import Foundation

private struct ExchangeData {
    var baseCurrency: String
    var date: String
    var exchangeRates: [String : Double]
}

protocol ConverterDataSourceReceiver: class {
    func willLoadExchangeRate()
    func didLoadExchangeRate(rate: Double)
    func cantLoadData(error: ErrorType)
}

class ConverterDataSource {
    
    private let url = "http://api.fixer.io/latest?base=%@"
    private var exchangeData: ExchangeData?
    private weak var receiver: ConverterDataSourceReceiver?
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let defaultsKey = "defaultConfigs"
    private let convertFromKey = "convertFrom"
    private let convertToKey = "convertTo"
    
    init(receiver: ConverterDataSourceReceiver) {
        self.receiver = receiver
    }
    
    //MARK: - Public API
    
    func getExchangeRate(fromCurrency: String, toCurrency: String) {
        
        let defaults = [convertFromKey: fromCurrency,
                    convertToKey: toCurrency]
        self.userDefaults.setObject(defaults, forKey: defaultsKey)
        
        if let data = exchangeData where data.baseCurrency == fromCurrency || data.baseCurrency == toCurrency {
            if let rate = data.exchangeRates[toCurrency] ?? data.exchangeRates[fromCurrency] {
                let r = data.baseCurrency == fromCurrency ? rate : 1 / rate
                receiver?.didLoadExchangeRate(r)
            }
        } else {
            receiver?.willLoadExchangeRate()
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: String(format: url, fromCurrency))!, completionHandler: { data, response, error in
                if error == nil && data != nil {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                        if let rates = json["rates"] as? [String: Double], date = json["date"] as? String, base = json["base"] as? String {
                            self.exchangeData = ExchangeData(baseCurrency: base, date: date, exchangeRates: rates)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.receiver?.didLoadExchangeRate(self.exchangeData!.exchangeRates[toCurrency]!)
                            }
                        }
                    } catch {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.receiver?.cantLoadData(error)
                        }
                    }
                }
            }).resume()
        }
    }
    
    func loadConfig() -> (convertFrom: String, convertTo: String)? {
        var result: (String, String)?
        if let defaults = userDefaults.objectForKey(defaultsKey) as? [String: String] {
            if let conertFrom = defaults[convertFromKey], convertTo = defaults[convertToKey] {
                result = (conertFrom, convertTo)
            }
        }

        return result
    }
}