//
//  CustomLabelPollOptionCell.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/29/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class CustomTextFieldPollOptionCell: UITextField {
    
    var topInset: CGFloat = 8.0
    var bottomInset: CGFloat = 8.0
    var leftInset: CGFloat = 8.0
    var rightInset: CGFloat = 8.0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.backgroundColor = global.pollOptionTrackTintColor
    }
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
