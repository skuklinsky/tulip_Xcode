//
//  Poast.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/27/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation

class Poast {
    var title:String
    var message:String
    var votingOptions:[String]
    var correspondingVotes:[Int]
    var category:String
    var age:String?
    var gender:String?
    var posterUsername:String
    var timePostSubmitted:CLongLong?
    
    var userVoteIndex:Int = -1
    
    init(title:String, message:String, votingOptions:[String], correspondingVotes:[Int], category:String, age:String?, gender:String?, posterUsername:String, timePostSubmitted:CLongLong?) {
        self.title = title
        self.message = message
        self.votingOptions = votingOptions
        self.correspondingVotes = correspondingVotes
        self.category = category
        self.age = age
        self.gender = gender
        self.posterUsername = posterUsername
        self.timePostSubmitted = timePostSubmitted
    }
    
    
}
