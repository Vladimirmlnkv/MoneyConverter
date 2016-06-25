//
//  CurrencyTableViewController.swift
//  Converter
//
//  Created by Владимир Мельников on 25/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit

enum ConvertDestination: String {
    case To = "to"
    case From = "from"
}

protocol CurrencyTableViewControllerDelegate {
    func didSelectCurrency(currency: String, forConvertDestination: ConvertDestination)
}

class CurrencyTableViewController: UITableViewController {
    
    @IBOutlet var headerLabel: UILabel!
    private let headerTemplate = "Select currency to conver %@"
    
    private let currencies = ["AUD", "BGN", "BRL" ,"CAD", "CHF", "CNY", "CZK", "DKK", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR",
                              "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]
    
    var currencyDelegate: CurrencyTableViewControllerDelegate!
    var convertDestination: ConvertDestination!
    var currentSelectedCurrency: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = String(format: headerTemplate, convertDestination.rawValue)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "Currencies"
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let text = currencies[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrencyCell")!
        cell.textLabel?.text = text
        if text == currentSelectedCurrency {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        currentSelectedCurrency = currencies[indexPath.row]
        tableView.reloadData()
        navigationController?.popToRootViewControllerAnimated(true)
        currencyDelegate.didSelectCurrency(currentSelectedCurrency, forConvertDestination: convertDestination)
    }
}
