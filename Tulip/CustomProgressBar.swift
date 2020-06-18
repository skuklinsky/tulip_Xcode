//
//  CustomProgressBar.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/27/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class CustomProgressBar: UIProgressView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.layer.cornerRadius = 14.0
        self.layer.masksToBounds = true
        self.trackTintColor = global.pollOptionTrackTintColor
        
        // Set the rounded edge for the inner bar
        self.layer.sublayers![1].cornerRadius = 14
        self.subviews[1].clipsToBounds = true
    }
}
