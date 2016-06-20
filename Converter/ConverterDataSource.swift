//
//  ConverterDataSource.swift
//  Converter
//
//  Created by Владимир Мельников on 20/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import Foundation

class ConverterDataSource {
    
    private let url = "https://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.xchange+where+pair+=+%22USDRUB,EURRUB%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
    private var exchangeRates = [String: Double]()
    
    //MARK: - Public API
    
    func loadExchangeRates(success: () -> Void, failure: (error: ErrorType) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!, completionHandler: { data, response, error in
            if error == nil && data != nil {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
                    if let query = json["query"], results = query["results"], rate = results!["rate"] {
                        let rateArray = rate as! [AnyObject]
                        for value in rateArray {
                            let v = value as! [String: String]
                            let name  = v["Name"]!
                            let rate = Double(v["Rate"]!)
                            self.exchangeRates[name] = rate
                        }
                    }
                    success()
                } catch {
                    // Something went wrong
                    failure(error: error)
                }
            }
        }).resume()
    }
    
    func getExchangeRate(fromCurrency: String, toCurrency: String) -> Double {
        var exchangeRate: Double = 1
        var key = "\(fromCurrency)/\(toCurrency)"
        if let rate = exchangeRates[key] {
            exchangeRate = rate
        } else {
            key = "\(toCurrency)/\(fromCurrency)"
            if let rate = exchangeRates[key] {
                exchangeRate = 1 / rate
            }
        }
        return exchangeRate
    }
}