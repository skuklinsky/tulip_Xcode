//
//  ViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/26/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var dropDownTableView: UITableView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createPostButton: UIButton!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var grayBackgroundView: UIView!
    
    @IBOutlet weak var dropDownTableViewHeight: NSLayoutConstraint!
    
    let dropDownRowHeight:CGFloat = 46.5
    
    var posts:[Poast] = []
    
    var dropDownButton = "sortBy"
    var sortByCurrentlyCheckedIndex = 0
    var categoriesCurrentlyCheckedIndex = 0
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func settingsAction(_ sender: Any) {
    }
    
    @IBAction func profileAction(_ sender: Any) {
        global.sendMessage(dictionaryMessage: ["instruction": "getMyPosts", "username": global.username], vc: self)
    }
    
    
    @IBAction func createPostAction(_ sender: Any) {
        let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
        newScreen.modalPresentationStyle = .fullScreen
        self.present(newScreen, animated: true, completion: nil)
    }
    
    @IBAction func sortByClicked(_ sender: Any) {
        
        if (!dropDownTableView.isHidden && dropDownButton == "sortBy") {
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0

        } else {
            dropDownTableViewHeight.constant = dropDownRowHeight * CGFloat(global.sortByOptions.count)
            dropDownButton = "sortBy"
            dropDownTableView.reloadData()
            dropDownTableView.isHidden = false
            grayBackgroundView.alpha = global.grayBackgroundAlpha
        }
        
    }
    
    @IBAction func categoriesClicked(_ sender: Any) {
        
        if (!dropDownTableView.isHidden && dropDownButton == "categories") {
            dropDownTableView.isHidden = true
            grayBackgroundView.alpha = 0

        } else {
            dropDownTableViewHeight.constant = dropDownRowHeight * CGFloat(global.categoryOptions.count)
            dropDownButton = "categories"
            dropDownTableView.reloadData()
            dropDownTableView.isHidden = false
            grayBackgroundView.alpha = global.grayBackgroundAlpha
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        global.setupNetworkCommunication(vc: self)
        contentTableViewRefreshAction()
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        
        contentTableView.separatorStyle = .none
        contentTableView.allowsSelection = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(contentTableViewRefreshAction), for: .valueChanged)
        contentTableView.refreshControl = refreshControl
        
        let clickedBackgroundGesture = UITapGestureRecognizer(target: self, action: #selector(clickedBackgroundAction))
        grayBackgroundView.addGestureRecognizer(clickedBackgroundGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        global.inputStream.delegate = self
    }
    
    //Action
    @objc func clickedBackgroundAction() {
        dropDownTableView.isHidden = true
        grayBackgroundView.alpha = 0
    }
    
    //Action
    @objc func contentTableViewRefreshAction() {
        global.sendMessage(dictionaryMessage: ["instruction": "getMainFeedPosts", "category": global.categoryOptions[categoriesCurrentlyCheckedIndex], "sortBy": global.sortByOptions[sortByCurrentlyCheckedIndex]], vc: self)
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == dropDownTableView) {
            if (dropDownButton == "sortBy") {
                return global.sortByOptions.count
            } else if (dropDownButton == "categories") {
                return global.categoryOptions.count
            }
        } else if (tableView == contentTableView) {
            return posts.count // get max possible entries from server
        }
        
        return -1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == dropDownTableView) {
            let cell:DropDownCell = dropDownTableView.dequeueReusableCell(withIdentifier: "ViewControllerDropDownCell") as! DropDownCell
            
            var name = ""
            var isChecked = false
            if (dropDownButton == "sortBy") {
                name = global.sortByOptions[indexPath.row]
                isChecked = (sortByCurrentlyCheckedIndex == indexPath.row)
            } else if (dropDownButton == "categories") {
                name = global.categoryOptions[indexPath.row]
                isChecked = (categoriesCurrentlyCheckedIndex == indexPath.row)
            }
            
            cell.setCell(cellText: name, isChecked: isChecked)
            return cell
            
            
        } else if (tableView == contentTableView) {
            
            let cell:MainEntryCell = contentTableView.dequeueReusableCell(withIdentifier: "MainEntryCell") as! MainEntryCell
            cell.setCell(post: posts[indexPath.row], tableView: contentTableView)
            return cell
        }
        
        let cell:MainEntryCell = contentTableView.dequeueReusableCell(withIdentifier: "MainEntryCell") as! MainEntryCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == dropDownTableView) {
            let oldSortByIndex = sortByCurrentlyCheckedIndex
            let oldCategoriesIndex = categoriesCurrentlyCheckedIndex
            
            if (dropDownButton == "sortBy") {
                sortByCurrentlyCheckedIndex = indexPath.row
            } else if (dropDownButton == "categories") {
                categoriesCurrentlyCheckedIndex = indexPath.row
            }
            
            if (sortByCurrentlyCheckedIndex != oldSortByIndex || categoriesCurrentlyCheckedIndex != oldCategoriesIndex) {
                contentTableViewRefreshAction()
            }
            
            let futureTime = DispatchTime.now() + global.dropDownTableViewDisappearDelay
            DispatchQueue.main.asyncAfter(deadline: futureTime) {
                self.dropDownTableView.isHidden = true
                self.grayBackgroundView.alpha = 0
            }
        }
    }

}

