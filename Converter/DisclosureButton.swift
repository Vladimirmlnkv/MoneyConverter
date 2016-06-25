//
//  DisclosureButton.swift
//  Converter
//
//  Created by Владимир Мельников on 23/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit

@IBDesignable
class DisclosureButton: UIButton {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        transform = CGAffineTransformMakeScale(-1.0, 1.0);
        titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
}
