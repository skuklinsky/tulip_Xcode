//
//  SelectPollOptionsCell.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/29/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class SelectPollOptionsCell: UITableViewCell {
    
    @IBOutlet weak var choosePollOptionCreatePost: CustomLabelPollOptionCell!
    @IBOutlet weak var pollOptionLabel: CustomLabelPollOptionCell!
    
    func setCell(cellText:String) {
        choosePollOptionCreatePost.text = cellText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = .systemBackground

        if selected {
            pollOptionLabel.backgroundColor = global.pollOptionColorWhenSelectedAsOption
        } else {
            pollOptionLabel.backgroundColor = global.pollOptionTrackTintColor
        }
    }
    
}
