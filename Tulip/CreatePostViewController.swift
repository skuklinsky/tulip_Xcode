//
//  CreatePostViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/28/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController {

    @IBOutlet weak var dropDownTableView: UITableView!
    @IBOutlet weak var titleCharacterCount: UILabel!
    @IBOutlet weak var messageWordCount: UILabel!
    @IBOutlet weak var titleTextView: CustomTextView!
    @IBOutlet weak var messageTextView: CustomTextView!
    @IBOutlet weak var dropDownTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectCategoryOutlet: UIButton!
    @IBOutlet weak var selectPollOptionsLabel: UILabel!
    
    @IBOutlet weak var grayBackgroundView: UIView!
    
    let dropDownRowHeight:CGFloat = 46.5 
    
    var currentlyCheckedIndex = -1

    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if (currentlyCheckedIndex == -1) {
            global.showSimpleAlert(title: "A category must be selected", message: "", vc: self)
        } else if (titleTextView.text.count == 0) {
            global.showSimpleAlert(title: "A title is required", message: "", vc: self)
        } else if (titleTextView.text.count > global.maxTitleChars) {
            global.showSimpleAlert(title: "Titles cannot have more than \(global.maxTitleChars) characters", message: "", vc: self)
        } else if (getNumWords(text: messageTextView.text) > global.maxMessageWords) {
            global.showSimpleAlert(title: "Messages cannot have more than \(global.maxMessageWords) words", message: "", vc: self)
        } else {
            let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "SelectPollOptionsViewController") as! SelectPollOptionsViewController
            newScreen.postCategory = global.categoryOptions[currentlyCheckedIndex]
            newScreen.postTitle = titleTextView.text
            newScreen.postMessage = messageTextView.text
            newScreen.modalPresentationStyle = .fullScreen
            self.present(newScreen, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectCategoryAction(_ sender: Any) {
        if (!dropDownTableView.isHidden) {
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0
        } else {
            dropDownTableViewHeightConstraint.constant = dropDownRowHeight * CGFloat(global.categoryOptions.count)
            dropDownTableView.reloadData()
            dropDownTableView.isHidden = false
            grayBackgroundView.alpha = global.grayBackgroundAlpha
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        tap.cancelsTouchesInView = false 
        
        view.addGestureRecognizer(tap)
        
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
                
        titleTextView.delegate = self
        messageTextView.delegate = self
        
        titleCharacterCount.text = "0 / \(global.maxTitleChars) Characters"
        messageWordCount.text = "0 / \(global.maxMessageWords) Words"
        
        let selectPollOptionsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPollOptionsLabelTappedAction))
        selectPollOptionsLabel.addGestureRecognizer(selectPollOptionsGestureRecognizer)
        
        let clickedBackgroundGesture = UITapGestureRecognizer(target: self, action: #selector(clickedBackgroundAction))
        grayBackgroundView.addGestureRecognizer(clickedBackgroundGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func getNumWords(text:String) -> Int {
        let components = text.components(separatedBy: .whitespacesAndNewlines) // split text by whitespaces and new lines
        let words = components.filter({!$0.isEmpty}) // remove components that are empty, for cases when multiple whitespaces in a row
        return words.count
    }
    
    //Action
    @objc func selectPollOptionsLabelTappedAction() {
        nextButtonAction(self)
    }
    
    //Action
    @objc func clickedBackgroundAction() {
        dropDownTableView.isHidden = true
        grayBackgroundView.alpha = 0
    }

}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return global.categoryOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DropDownCell = dropDownTableView.dequeueReusableCell(withIdentifier: "ChooseCategoryCreatePostCell") as! DropDownCell
        
        let name = global.categoryOptions[indexPath.row]
        let isChecked = (currentlyCheckedIndex == indexPath.row)
        cell.setCellChooseCategoryCreatePost(cellText: name, isChecked: isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentlyCheckedIndex = indexPath.row
        
        UIView.performWithoutAnimation {
            selectCategoryOutlet.setTitle(global.categoryOptions[currentlyCheckedIndex] + " ▼", for: .normal)
            selectCategoryOutlet.layoutIfNeeded()
        }
        
        let futureTime = DispatchTime.now() + global.dropDownTableViewDisappearDelay
        DispatchQueue.main.asyncAfter(deadline: futureTime) {
            self.dropDownTableView.isHidden = true
            self.grayBackgroundView.alpha = 0
        }
        
        dropDownTableView.reloadData()
    }

}

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if (textView == titleTextView) {
            if let numChars = titleTextView.text?.count {
                titleCharacterCount.text = "\(numChars) / \(global.maxTitleChars) Characters"
                
                if (numChars > global.maxTitleChars) {
                    let attributedText = NSMutableAttributedString(string: titleCharacterCount.text!)
                    
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: global.wentOverCharacterOrWordLimitColor, range: NSRange(location: 0, length: String(numChars).count))
                    titleCharacterCount.attributedText = attributedText
                }
            }
        } else if (textView == messageTextView) {
            if let message = messageTextView.text {
                let numWords = getNumWords(text: message)
                messageWordCount.text = "\(numWords) / \(global.maxMessageWords) Words"
                
                if (numWords > global.maxMessageWords) {
                    let attributedText = NSMutableAttributedString(string: messageWordCount.text!)
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: global.wentOverCharacterOrWordLimitColor, range: NSRange(location: 0, length: String(numWords).count))
                    messageWordCount.attributedText = attributedText
                }
            }
        }
    }
}
