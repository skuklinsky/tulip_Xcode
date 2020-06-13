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
    
    func setCell(cellText:String, tableView:UITableView, parentViewController:SelectPollOptionsViewController, rowIndex:Int) {
        self.tableView = tableView
        self.parentViewController = parentViewController
        choosePollOptionTextField.text = cellText
        self.choosePollOptionTextField.delegate = self
        self.rowIndex = rowIndex
        self.selectionStyle = .none
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parentViewController!.addPollOption(option:choosePollOptionTextField.text!)
        
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows
        var newSelectedIndexPaths:[IndexPath] = [IndexPath(row: 1, section: 0)]
        
        if let forcedSelectedIndexPaths = selectedIndexPaths {
            for selectedIndexPath in forcedSelectedIndexPaths {
                newSelectedIndexPaths.append(IndexPath(row: selectedIndexPath.row + 1, section: 0))
            }
        }
        
        tableView?.reloadData()
        
        for newSelectedIndexPath in newSelectedIndexPaths {
            tableView?.selectRow(at: newSelectedIndexPath, animated: false, scrollPosition: .none)
        }
        
        // set height of table view
        let pollOptionsTableViewHeight = parentViewController!.pollOptionsTableViewRowHeight * CGFloat(global.categoryToOptions[parentViewController!.postCategory]!.count + 1)
        if (pollOptionsTableViewHeight > parentViewController!.maxPollOptionsTableViewHeight) {
            // want to show x.5 rows (so user knows to scroll), showing max number while still under height maximum
            var height = (1.5 * parentViewController!.pollOptionsTableViewRowHeight) + 4.0 // add 4 bc halfway will appear to be less than half bc top margin of 8
            while (height < parentViewController!.maxPollOptionsTableViewHeight) {
                height += parentViewController!.pollOptionsTableViewRowHeight
            }
            parentViewController!.tableViewHeightConstraint.constant = height - parentViewController!.pollOptionsTableViewRowHeight
        } else {
            parentViewController!.tableViewHeightConstraint.constant = pollOptionsTableViewHeight
        }
        // height setting complete
        
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
        
        if selected {
            choosePollOptionTextField.backgroundColor = global.pollOptionColorWhenSelectedAsOption
        } else {
            choosePollOptionTextField.backgroundColor = global.pollOptionTrackTintColor
        }
    }
    
}
