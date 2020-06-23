//
//  CustomButton.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 6/22/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    var tintedClearImage: UIImage?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        //self.borderStyle = UITextField.BorderStyle.roundedRect
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2.0
        let borderColor:UIColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = .white
    }
}

