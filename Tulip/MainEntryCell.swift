//
//  MainEntryCell.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/26/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class MainEntryCell: UITableViewCell {
    
    @IBOutlet weak var ageGenderLabel: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellMessage: UILabel!
    
    @IBOutlet weak var cpb1: CustomProgressBar!
    @IBOutlet weak var cpb2: CustomProgressBar!
    @IBOutlet weak var cpb3: CustomProgressBar!
    @IBOutlet weak var cpb4: CustomProgressBar!
    @IBOutlet weak var cpb5: CustomProgressBar!
    
    @IBOutlet weak var votingOption1: UIButton!
    @IBOutlet weak var votingOption2: UIButton!
    @IBOutlet weak var votingOption3: UIButton!
    @IBOutlet weak var votingOption4: UIButton!
    @IBOutlet weak var votingOption5: UIButton!
    
    @IBOutlet weak var yourVote1: UIImageView!
    @IBOutlet weak var yourVote2: UIImageView!
    @IBOutlet weak var yourVote3: UIImageView!
    @IBOutlet weak var yourVote4: UIImageView!
    @IBOutlet weak var yourVote5: UIImageView!
    
    @IBOutlet weak var totalVotesLabel: UILabel!
    @IBOutlet weak var cellMessageHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var ageGenderLabelReviewPost: UILabel!
    @IBOutlet weak var cellTitleReviewPost: UILabel!
    @IBOutlet weak var cellMessageReviewPost: UILabel!
    @IBOutlet weak var votingOption1ReviewPost: UIButton!
    @IBOutlet weak var votingOption2ReviewPost: UIButton!
    @IBOutlet weak var votingOption3ReviewPost: UIButton!
    @IBOutlet weak var votingOption4ReviewPost: UIButton!
    @IBOutlet weak var votingOption5ReviewPost: UIButton!
    @IBOutlet weak var cpb1ReviewPost: CustomProgressBar!
    @IBOutlet weak var cpb2ReviewPost: CustomProgressBar!
    @IBOutlet weak var cpb3ReviewPost: CustomProgressBar!
    @IBOutlet weak var cpb4ReviewPost: CustomProgressBar!
    @IBOutlet weak var cpb5ReviewPost: CustomProgressBar!
    @IBOutlet weak var cellMessageReviewPostHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ageGenderLabelProfile: UILabel!
    @IBOutlet weak var cellTitleProfile: UILabel!
    @IBOutlet weak var cellMessageProfile: UILabel!
    @IBOutlet weak var votingOption1Profile: UIButton!
    @IBOutlet weak var votingOption2Profile: UIButton!
    @IBOutlet weak var votingOption3Profile: UIButton!
    @IBOutlet weak var votingOption4Profile: UIButton!
    @IBOutlet weak var votingOption5Profile: UIButton!
    @IBOutlet weak var cpb1Profile: CustomProgressBar!
    @IBOutlet weak var cpb2Profile: CustomProgressBar!
    @IBOutlet weak var cpb3Profile: CustomProgressBar!
    @IBOutlet weak var cpb4Profile: CustomProgressBar!
    @IBOutlet weak var cpb5Profile: CustomProgressBar!
    @IBOutlet weak var cellMessageProfileHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalVotesLabelProfile: UILabel!
    
    
    var progressBars:[CustomProgressBar] = []
    var yourVoteImageViews:[UIImageView] = []
    var percentagesArray:[Float] = []
    var totalVotes:Int = 0
    var post:Poast? = nil
    var tableView:UITableView? = nil
    var indexOfOptionWithMostVotes = -1
    
    
    @IBAction func vo1Clicked(_ sender: Any) {
        userVoted(userVoteIndex: 0)
    }
    
    @IBAction func vo2Clicked(_ sender: Any) {
        userVoted(userVoteIndex: 1)
    }
    
    @IBAction func vo3Clicked(_ sender: Any) {
        userVoted(userVoteIndex: 2)
    }
    
    @IBAction func vo4Clicked(_ sender: Any) {
        userVoted(userVoteIndex: 3)
    }
    
    @IBAction func vo5Clicked(_ sender: Any) {
        userVoted(userVoteIndex: 4)
    }
    
    func userVoted(userVoteIndex:Int) {
        
        percentagesArray = []
        post?.correspondingVotes[userVoteIndex] += 1
        totalVotes += 1
        
        var maxVotes = -1
        for index in 0..<post!.correspondingVotes.count {
            percentagesArray.append(Float(post!.correspondingVotes[index]) / Float(totalVotes))
            if (post!.correspondingVotes[index] > maxVotes) {
                maxVotes = post!.correspondingVotes[index]
                indexOfOptionWithMostVotes = index
            }
        }
        totalVotesLabel.text = "Total Votes: \(totalVotes)"
        
        post!.userVoteIndex = userVoteIndex
        votingOption1.isEnabled = false
        votingOption2.isEnabled = false
        votingOption3.isEnabled = false
        votingOption4.isEnabled = false
        votingOption5.isEnabled = false
                
        cpb1.progress = percentagesArray[0]
        cpb1.progressTintColor = global.pollOptionColorDefault
        cpb2.progress = percentagesArray[1]
        cpb2.progressTintColor = global.pollOptionColorDefault
        
        if (post!.votingOptions.count >= 3) {
            cpb3.progress = percentagesArray[2]
            cpb3.progressTintColor = global.pollOptionColorDefault
        }
        if (post!.votingOptions.count >= 4) {
            cpb4.progress = percentagesArray[3]
            cpb4.progressTintColor = global.pollOptionColorDefault
        }
        if (post!.votingOptions.count >= 5) {
            cpb5.progress = percentagesArray[4]
            cpb5.progressTintColor = global.pollOptionColorDefault
        }
        
        progressBars[indexOfOptionWithMostVotes].progressTintColor = global.pollOptionColorMostVotes
        yourVoteImageViews[userVoteIndex].image = UIImage(named: "profile")
        
        global.sendMessage(dictionaryMessage: ["instruction": "voteOnPost", "timePostSubmitted": post!.timePostSubmitted!, "voteIndex": userVoteIndex], vc: ViewController.self)
    }
    
    func setCell(post:Poast, tableView:UITableView) {
        
        self.post = post
        self.tableView = tableView
        self.totalVotes = 0
        
        let messageLabelTapped = UITapGestureRecognizer(target: self, action: #selector(messageLabelTappedAction))
        cellMessage.addGestureRecognizer(messageLabelTapped)
                
        progressBars = [cpb1, cpb2, cpb3, cpb4, cpb5]
        yourVoteImageViews = [yourVote1, yourVote2, yourVote3, yourVote4, yourVote5]
        
        for numVotesPerOption in post.correspondingVotes {
            totalVotes += numVotesPerOption
        }
        
        totalVotesLabel.text = "Total Votes: \(totalVotes)"

        self.cellMessage.sizeToFit()
        self.cellTitle.sizeToFit()
        
        self.cellTitle.text = post.title
        self.cellMessage.text = post.message
        self.ageGenderLabel.text = (post.gender == nil) ? nil: post.gender! + ", " + post.age!
        
        votingOption1.setTitle(post.votingOptions[0], for: .normal)
        votingOption2.setTitle(post.votingOptions[1], for: .normal)
        cpb1.progress = 0
        cpb2.progress = 0
        
        if (post.votingOptions.count >= 3) {
            votingOption3.setTitle(post.votingOptions[2], for: .normal)
            cpb3.progress = 0
        } else {
            votingOption3.isHidden = true
            cpb3.isHidden = true
            yourVote3.isHidden = true
        }
        if (post.votingOptions.count >= 4) {
            votingOption4.setTitle(post.votingOptions[3], for: .normal)
            cpb4.progress = 0
        } else {
            votingOption4.isHidden = true
            cpb4.isHidden = true
            yourVote4.isHidden = true
        }
        if (post.votingOptions.count >= 5) {
            votingOption5.setTitle(post.votingOptions[4], for: .normal)
            cpb5.progress = 0
        } else {
            votingOption5.isHidden = true
            cpb5.isHidden = true
            yourVote5.isHidden = true
        }
        
        if (post.userVoteIndex != -1) { // if user has already voted
            userVoted(userVoteIndex: post.userVoteIndex)
        }
        
    }
    
    func setCellReviewPost(post:Poast, tableView:UITableView) {
        
        self.tableView = tableView
        
        self.cellTitleReviewPost.sizeToFit()
        self.cellMessageReviewPost.sizeToFit()
        
        let messageLabelReviewPostTapped = UITapGestureRecognizer(target: self, action: #selector(messageLabelReviewPostTappedAction))
        cellMessageReviewPost.addGestureRecognizer(messageLabelReviewPostTapped)
        
        self.cellTitleReviewPost.text = post.title
        self.cellMessageReviewPost.text = post.message
        self.ageGenderLabelReviewPost.text = (post.gender == nil) ? nil: post.gender! + ", " + post.age!
        
        votingOption1ReviewPost.setTitle(post.votingOptions[0], for: .normal)
        votingOption2ReviewPost.setTitle(post.votingOptions[1], for: .normal)
        
        if (post.votingOptions.count >= 3) {
            votingOption3ReviewPost.setTitle(post.votingOptions[2], for: .normal)
        } else {
            votingOption3ReviewPost.isHidden = true
            cpb3ReviewPost.isHidden = true
        }
        if (post.votingOptions.count >= 4) {
            votingOption4ReviewPost.setTitle(post.votingOptions[3], for: .normal)
        } else {
            votingOption4ReviewPost.isHidden = true
            cpb4ReviewPost.isHidden = true
        }
        if (post.votingOptions.count >= 5) {
            votingOption5ReviewPost.setTitle(post.votingOptions[4], for: .normal)
            cpb5ReviewPost.progress = 0
        } else {
            votingOption5ReviewPost.isHidden = true
            cpb5ReviewPost.isHidden = true
        }
        
    }
    
    func setCellProfile(post:Poast, tableView:UITableView) {
        self.tableView = tableView
        self.totalVotes = 0
        
        self.cellTitleProfile.sizeToFit()
        self.cellMessageProfile.sizeToFit()
        
        let messageLabelProfileTapped = UITapGestureRecognizer(target: self, action: #selector(messageLabelProfileTappedAction))
        cellMessageProfile.addGestureRecognizer(messageLabelProfileTapped)
        
        self.cellTitleProfile.text = post.title
        self.cellMessageProfile.text = post.message
        self.ageGenderLabelProfile.text = (post.gender == nil) ? nil: post.gender! + ", " + post.age!
        
        progressBars = [cpb1Profile, cpb2Profile, cpb3Profile, cpb4Profile, cpb5Profile]
        
        for numVotesPerOption in post.correspondingVotes {
            totalVotes += numVotesPerOption
        }
        
        var maxVotes = -1
        for index in 0..<post.correspondingVotes.count {
            percentagesArray.append(Float(post.correspondingVotes[index]) / Float(totalVotes))
            if (post.correspondingVotes[index] > maxVotes) {
                maxVotes = post.correspondingVotes[index]
                indexOfOptionWithMostVotes = index
            }
        }
        totalVotesLabelProfile.text = "Total Votes: \(totalVotes)"
        
        votingOption1Profile.setTitle(post.votingOptions[0], for: .normal)
        cpb1Profile.progress = totalVotes != 0 ? percentagesArray[0]: 0
        cpb1Profile.progressTintColor = global.pollOptionColorDefault
        
        votingOption2Profile.setTitle(post.votingOptions[1], for: .normal)
        cpb2Profile.progress = totalVotes != 0 ? percentagesArray[1]: 0
        cpb2Profile.progressTintColor = global.pollOptionColorDefault
        
        if (post.votingOptions.count >= 3) {
            votingOption3Profile.setTitle(post.votingOptions[2], for: .normal)
            cpb3Profile.progress = totalVotes != 0 ? percentagesArray[2]: 0
            cpb3Profile.progressTintColor = global.pollOptionColorDefault
        } else {
            votingOption3Profile.isHidden = true
            cpb3Profile.isHidden = true
        }
        if (post.votingOptions.count >= 4) {
            votingOption4Profile.setTitle(post.votingOptions[3], for: .normal)
            cpb4Profile.progress = totalVotes != 0 ? percentagesArray[3]: 0
            cpb4Profile.progressTintColor = global.pollOptionColorDefault
        } else {
            votingOption4Profile.isHidden = true
            cpb4Profile.isHidden = true
        }
        if (post.votingOptions.count >= 5) {
            votingOption5Profile.setTitle(post.votingOptions[4], for: .normal)
            cpb5Profile.progress = totalVotes != 0 ? percentagesArray[4]: 0
            cpb5Profile.progressTintColor = global.pollOptionColorDefault
        } else {
            votingOption5Profile.isHidden = true
            cpb5Profile.isHidden = true
        }
        
        progressBars[indexOfOptionWithMostVotes].progressTintColor = global.pollOptionColorMostVotes
        
    }
    
    //Action
    @objc func messageLabelTappedAction() {
        tableView!.beginUpdates()
        cellMessageHeightConstraint.constant = 2000
        tableView!.endUpdates()
    }
    
    //Action
    @objc func messageLabelReviewPostTappedAction() {
        tableView!.beginUpdates()
        cellMessageReviewPostHeightConstraint.constant = 2000
        tableView!.endUpdates()
    }
    
    //Action
    @objc func messageLabelProfileTappedAction() {
        tableView!.beginUpdates()
        cellMessageProfileHeightConstraint.constant = 2000
        tableView!.endUpdates()
    }

}