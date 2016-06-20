//
//  ConverterViewController.swift
//  Converter
//
//  Created by Владимир Мельников on 20/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit

class ConverterViewController: UIViewController {

    @IBOutlet var headerView: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewContraint: NSLayoutConstraint!
    
    @IBOutlet var convertFromTextField: UITextField!
    @IBOutlet var convertFromLabel: UILabel!
    
    @IBOutlet var convertToTextField: UITextField!
    @IBOutlet var converToLabel: UILabel!
    
    private let dataSource = ConverterDataSource()
    private var currentRate: Double = 1
    
    private let keyboardAnimationTime = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.loadExchangeRates({
            self.currentRate = self.dataSource.getExchangeRate(self.convertFromLabel.text!, toCurrency: self.converToLabel.text!)
        }) { error in
            print(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        convertFromTextField.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let topCenter = keyboardSize.height / 2
                let k = contentView!.bounds.origin.y - topCenter + headerView.bounds.size.height
                let correction = (k < 0) ? abs(k) : 0
                
                UIView.animateWithDuration(keyboardAnimationTime) {
                    self.contentViewContraint.constant -= correction
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(keyboardAnimationTime) {
            self.contentViewContraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func swapLabelTexts(label1: UILabel, label2: UILabel) {
        let tmp = label1.text
        label1.text = label2.text
        label2.text = tmp
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
        swapLabelTexts(convertFromLabel!, label2: converToLabel!)
        currentRate = dataSource.getExchangeRate(convertFromLabel.text!, toCurrency: converToLabel.text!)
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
