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

    override func imageRectForContentRect(contentRect:CGRect) -> CGRect {
        var imageFrame = super.imageRectForContentRect(contentRect)
        imageFrame.origin.x = CGRectGetMaxX(super.titleRectForContentRect(contentRect)) - CGRectGetWidth(imageFrame)
        return imageFrame
    }
    
    override func titleRectForContentRect(contentRect:CGRect) -> CGRect {
        var titleFrame = super.titleRectForContentRect(contentRect)
        if (self.currentImage != nil) {
            titleFrame.origin.x = CGRectGetMinX(super.imageRectForContentRect(contentRect))
        }
        return titleFrame
    }
}
