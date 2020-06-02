//
//  DropDownCell.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/27/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class DropDownCell: UITableViewCell {
    
    @IBOutlet weak var dropDownOption: UILabel!
    @IBOutlet weak var dropDownCheckMark: UILabel!
    
    @IBOutlet weak var chooseCategoryCreatePost: UILabel!
    @IBOutlet weak var chooseCategoryCheckMarkCreatePost: UILabel!
    
    @IBOutlet weak var ageGenderOptionLabel: UILabel!
    @IBOutlet weak var ageGenderCheckMark: UILabel!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.designSetup()
    }
    
    func designSetup() {
        //self.backgroundColor = global.dropDownCellBackgroundColor
    }
    
    func setCell(cellText:String, isChecked:Bool) {
        dropDownOption.text = cellText
        if (isChecked) {
            dropDownCheckMark.text = "✓"
        } else {
            dropDownCheckMark.text = ""
        }
    }
    
    func setCellChooseCategoryCreatePost(cellText:String, isChecked:Bool) {
        chooseCategoryCreatePost.text = cellText
        if (isChecked) {
            chooseCategoryCheckMarkCreatePost.text = "✓"
        } else {
            chooseCategoryCheckMarkCreatePost.text = ""
        }
    }
    
    func setCellAgeGenderOption(cellText:String, isChecked:Bool) {
        ageGenderOptionLabel.text = cellText
        if (isChecked) {
            ageGenderCheckMark.text = "✓"
        } else {
            ageGenderCheckMark.text = ""
        }
    }
}
