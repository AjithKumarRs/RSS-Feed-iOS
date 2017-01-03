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
        let defs = NSUserDefaults.standardUserDefaults()
        
        if let defaults:Array<NSData> = defs.valueForKey("Default") as? Array<NSData> {
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
        let defs = NSUserDefaults.standardUserDefaults()
        if let userFeeds:Array<NSData> = defs.valueForKey("User") as? Array<NSData> {
            for data in userFeeds {
                let unarc = NSKeyedUnarchiver(forReadingWithData: data)
                let feed = unarc.decodeObjectForKey("root") as! Feed
                
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
            let content = try String(contentsOfFile: NSBundle.mainBundle().pathForResource("Defaults", ofType: "txt")!, encoding: NSUTF8StringEncoding)
            let lines = content.componentsSeparatedByString("\n")
            for line in lines {
                let lineSplit = line.componentsSeparatedByString(";")
                let title = lineSplit[0]
                let URL = lineSplit[1]
                
                let thisFeed = Feed(title: title, URL: NSURL(string: URL)!, isOn: false, isStandard: true)
                defaultArray.append(thisFeed)
            }
        }
        catch _ {
        }
        
        feeds.insertContentsOf(defaultArray, at: 0)
        saveAll()
    }
    
    // Loads the default feeds
    func loadDefaults(defaults: Array<NSData>) {
        for data in defaults {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data)
            let feed = unarc.decodeObjectForKey("root") as! Feed
            
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
        var defaults:Array<NSData> = Array()
        var userCreated:Array<NSData> = Array()
        
        // Add feeds to array
        for feed in feeds {
            let feedData = NSKeyedArchiver.archivedDataWithRootObject(feed)
            
            if feed.isFeedStandard! {
                defaults.append(feedData)
            }
            else {
                userCreated.append(feedData)
            }
        }
        
        // Save!
        let defs = NSUserDefaults.standardUserDefaults()
        defs.setValue(defaults, forKey: "Default")
        defs.setValue(userCreated, forKey: "User")
        defs.synchronize()
    }
    
    
    //MARK: Modifying / adding / deleting feeds
    // Removes feed
    func removeFeed(feedToRemove: Feed) {
        var removeIndex = -1
        for index in 0 ... feeds.count {
            if feeds[index] == feedToRemove {
                removeIndex = index
                break
            }
        }
        
        if removeIndex != -1 {
            feeds.removeAtIndex(removeIndex)
            saveAll()
        }
    }
    
    func addFeed(newFeed: Feed) {
        feeds.append(newFeed)
        saveAll()
    }
}