extension ViewController: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode == .hasBytesAvailable {
            if let receivedMessage = global.getMessageFromInputStream(inputStream: aStream as! InputStream) {
                handleReceivedMessage(dictionary: receivedMessage)
            }
        } else if (eventCode == .errorOccurred) {
            global.stableConnectionExists = false
            global.networkError(vc: self)
        }
    }
    
    func handleReceivedMessage(dictionary:[String:Any]) {
        
        if let instruction = dictionary["instruction"] as? String {
            switch (instruction) {
            case "connectionEstablished":
                global.stableConnectionExists = true
            case "getMainFeedPostsResponse":
                handleGetMainFeedPostsResponse(dictionary: dictionary)
            case "getMyPostsResponse":
                handleGetMyPostsResponse(dictionary: dictionary)
            default:
                return
            }
        }
    }
    
    func handleGetMainFeedPostsResponse(dictionary:[String: Any]) {
        var postsAsJsonStrings:[String] = []
    
        if (dictionary["posts"] != nil) {
            postsAsJsonStrings = global.getStringListFromJson(jsonString: dictionary["posts"]! as! String)
        }
        
        // postsAsJsonStrings of form: [post1AsJsonString, post2AsJsonString, ...]
        var posts:[Poast] = []
        
        for postAsJsonString in postsAsJsonStrings {
            if let data = postAsJsonString.data(using: .utf8) {
                do {
                    if let postDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let title:String = postDictionary["title"] as! String
                        let message:String = postDictionary["message"] as! String
                        let votingOptions:[String] = global.getStringListFromJson(jsonString: postDictionary["votingOptions"] as! String)
                        let correspondingVotes:[Int] = global.getIntListFromJson(jsonString: postDictionary["correspondingVotes"] as! String)
                        let category:String = postDictionary["category"] as! String
                        let age:String? = postDictionary["age"] as! String?
                        let gender:String? = postDictionary["gender"] as! String?
                        let posterUsername:String = postDictionary["posterUsername"] as! String
                        let timePostSubmitted:CLongLong = postDictionary["timePostSubmitted"] as! CLongLong
                        posts.append(Poast(title: title, message: message, votingOptions: votingOptions, correspondingVotes: correspondingVotes, category: category, age: age, gender: gender, posterUsername: posterUsername, timePostSubmitted: timePostSubmitted))
                    } else {
                        print("Could not convert message to type [String: Any]")
                        print("Message received: \(data)")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        self.posts = posts
        contentTableView.reloadData()
        contentTableView.refreshControl?.endRefreshing()
    }
    
    func handleGetMyPostsResponse(dictionary:[String: Any]) {
        var postsAsJsonStrings:[String] = []
        
        if (dictionary["posts"] != nil) {
            postsAsJsonStrings = global.getStringListFromJson(jsonString: dictionary["posts"]! as! String)
        }
        
        // postsAsJsonStrings of form: [post1AsJsonString, post2AsJsonString, ...]
        var posts:[Poast] = []
        
        for postAsJsonString in postsAsJsonStrings {
            if let data = postAsJsonString.data(using: .utf8) {
                do {
                    if let postDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let title:String = postDictionary["title"] as! String
                        let message:String = postDictionary["message"] as! String
                        let votingOptions:[String] = global.getStringListFromJson(jsonString: postDictionary["votingOptions"] as! String)
                        let correspondingVotes:[Int] = global.getIntListFromJson(jsonString: postDictionary["correspondingVotes"] as! String)
                        let category:String = postDictionary["category"] as! String
                        let age:String? = postDictionary["age"] as! String?
                        let gender:String? = postDictionary["gender"] as! String?
                        let posterUsername:String = postDictionary["posterUsername"] as! String
                        let timePostSubmitted:CLongLong = postDictionary["timePostSubmitted"] as! CLongLong
                        posts.append(Poast(title: title, message: message, votingOptions: votingOptions, correspondingVotes: correspondingVotes, category: category, age: age, gender: gender, posterUsername: posterUsername, timePostSubmitted: timePostSubmitted))
                    } else {
                        print("Could not convert message to type [String: Any]")
                        print("Message received: \(data)")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        newScreen.posts = posts
        newScreen.modalPresentationStyle = .fullScreen
        self.present(newScreen, animated: true, completion: nil)
    }

}
