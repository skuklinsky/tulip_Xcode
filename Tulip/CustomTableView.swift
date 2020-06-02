//
//  CustomTableView.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/30/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class CustomTableView: UITableView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
