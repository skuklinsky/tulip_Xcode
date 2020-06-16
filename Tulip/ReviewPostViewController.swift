//
//  ReviewPostViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/30/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit

class ReviewPostViewController: UIViewController {
    
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var postLabel: UILabel!
    
    var post:Poast? = nil
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        let dictionaryToSend:[String: Any] = ["instruction": "submitPost", "title": post!.title, "message": post!.message, "votingOptions": post!.votingOptions, "category": post!.category, "age": post!.age ?? "", "gender": post!.gender ?? "", "posterUsername": post!.posterUsername]
        global.sendMessage(dictionaryMessage: dictionaryToSend, vc: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTableView.dataSource = self
        contentTableView.delegate = self
        contentTableView.allowsSelection = false
        contentTableView.separatorStyle = .none
        
        let reviewAndPostGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reviewAndPostLabelAction))
        postLabel.addGestureRecognizer(reviewAndPostGestureRecognizer)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        global.inputStream.delegate = self
    }
    
    //Action
    @objc func reviewAndPostLabelAction() {
        nextButtonAction(self)
    }

}


extension ReviewPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MainEntryCell = contentTableView.dequeueReusableCell(withIdentifier: "MainEntryCellReviewPost") as! MainEntryCell
        cell.setCellReviewPost(post: post!, tableView: contentTableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

extension ReviewPostViewController: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode == .hasBytesAvailable {
            if let receivedMessage = global.getMessageFromInputStream(inputStream: aStream as! InputStream) {
                handleReceivedMessage(dictionary: receivedMessage)
            }
        } else if (eventCode == .errorOccurred) {
            
            if (UserDefaults.standard.bool(forKey: "didResignActive")) { // if resigned active, don't show "Try again" message
                
                UserDefaults.standard.set(false, forKey: "didResignActive") // reset resign active status
                global.setupNetworkCommunication(vc: self)
            } else {
                global.stableConnectionExists = false
                global.networkError(vc: self)
            }
        }
    }
    
    func handleReceivedMessage(dictionary:[String:Any]) {
        
        if let instruction = dictionary["instruction"] as? String {
            switch (instruction) {
            case "connectionEstablished":
                global.stableConnectionExists = true
            case "successfullySubmittedPost":
                handleSubmittedPostSuccessfully()
            default:
                return
            }
        }
    }
    
    func handleSubmittedPostSuccessfully() {
        self.performSegue(withIdentifier: "unwindFromReviewPostToViewController", sender: self)
    }
}
