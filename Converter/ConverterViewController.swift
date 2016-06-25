//
//  ConverterViewController.swift
//  Converter
//
//  Created by Владимир Мельников on 20/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit

class ConverterViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var convertFromTextField: UITextField!
    @IBOutlet var convertFromButton: DisclosureButton!
    
    @IBOutlet var convertToTextField: UITextField!
    @IBOutlet var converToButton: DisclosureButton!
    
    private var converFromTitle: String {
        return convertFromButton.titleForState(.Normal)!
    }
    
    private var converToTitle: String {
        return converToButton.titleForState(.Normal)!
    }
    
    @IBOutlet var activityView: ActivityView!
    
    @IBOutlet var swapButton: UIButton!
    
    private var dataSource: ConverterDataSource!
    private var currentRate: Double = 1
    
    private let keyboardAnimationTime = 0.5
    
    private lazy var numberFormater: NSNumberFormatter = {
        let nf = NSNumberFormatter()
        nf.numberStyle = .CurrencyAccountingStyle
        nf.currencySymbol = ""
        nf.roundingMode = .RoundHalfUp
        nf.maximumFractionDigits = 2
        
        return nf
    }()
    
    private let segueID = "currencyTableViewSegue"
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        dataSource = ConverterDataSource(receiver: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getExchangeRate()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let topCenter = keyboardSize.height / 2
                let k = contentView!.bounds.origin.y - topCenter
                let correction = (k < 0) ? abs(k) : 0
                
                UIView.animateWithDuration(keyboardAnimationTime) {
                    self.contentViewConstraint.constant = -correction
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(keyboardAnimationTime) {
            self.contentViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func getExchangeRate() {
        dataSource.getExchangeRate(converFromTitle, toCurrency: converToTitle)
    }
    
    private func enableUI(enabled: Bool) {
        convertFromButton.userInteractionEnabled = enabled
        converToButton.userInteractionEnabled = enabled
        swapButton.userInteractionEnabled = enabled
        if enabled && !convertFromTextField.isFirstResponder() {
            convertFromTextField.becomeFirstResponder()
        }
    }
    
    private func showActivityView() {
        enableUI(false)
        UIView.animateWithDuration(0.3, animations: {
            self.activityView.hidden = false
            self.activityView.alpha = 1.0
        })
    }
    
    private func hideActivityView() {
        if !activityView.hidden {
            UIView.animateWithDuration(0.3, animations: {
                self.activityView.alpha = 0
            }) { b in
                self.enableUI(true)
                self.activityView.hidden = true
            }
        }
    }
    
    private func swapButtonTitles(title1: String, title2: String) {
        convertFromButton.setTitle(title2, forState: .Normal)
        converToButton.setTitle(title1, forState: .Normal)
    }
    
    private func updateTextField() {
        if let d = self.convertFromTextField.text!.doubleValue {
            self.convertToTextField.text = self.numberFormater.stringFromNumber(NSNumber(double: d * self.currentRate))
        } else {
            self.convertToTextField.text = ""
        }
    }
    
    //MARK: - Actions
    
    @IBAction func currencyButtonAction(sender: AnyObject) {
        performSegueWithIdentifier(segueID, sender: sender)
    }
    
    @IBAction func reverseButtonAction(sender: AnyObject) {
        swapButtonTitles(converFromTitle, title2: converToTitle)
        getExchangeRate()
    }
    
    @IBAction func textFieldTextChangedAction(sender: AnyObject) {
        updateTextField()
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let currencyVC = segue.destinationViewController as! CurrencyTableViewController
        currencyVC.currencyDelegate = self
        if sender as! UIButton == convertFromButton {
            currencyVC.convertDestination = .From
            currencyVC.currentSelectedCurrency = converFromTitle
        } else {
            currencyVC.convertDestination = .To
            currencyVC.currentSelectedCurrency = converToTitle
        }
    }
    
}

extension ConverterViewController: ConverterDataSourceReceiver {
    
    func willLoadExchangeRate() {
        showActivityView()
    }
    
    func didLoadExchangeRate(rate: Double) {
        currentRate = rate
        self.hideActivityView()
        self.updateTextField()
    }
    
    func cantLoadData(error: ErrorType) {
        print(error)
        hideActivityView()
    }
}

extension ConverterViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let hasSeparator = textField.text!.containsString(numberFormater.decimalSeparator)
        let notDigits = NSCharacterSet.decimalDigitCharacterSet()
        var shouldChange = false
        if let _ = string.rangeOfCharacterFromSet(notDigits) {
            shouldChange = true
        } else if string == "" {
            shouldChange = true
        } else if string == numberFormater.decimalSeparator && !hasSeparator {
            if range.location == 0 {
                textField.text = "0"
            }
            shouldChange = true
        }
        return shouldChange
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        convertFromTextField.resignFirstResponder()
        return true
    }
}

extension ConverterViewController: CurrencyTableViewControllerDelegate {
    
    func didSelectCurrency(currency: String, forConvertDestination: ConvertDestination) {
        if forConvertDestination == .To {
            converToButton.setTitle(currency, forState: .Normal)
        } else {
            convertFromButton.setTitle(currency, forState: .Normal)
        }
    }

}
