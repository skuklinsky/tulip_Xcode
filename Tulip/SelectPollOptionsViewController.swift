//
//  SelectPollOptionsViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/29/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit

class SelectPollOptionsViewController: UIViewController {

    @IBOutlet weak var pollOptionsTableView: UITableView!
    @IBOutlet weak var dropDownTableView: CustomTableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reviewAndPostLabel: UILabel!
    @IBOutlet weak var yourAgeButtonOutlet: UIButton!
    @IBOutlet weak var yourGenderButtonOutlet: UIButton!
    
    @IBOutlet weak var grayBackgroundView: UIView!
    
    var currentlyCheckedYourAgeIndex:Int = 0
    var currentlyCheckedYourGenderIndex:Int = 0
    
    var pollOptionsAdded:[String] = []
    
    let pollOptionsTableViewRowHeight:CGFloat = 43.0
    let maxPollOptionsTableViewHeight:CGFloat = 300.0
    let dropDownTableViewRowHeight:CGFloat = 46.5
    
    var postCategory = ""
    var postTitle = ""
    var postMessage = ""
    
    var currentDropDown = "yourAge"
    
    func addPollOption(option:String) {
        pollOptionsAdded.insert(option, at:0)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        let numberPollOptionsSelected:Int = pollOptionsTableView.indexPathsForSelectedRows?.count ?? 0
        if (numberPollOptionsSelected < global.minNumberPollOptions) {
            global.showSimpleAlert(title: "You must select at least \(global.minNumberPollOptions) poll options", message: "", vc: self)
        } else if ((currentlyCheckedYourAgeIndex == 0 && currentlyCheckedYourGenderIndex != 0) || (currentlyCheckedYourAgeIndex != 0 && currentlyCheckedYourGenderIndex == 0)) {
            global.showSimpleAlert(title: "Selecting age and gender is optional, but you can't select one and not the other.", message: "", vc: self)
        } else {
            let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "ReviewPostViewController") as! ReviewPostViewController
            
            var votingOptions:[String] = []
            for indexPath in pollOptionsTableView.indexPathsForSelectedRows! {
                if (indexPath.row <= pollOptionsAdded.count) {
                    votingOptions.append(pollOptionsAdded[indexPath.row - 1])
                } else {
                    votingOptions.append(global.categoryToOptions[postCategory]![indexPath.row - pollOptionsAdded.count - 1])
                }
            }
            let correspondingVotes = votingOptions.map({_ in 0})
            let ageRange = (currentlyCheckedYourAgeIndex != 0) ? global.yourAgeOptions[currentlyCheckedYourAgeIndex]: nil
            let gender = (currentlyCheckedYourGenderIndex != 0) ? global.yourGenderOptions[currentlyCheckedYourGenderIndex]: nil
            
            let post:Poast = Poast(title: postTitle, message: postMessage, votingOptions: votingOptions, correspondingVotes: correspondingVotes, category: postCategory, age: ageRange, gender: gender, posterUsername: global.username!, timePostSubmitted: nil)
            newScreen.post = post
            
            newScreen.modalPresentationStyle = .fullScreen
            self.present(newScreen, animated: true, completion: nil)
        }
    }
    
    @IBAction func yourAgeAction(_ sender: Any) {
        
        if (!dropDownTableView.isHidden) {
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0
        } else {
            dropDownTableViewHeightConstraint.constant = dropDownTableViewRowHeight * 8.5
            currentDropDown = "yourAge"
            dropDownTableView.reloadData()
            dropDownTableView.isHidden = false
            grayBackgroundView.alpha = global.grayBackgroundAlpha
        }
    }
    
    @IBAction func yourGenderAction(_ sender: Any) {

        if (!dropDownTableView.isHidden) {
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0
        } else {
            dropDownTableViewHeightConstraint.constant = dropDownTableViewRowHeight * CGFloat(global.yourGenderOptions.count)
            currentDropDown = "yourGender"
            dropDownTableView.reloadData()
            dropDownTableView.isHidden = false
            grayBackgroundView.alpha = global.grayBackgroundAlpha
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pollOptionsTableView.dataSource = self
        pollOptionsTableView.delegate = self
        dropDownTableView.dataSource = self
        dropDownTableView.delegate = self
        
        pollOptionsTableView.separatorStyle = .none
        
        currentlyCheckedYourAgeIndex = UserDefaults.standard.integer(forKey: "storedAgeIndex") // zero if nothing stored
        currentlyCheckedYourGenderIndex = UserDefaults.standard.integer(forKey: "storedGenderIndex") // zero if nothing stored
        
        let ageTitle = currentlyCheckedYourAgeIndex == 0 ? "Your Age ▼": global.yourAgeOptions[currentlyCheckedYourAgeIndex] + " ▼"
        yourAgeButtonOutlet.setTitle(ageTitle, for: .normal)
        let genderTitle = currentlyCheckedYourGenderIndex == 0 ? "Your Gender ▼": global.yourGenderOptions[currentlyCheckedYourGenderIndex] + " ▼"
        yourGenderButtonOutlet.setTitle(genderTitle, for: .normal)
        
        // set height of table view
        let pollOptionsTableViewHeight = pollOptionsTableViewRowHeight * CGFloat(global.categoryToOptions[postCategory]!.count + 1)
        if (pollOptionsTableViewHeight > maxPollOptionsTableViewHeight) {
            // want to show x.5 rows (so user knows to scroll), showing max number while still under height maximum
            var height = (1.5 * pollOptionsTableViewRowHeight) + 4.0 // add 4 bc halfway will appear to be less than half bc top margin of 8
            while (height < maxPollOptionsTableViewHeight) {
                height += pollOptionsTableViewRowHeight
            }
            tableViewHeightConstraint.constant = height - pollOptionsTableViewRowHeight
        } else {
            tableViewHeightConstraint.constant = pollOptionsTableViewHeight
        }
        // height setting complete
        
        let reviewAndPostGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reviewAndPostLabelAction))
        reviewAndPostLabel.addGestureRecognizer(reviewAndPostGestureRecognizer)
        
        let clickedBackgroundGesture = UITapGestureRecognizer(target: self, action: #selector(clickedBackgroundAction))
        grayBackgroundView.addGestureRecognizer(clickedBackgroundGesture)
    }
    
    //Action
    @objc func reviewAndPostLabelAction() {
        nextButtonAction(self)
    }
    
    //Action
    @objc func clickedBackgroundAction() {
        dropDownTableView.isHidden = true
        grayBackgroundView.alpha = 0
    }

}

