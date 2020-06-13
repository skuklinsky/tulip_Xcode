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
    
    @IBOutlet weak var adminToolsButton: UIButton!
    @IBOutlet weak var createPostButton: UIButton!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var grayBackgroundView: UIView!
    
    @IBOutlet weak var dropDownTableViewHeight: NSLayoutConstraint!
    
    var posts:[Poast] = []
    
    let dropDownRowHeight:CGFloat = 46.5
    var dropDownButton = "sortBy"
    var sortByCurrentlyCheckedIndex = 0
    var categoriesCurrentlyCheckedIndex = 0
    var createPostOrViewProfile:String = ""
    var morePostsAvailable:Bool = true
    var okToAskServerForMorePosts:Bool = true
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func adminToolsAction(_ sender: Any) {
        let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "AdminToolsViewController") as! AdminToolsViewController
        newScreen.modalPresentationStyle = .fullScreen
        self.present(newScreen, animated: true, completion: nil)
    }
    
    @IBAction func profileAction(_ sender: Any) {
        if let _ = global.username {
            global.sendMessage(dictionaryMessage: ["instruction": "getMyPosts", "username": global.username!], vc: self)
        } else {
            createPostOrViewProfile = "viewProfile"
            loginOrSignup(purpose: "viewProfile")
        }
    }
    
    
    @IBAction func createPostAction(_ sender: Any) {
        
        if let _ = global.username {
            let newScreen = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
            newScreen.modalPresentationStyle = .fullScreen
            self.present(newScreen, animated: true, completion: nil)
        } else {
            createPostOrViewProfile = "createPost"
            loginOrSignup(purpose: "createPost")
        }
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
        
        UserDefaults.standard.set(false, forKey: "didResignActive") // launched new instance of app, reset resigning status
        
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
        
        if (global.isAdmin) {
            adminToolsButton.isHidden = false
            adminToolsButton.isEnabled = true
        }
        
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
        
        if (!okToAskServerForMorePosts) { // even if no more posts available, allowed to refresh
            contentTableView.refreshControl?.endRefreshing()
            return
        }
        
        okToAskServerForMorePosts = false // don't send another request until first is done
        let lastPostTimeSubmitted:CLongLong = 0
        global.sendMessage(dictionaryMessage: ["instruction": "getMainFeedPosts", "fullRefresh": true, "numPostsBeingRequested": global.numPostsPerServerRequest, "numPostsAlreadyLoaded": 0, "lastPostTimePostSubmitted": lastPostTimeSubmitted, "category": global.categoryOptions[categoriesCurrentlyCheckedIndex], "sortBy": global.sortByOptions[sortByCurrentlyCheckedIndex]], vc: self)
    }
    
    func contentTableViewLoadNextNPosts() {
        
        if (!morePostsAvailable || !okToAskServerForMorePosts) {
            return
        }
        
        okToAskServerForMorePosts = false // don't send another request until first is done
        let lastPostTimeSubmitted:CLongLong = posts.count > 0 ? posts[posts.count - 1].timePostSubmitted! : 0
        global.sendMessage(dictionaryMessage: ["instruction": "getMainFeedPosts", "fullRefresh": false, "numPostsBeingRequested": global.numPostsPerServerRequest, "numPostsAlreadyLoaded": posts.count, "lastPostTimePostSubmitted": lastPostTimeSubmitted, "category": global.categoryOptions[categoriesCurrentlyCheckedIndex], "sortBy": global.sortByOptions[sortByCurrentlyCheckedIndex]], vc: self)
    }
    
    func loginOrSignup(purpose:String) {
        var message:String = ""
        if (purpose == "viewProfile") {
            message = "In order to access your post history, you must be logged in."
        } else {
            message = "In order to create a post, you must be logged in. This allows you to easily access your posts later."
        }
        let alertController = UIAlertController(title: "Log in or Sign up", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Log in", style: .default, handler: showLoginAlert))
        alertController.addAction(UIAlertAction(title: "Sign up", style: .default, handler: showSignupAlert))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoginAlert(alert: UIAlertAction!) {
        let alertController = UIAlertController(title: "Enter your username and password", message: "", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "username"
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        })
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "password"
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Log in", style: .default, handler: {(alert: UIAlertAction!) in self.sendLoginRequestToServer(alert: alert, username: alertController.textFields![0].text!, password: alertController.textFields![1].text!)}))
        
        alertController.actions[1].isEnabled = false
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSignupAlert(alert: UIAlertAction) {
        let alertController = UIAlertController(title: "Create a username and password", message: "Your username will not be visible when you post.", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "username"
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        })
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "password"
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Sign up", style: .default, handler: {(alert: UIAlertAction!) in self.sendSignupRequestToServer(alert: alert, username: alertController.textFields![0].text!, password: alertController.textFields![1].text!)}))
        
        alertController.actions[1].isEnabled = false
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendLoginRequestToServer(alert: UIAlertAction, username:String, password:String) {
        let dictionaryToSend:[String: Any] = ["instruction": "loginRequest", "username": username, "password": password]
        global.sendMessage(dictionaryMessage: dictionaryToSend, vc: self)
    }
    
    func sendSignupRequestToServer(alert: UIAlertAction, username:String, password:String) {
        let dictionaryToSend:[String: Any] = ["instruction": "signupRequest", "username": username, "password": password]
        global.sendMessage(dictionaryMessage: dictionaryToSend, vc: self)
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
            return posts.count
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
            cell.setCell(post: posts[indexPath.row], tableView: contentTableView, vc: self)
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
            
            if ((sortByCurrentlyCheckedIndex != oldSortByIndex) || (categoriesCurrentlyCheckedIndex != oldCategoriesIndex)) {
                contentTableViewRefreshAction()
            }
            
            let futureTime = DispatchTime.now() + global.dropDownTableViewDisappearDelay
            DispatchQueue.main.asyncAfter(deadline: futureTime) {
                self.dropDownTableView.isHidden = true
                self.grayBackgroundView.alpha = 0
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indices:[Int]? = contentTableView.indexPathsForVisibleRows?.map({$0.row})
        if let nonOptionalIndices = indices {
            if (nonOptionalIndices.contains(posts.count - 1)) { // if last row is in the list of visible rows, reload
                contentTableViewLoadNextNPosts()
            }
        }
    }

}

extension ViewController: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode == .hasBytesAvailable {
            
            // wait for full message to come in before trying to read, otherwise can't read partial message
            let futureTime = DispatchTime.now() + global.waitToReceiveFullMessageDelay
            DispatchQueue.main.asyncAfter(deadline: futureTime) {
                if let receivedMessage = global.getMessageFromInputStream(inputStream: aStream as! InputStream) {
                    self.handleReceivedMessage(dictionary: receivedMessage)
                }
            }
            
        } else if (eventCode == .errorOccurred) {
            if (UserDefaults.standard.bool(forKey: "didResignActive")) { // if resigned active, don't show "Try again" message, just try to reconnect stealthily
                global.setupNetworkCommunication(vc: self)
            } else {
                global.stableConnectionExists = false
                global.networkError(vc: self)
            }
        }
        
        UserDefaults.standard.set(false, forKey: "didResignActive") // reset resign active status so if get socket error from here on, show "Try again" message
    }
    
    func handleReceivedMessage(dictionary:[String:Any]) {
        
        if let instruction = dictionary["instruction"] as? String {
            switch (instruction) {
            case "connectionEstablished":
                global.stableConnectionExists = true
                okToAskServerForMorePosts = true
                contentTableView.refreshControl?.endRefreshing()
            case "getMainFeedPostsResponse":
                handleGetMainFeedPostsResponse(dictionary: dictionary)
            case "getMyPostsResponse":
                handleGetMyPostsResponse(dictionary: dictionary)
            case "successfullyVoted":
                handleSuccessfullyVoted(dictionary: dictionary)
            case "loginRequestResponse":
                handleLoginRequestResponse(dictionary: dictionary)
            case "signupRequestResponse":
                handleSignupRequestResponse(dictionary: dictionary)
            case "serverDowntimeExpected":
                handleServerDowntimeExpected(dictionary: dictionary)
            default:
                return
            }
        }
    }
    
    func handleGetMainFeedPostsResponse(dictionary:[String: Any]) {
        var postsAsJsonStrings:[String] = [] // postsAsJsonStrings of form: [post1AsJsonString, post2AsJsonString, ...]
        let fullRefresh:Bool = dictionary["fullRefresh"] as! Bool
    
        if (dictionary["posts"] != nil) {
            postsAsJsonStrings = global.getStringListFromJson(jsonString: dictionary["posts"]! as! String)
        }
        
        var postsToAdd:[Poast] = []
        
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
                        
                        var postAlreadyInList:Bool = false
                        for post in self.posts {
                            if (post.timePostSubmitted! == timePostSubmitted) {
                                postAlreadyInList = true
                                break
                            }
                        }
                        
                        if (!postAlreadyInList || fullRefresh) { // if doing a full refresh, set self.posts = [] so always include received posts
                            postsToAdd.append(Poast(title: title, message: message, votingOptions: votingOptions, correspondingVotes: correspondingVotes, category: category, age: age, gender: gender, posterUsername: posterUsername, timePostSubmitted: timePostSubmitted))
                        }
                        
                    } else {
                        print("Could not convert message to type [String: Any]")
                        print("Message received: \(data)")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        if (fullRefresh) {
            self.posts = [] // delete all previous posts in table view if full refresh
        }
        
        for post in postsToAdd {
            self.posts.append(post)
        }
        
        if (postsToAdd.count < global.numPostsReceivedThresholdForServerBeingOutOfPosts) {
            morePostsAvailable = false
        } else {
            morePostsAvailable = true
        }
        
        okToAskServerForMorePosts = true
        
        contentTableView.reloadData()
        contentTableView.refreshControl?.endRefreshing()
        
        if (self.posts.count > 0 && fullRefresh) {
            let topIndex = IndexPath(row: 0, section: 0)
            contentTableView.scrollToRow(at: topIndex, at: .top, animated: true)
        }
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

    func handleSuccessfullyVoted(dictionary:[String: Any]) {
        let timePostSubmittedAsString = String(dictionary["timePostSubmitted"] as! CLongLong)
        let voteIndex = dictionary["voteIndex"] as! Int
        
        if var votesToIndices:[String:Int] = UserDefaults.standard.dictionary(forKey: "votingHistory") as! [String:Int]? {
            votesToIndices[timePostSubmittedAsString] = voteIndex
            UserDefaults.standard.set(votesToIndices, forKey: "votingHistory")
        } else {
            var votesToIndices:[String:Int] = [:]
            votesToIndices[timePostSubmittedAsString] = voteIndex
            UserDefaults.standard.set(votesToIndices, forKey: "votingHistory")
        }
    }
    
    func handleLoginRequestResponse(dictionary:[String: Any]) {
        let username = dictionary["username"] as! String
        let successfullyLoggedIn = dictionary["successfullyLoggedIn"] as! Bool
        
        if (!successfullyLoggedIn) {
            global.showSimpleAlert(title: "The username or password is incorrect", message: "Please try again", vc: self)
        } else {
            UserDefaults.standard.set(username, forKey: "username")
            global.username = username
            
            if (createPostOrViewProfile == "viewProfile") {
                profileAction(self)
            } else {
                createPostAction(self)
            }
        }
    }
    
    func handleSignupRequestResponse(dictionary:[String: Any]) {
        let username = dictionary["username"] as! String
        let successfullyCreatedAccount = dictionary["successfullyCreatedAccount"] as! Bool
        
        if (!successfullyCreatedAccount) {
            global.showSimpleAlert(title: "The username \(username) is already taken", message: "Please choose a different username", vc: self)
        } else {
            UserDefaults.standard.set(username, forKey: "username")
            global.username = username
            
            if (createPostOrViewProfile == "viewProfile") {
                profileAction(self)
            } else {
                createPostAction(self)
            }
        }
    }
    
    func handleServerDowntimeExpected(dictionary:[String: Any]) {
        let minutesUntilDowntime = dictionary["minutesUntilDowntime"] as! Int
        global.showSimpleAlert(title: "Expected Server Downtime", message: "In \(minutesUntilDowntime) minutes, the server will be temporarily unavailable for scheduled maintenance.", vc: self)
    }
}

extension ViewController {
    @objc func textChanged(_ sender: Any) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        
        if ((alert.textFields![0].text) != "" && alert.textFields![1].text != "") {
            alert.actions[1].isEnabled = true
        } else {
            alert.actions[1].isEnabled = false
        }
    }
}
