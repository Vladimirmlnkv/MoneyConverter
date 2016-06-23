//
//  BorderedButton.swift
//  Converter
//
//  Created by Владимир Мельников on 23/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor()
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
    }
}

