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
        return (convertFromButton.titleLabel?.text)!
    }
    
    private var converToTitle: String {
        return (converToButton.titleLabel?.text)!
    }
    
    @IBOutlet var activityView: ActivityView!
    
    @IBOutlet var swapButton: UIButton!
    
    private let dataSource = ConverterDataSource()
    private var currentRate: Double = 1
    
    private let keyboardAnimationTime = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityView()
        dataSource.loadExchangeRates({
            self.currentRate = self.dataSource.getExchangeRate(self.converFromTitle, toCurrency: self.converToTitle)
            self.hideActivityView()
        }) { error in
            print(error)
            self.hideActivityView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let topCenter = keyboardSize.height / 2
                let k = contentView!.bounds.origin.y - topCenter
                let correction = (k < 0) ? abs(k) : 0
                
                UIView.animateWithDuration(keyboardAnimationTime) {
                    self.contentViewConstraint.constant -= correction
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
    
    private func enableUI(enabled: Bool) {
        convertFromButton.enabled = enabled
        converToButton.enabled = enabled
        convertFromTextField.enabled = enabled
        swapButton.enabled = enabled
        convertFromTextField.enabled = enabled
        if enabled {
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
        dispatch_async(dispatch_get_main_queue()) {
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
        if let d = Double(convertFromTextField.text!) {
            convertToTextField.text = String(format: "%.2f",  d * currentRate)
        } else {
            convertToTextField.text = ""
        }
    }
    
    //MARK: - Actions
    
    @IBAction func reverseButtonAction(sender: AnyObject) {
        swapButtonTitles(converFromTitle, title2: converToTitle)
        currentRate = dataSource.getExchangeRate(converFromTitle, toCurrency: converToTitle)
        updateTextField()
    }
    
    @IBAction func textFieldTextChangedAction(sender: AnyObject) {
        updateTextField()
    }
    
}

extension ConverterViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let hasDot = textField.text!.containsString(".")
        let notDigits = NSCharacterSet.decimalDigitCharacterSet()
        var shouldChange = false
        if let _ = string.rangeOfCharacterFromSet(notDigits) {
            shouldChange = true
        } else if string == "" {
            shouldChange = true
        } else if string == "." && !hasDot {
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
