//
//  SelectPollOptionsCell.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/29/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class SelectPollOptionsCell: UITableViewCell, UITextFieldDelegate {
    
    var tableView:UITableView? = nil
    var parentViewController:SelectPollOptionsViewController? = nil
    var rowIndex:Int? = nil
    
    @IBOutlet weak var choosePollOptionTextField: CustomTextFieldPollOptionCell!
    
    @IBAction func choosePollOptionTextFieldEditingDidEnd(_ sender: Any) {
    
    }
    
    func setCell(cellText:String, tableView:UITableView, parentViewController:SelectPollOptionsViewController, rowIndex:Int) {
        self.tableView = tableView
        self.parentViewController = parentViewController
        choosePollOptionTextField.text = cellText
        self.choosePollOptionTextField.delegate = self
        self.rowIndex = rowIndex
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parentViewController!.addPollOption(option:choosePollOptionTextField.text!)
        tableView?.reloadData()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func setEditable(isEditable:Bool) {
        choosePollOptionTextField.isUserInteractionEnabled = isEditable
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if (rowIndex == 0) {
            return
        }
        
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = .systemBackground

        if selected {
            choosePollOptionTextField.backgroundColor = global.pollOptionColorWhenSelectedAsOption
        } else {
            choosePollOptionTextField.backgroundColor = global.pollOptionTrackTintColor
        }
    }
    
}