extension SelectPollOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == pollOptionsTableView) {
            return global.categoryToOptions[postCategory]!.count + pollOptionsAdded.count + 1
        } else if (tableView == dropDownTableView) {
            if (currentDropDown == "yourAge") {
                return global.yourAgeOptions.count
            } else if (currentDropDown == "yourGender") {
                return global.yourGenderOptions.count
            } else {
                return -1
            }
        } else {
            return -1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == pollOptionsTableView) {
            let cell:SelectPollOptionsCell = pollOptionsTableView.dequeueReusableCell(withIdentifier: "SelectPollOptionsCell") as! SelectPollOptionsCell
            
            var name:String? = nil
            if (indexPath.row == 0) {
                name = "Add poll option"
            } else if (indexPath.row < pollOptionsAdded.count + 1) {
                name = pollOptionsAdded[indexPath.row - 1]
            } else {
                name = global.categoryToOptions[postCategory]![indexPath.row - pollOptionsAdded.count - 1]
            }
            
            cell.setCell(cellText: name!, tableView: pollOptionsTableView, parentViewController: self, rowIndex: indexPath.row)
            cell.setEditable(isEditable: (indexPath.row == 0))
            return cell
        } else if (tableView == dropDownTableView) {
            let cell:DropDownCell = dropDownTableView.dequeueReusableCell(withIdentifier: "AgeGenderDropDownCell") as! DropDownCell
            var name:String = ""
            var isChecked:Bool = false
            if (currentDropDown == "yourAge") {
                name = global.yourAgeOptions[indexPath.row]
                isChecked = (currentlyCheckedYourAgeIndex == indexPath.row)
            } else if (currentDropDown == "yourGender") {
                name = global.yourGenderOptions[indexPath.row]
                isChecked = (currentlyCheckedYourGenderIndex == indexPath.row)
            } else {
                name = "Error, unknown which table view to use"
                isChecked = false
            }
            cell.setCellAgeGenderOption(cellText: name, isChecked: isChecked)
            return cell
        } else {
            print("ERROR, TABLE VIEW NOT SET")
            let cell:DropDownCell = dropDownTableView.dequeueReusableCell(withIdentifier: "AgeGenderDropDownCell") as! DropDownCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == dropDownTableView) {
            if (currentDropDown == "yourAge") {
                currentlyCheckedYourAgeIndex = indexPath.row
                UserDefaults.standard.set(currentlyCheckedYourAgeIndex, forKey: "storedAgeIndex")
                UIView.performWithoutAnimation {
                    let ageTitle = currentlyCheckedYourAgeIndex == 0 ? "Your Age ▼": global.yourAgeOptions[currentlyCheckedYourAgeIndex] + " ▼"
                    yourAgeButtonOutlet.setTitle(ageTitle, for: .normal)
                    
                    yourAgeButtonOutlet.layoutIfNeeded()
                }
            } else if (currentDropDown == "yourGender") {
                currentlyCheckedYourGenderIndex = indexPath.row
                UserDefaults.standard.set(currentlyCheckedYourGenderIndex, forKey: "storedGenderIndex")
                UIView.performWithoutAnimation {
                    let genderTitle = currentlyCheckedYourGenderIndex == 0 ? "Your Gender ▼": global.yourGenderOptions[currentlyCheckedYourGenderIndex] + " ▼"
                    yourGenderButtonOutlet.setTitle(genderTitle, for: .normal)
                    
                    yourGenderButtonOutlet.layoutIfNeeded()
                }
            }
            
            let futureTime = DispatchTime.now() + global.dropDownTableViewDisappearDelay
            DispatchQueue.main.asyncAfter(deadline: futureTime) {
                self.dropDownTableView.isHidden = true
                self.grayBackgroundView.alpha = 0
            }
            
            dropDownTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (tableView == pollOptionsTableView) {
            
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0
            
            if let numSelectedRows = pollOptionsTableView.indexPathsForSelectedRows?.count {
                if numSelectedRows == global.maxNumberPollOptions {
                    global.showSimpleAlert(title: "You cannot select more than \(global.maxNumberPollOptions) poll options", message: "", vc: self)
                    return nil
                }
            }
            return indexPath
        } else {
            return indexPath
        }
    }
}
