//
//  Global.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/29/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import Foundation
import UIKit

class Global {
    
    var isAdmin:Bool = false
    
    var username:String? = UserDefaults.standard.string(forKey: "username")
    
    let pollOptionTrackTintColor:UIColor = UIColor.init(red: 228/255, green: 228/255, blue: 230/255, alpha: 1)
    let pollOptionColorDefault = UIColor.init(red: 15/255, green: 203/255, blue: 255/255, alpha: 1)
    let pollOptionColorMostVotes = UIColor.init(red: 15/255, green: 203/255, blue: 255/255, alpha: 1)
    let pollOptionColorWhenSelectedAsOption:UIColor = UIColor.init(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
    let dropDownCellBackgroundColor:UIColor = UIColor.init(red: 15/255, green: 203/255, blue: 255/255, alpha: 1)
    let wentOverCharacterOrWordLimitColor:UIColor = UIColor.red
    let grayBackgroundAlpha:CGFloat = 0.35
    
    let categoryOptions:[String] = ["All", "Is he interested", "Is she interested", "Should I break up with her"]
    let sortByOptions:[String] = ["Popular", "New"]
    
    let categoryToOptions:[String:[String]] = ["All": ["All 1", "All 2", "All 3", "All 4", "All 5", "All 6", "All 7", "All 8"], "Is he interested":["IHE 1", "IHE 2", "IHE 3", "IHE 4", "IHE 5"], "Is she interested": ["ISE 1", "ISE 2", "ISE 3", "ISE 4", "ISE 5"], "Should I break up with her": ["SIBUWH 1", "SIBUWH 2", "SIBUWH 3", "SIBUWH 4", "SIBUWH 5"]]
    
    let yourAgeOptions:[String] = ["No selection", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99+"]
    let yourGenderOptions:[String] = ["No selection", "Male", "Female", "Non-binary"]
    
    let maxTitleChars:Int = 100
    let maxMessageWords:Int = 500
    let maxNumberPollOptions:Int = 5
    let minNumberPollOptions:Int = 2
    let dropDownTableViewDisappearDelay:Double = 0.15 // in seconds
    let waitToReceiveFullMessageDelay:Double = 0.10 // in seconds
    let numPostsPerServerRequest:Int = 5
    let numPostsReceivedThresholdForServerBeingOutOfPosts:Int = 2 // need at least this many posts otherwise consider server to be out of posts
    
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    var inputStream: InputStream!
    var outputStream: OutputStream!
    let IPAddress:CFString = "18.222.70.0" as CFString
    let PORT:UInt32 = 16042
    let CONNECTION_TIMEOUT_THRESHOLD = DispatchTimeInterval.seconds(5) // seconds
    var stableConnectionExists:Bool = false
    var numberReceivedMessages = 0
    
    func networkError(vc:Any) {
        let alert = UIAlertController(title: "Network Error", message: "Please reconnect to the internet and try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: {_ in global.setupNetworkCommunication(vc: vc)}))
        (vc as AnyObject).present(alert, animated: true, completion: nil)
    }
    
    func setupNetworkCommunication(vc:Any) {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, IPAddress, PORT, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
                
        inputStream.delegate = (vc as! StreamDelegate)

        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
               
        inputStream.open()
        outputStream.open()
    }
    
    func sendMessage(dictionaryMessage:[String:Any], vc:Any) {
        
        // replace wierd quotes with regular quotes so they get auto-escaped
        var messageWithNormalizedQuotes = dictionaryMessage
        if let title = dictionaryMessage["title"] as! String? {
            messageWithNormalizedQuotes["title"] = replaceOccurencesOfQuotesBeforeSending(string: title)
        }
        if let message = dictionaryMessage["message"] as! String? {
            messageWithNormalizedQuotes["message"] = replaceOccurencesOfQuotesBeforeSending(string: message)
        }
        if let votingOptions = dictionaryMessage["votingOptions"] as! [String]? {
            var newVotingOptions:[String] = []
            for index in 0..<votingOptions.count {
                newVotingOptions.append(replaceOccurencesOfQuotesBeforeSending(string: votingOptions[index]))
            }
            messageWithNormalizedQuotes["votingOptions"] = getJsonFromStringList(stringList: newVotingOptions)
        }
        if let username = dictionaryMessage["username"] as! String? {
            messageWithNormalizedQuotes["username"] = replaceOccurencesOfQuotesBeforeSending(string: username)
        }
        if let password = dictionaryMessage["password"] as! String? {
            messageWithNormalizedQuotes["password"] = replaceOccurencesOfQuotesBeforeSending(string: password)
        }
        // finish replacing
        
        
        let futureTime = DispatchTime.now() + global.CONNECTION_TIMEOUT_THRESHOLD
        let currentNumMessages = global.numberReceivedMessages
        DispatchQueue.main.asyncAfter(deadline: futureTime) {
            if global.numberReceivedMessages <= currentNumMessages {
                global.stableConnectionExists = false
                global.networkError(vc: vc)
            }
        }
        
        if let theJSONData = try? JSONSerialization.data(withJSONObject: messageWithNormalizedQuotes, options: []) {
            if let theJSONText = String(data: theJSONData, encoding: .utf8) {
                
                let msgLengthAsInt:Int32 = Int32(theJSONText.count)
                let msgLengthAsBytes = withUnsafeBytes(of: msgLengthAsInt.bigEndian) { Data($0) }
                
                let msgAsBytes = theJSONText.data(using: .utf8)!
                
                let data = msgLengthAsBytes + msgAsBytes
                
                data.withUnsafeBytes {
                    guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                        return
                    }
                    outputStream.write(pointer, maxLength: data.count)
                    print("Message sent with instruction: " + (messageWithNormalizedQuotes["instruction"]! as! String))
                }
            }
        }
    }
    
    func getMessageFromInputStream(inputStream:InputStream) -> [String:Any]? {
        
        let bufferForMessageSize = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        inputStream.read(bufferForMessageSize, maxLength: 4)

        //let messageSize:Int32 = Int32((bufferForMessageSize[0] << 24) | (bufferForMessageSize[1] << 16) | (bufferForMessageSize[2] << 8) | (bufferForMessageSize[3]))
        //let intMessageSize = Int(messageSize)
        
        let a:Int = Int(bufferForMessageSize[0]) * Int(pow(2.0, 24.0))
        let b:Int = Int(bufferForMessageSize[1]) * Int(pow(2.0, 16.0))
        let c:Int = Int(bufferForMessageSize[2]) * Int(pow(2.0, 8.0))
        let d:Int = Int(bufferForMessageSize[3])
        let intMessageSize = a + b + c + d

        let bufferForMessage = UnsafeMutablePointer<UInt8>.allocate(capacity: intMessageSize)
        inputStream.read(bufferForMessage, maxLength: intMessageSize)
        
        if let message = String(bytesNoCopy: bufferForMessage, length: intMessageSize, encoding: .utf8, freeWhenDone: true) {
            global.numberReceivedMessages += 1
            if let data = message.data(using: .utf8) {
                do {
                    if let rv = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Message received with instruction: " + (rv["instruction"]! as! String))
                        return rv
                    } else {
                        print("Could not convert message to type [String: Any]")
                        print("Message received: \(data)")
                    }
                } catch let error {
                    print("Error reading data")
                    print(error.localizedDescription)
                    print(message)
                    return nil
                }
            }
        }
        return nil
    }
    
    func getStringListFromJson(jsonString:String) -> [String] {
        if let decoded = try? JSONDecoder().decode([String].self, from: jsonString.data(using: .utf8)!) {
            return decoded
        } else {
            return []
        }
    }
    func getIntListFromJson(jsonString:String) -> [Int] {
        if let decoded = try? JSONDecoder().decode([Int].self, from: jsonString.data(using: .utf8)!) {
            return decoded
        } else {
            return []
        }
    }
    func getJsonFromStringList(stringList:[String]) -> String? {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: stringList, options: []) {
            if let theJSONText = String(data: theJSONData, encoding: .utf8) {
                return theJSONText
            }
        }
        return nil
    }
    
    func showSimpleAlert(title:String, message:String, vc:Any) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        (vc as AnyObject).present(alert, animated: true, completion: nil)
    }
    
    func replaceOccurencesOfQuotesBeforeSending(string:String) -> String {
        var strToReturn = string.replacingOccurrences(of: "‘", with: "'")
        strToReturn = strToReturn.replacingOccurrences(of: "“", with: "\"")
        strToReturn = strToReturn.replacingOccurrences(of: "’", with: "'")
        strToReturn = strToReturn.replacingOccurrences(of: "”", with: "\"")
        return strToReturn
    }
}

let global = Global()
