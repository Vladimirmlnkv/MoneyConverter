//
//  ActivityView.swift
//  Converter
//
//  Created by Владимир Мельников on 21/06/16.
//  Copyright © 2016 Владимир Мельников. All rights reserved.
//

import UIKit


class ActivityView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        layer.cornerRadius = 0.5 * layer.bounds.height
    }

    private func loadFromXib() {
        NSBundle.mainBundle().loadNibNamed("ActivityView", owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
}
