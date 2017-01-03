//
//  FeedManager.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import Foundation

class FeedManager {
    static let sharedManger = FeedManager()
    var feeds:Array<Feed> = Array()
    
    init() {
        // Load defaults
        let defs = UserDefaults.standard
        
        if let defaults:Array<Data> = defs.value(forKey: "Default") as? Array<Data> {
            loadDefaults(defaults)
        }
        else { // Defaults does not exist. Create and save! (Most likely first run)
            createDefaults()
        }
        
        // Load user created
        loadUserFeeds()
    }
    
    //MARK: Saving and loading feeds
    
    // Loads the users own feeds
    func loadUserFeeds() {
        let defs = UserDefaults.standard
        if let userFeeds:Array<Data> = defs.value(forKey: "User") as? Array<Data> {
            for data in userFeeds {
                let unarc = NSKeyedUnarchiver(forReadingWith: data)
                let feed = unarc.decodeObject(forKey: "root") as! Feed
                
                feeds.append(feed)
            }
        }
    }
    
    // Creates default feeds
    func createDefaults() {
        print("No defaults yet. Adding them!")
        
        var defaultArray:Array<Feed> = Array()
        
        // Read defaults from file
        do {
            let content = try String(contentsOfFile: Bundle.main.path(forResource: "Defaults", ofType: "txt")!, encoding: String.Encoding.utf8)
            let lines = content.components(separatedBy: "\n")
            for line in lines {
                let lineSplit = line.components(separatedBy: ";")
                let title = lineSplit[0]
                let URL = lineSplit[1]
                
                let thisFeed = Feed(title: title, URL: Foundation.URL(string: URL)!, isOn: false, isStandard: true)
                defaultArray.append(thisFeed)
            }
        }
        catch _ {
        }
        
        feeds.insert(contentsOf: defaultArray, at: 0)
        saveAll()
    }
    
    // Loads the default feeds
    func loadDefaults(_ defaults: Array<Data>) {
        for data in defaults {
            let unarc = NSKeyedUnarchiver(forReadingWith: data)
            let feed = unarc.decodeObject(forKey: "root") as! Feed
            
            feeds.append(feed)
        }
    }
    
    // Returns feeds that are enabled
    func enabledFeeds() -> Array<Feed> {
        var enabledAr:Array<Feed> = Array()
        for feed in feeds {
            if feed.isFeedOn! {
                enabledAr.append(feed)
            }
        }
        
        return enabledAr
    }
    
    // Saves default and users feeds
    func saveAll() {
        var defaults:Array<Data> = Array()
        var userCreated:Array<Data> = Array()
        
        // Add feeds to array
        for feed in feeds {
            let feedData = NSKeyedArchiver.archivedData(withRootObject: feed)
            
            if feed.isFeedStandard! {
                defaults.append(feedData)
            }
            else {
                userCreated.append(feedData)
            }
        }
        
        // Save!
        let defs = UserDefaults.standard
        defs.setValue(defaults, forKey: "Default")
        defs.setValue(userCreated, forKey: "User")
        defs.synchronize()
    }
    
    
    //MARK: Modifying / adding / deleting feeds
    // Removes feed
    func removeFeed(_ feedToRemove: Feed) {
        var removeIndex = -1
        for index in 0 ... feeds.count {
            if feeds[index] == feedToRemove {
                removeIndex = index
                break
            }
        }
        
        if removeIndex != -1 {
            feeds.remove(at: removeIndex)
            saveAll()
        }
    }
    
    func addFeed(_ newFeed: Feed) {
        feeds.append(newFeed)
        saveAll()
    }
}
