//
//  Feed.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import Foundation

class Feed : NSObject, NSCoding, NSURLSessionDelegate {
    var feedTitle:String!
    var feedURL:NSURL!
    var isFeedOn:Bool!
    var isFeedStandard:Bool!
    
    // MARK: Constructors
    init(title: String, URL: NSURL, isOn: Bool, isStandard: Bool) {
        super.init()
        
        self.feedTitle = title
        self.feedURL = URL
        self.isFeedOn = isOn
        self.isFeedStandard = isStandard
        
        self.sanitize()
    }
    
    init(title: String, URL: NSURL) { // When creating a new site
        super.init()
        
        self.feedTitle = title
        self.feedURL = URL
        self.isFeedOn = false
        self.isFeedStandard = false
        
        self.sanitize()
    }
    
    // Removes weird stuff (Like newlines in titles..)
    func sanitize() {
        var tempTitle = self.feedTitle
        tempTitle = tempTitle.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        self.feedTitle = tempTitle
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObjectForKey("Title") as? String {
            self.feedTitle = title
        }
        if let feedURL = aDecoder.decodeObjectForKey("URL") as? NSURL {
            self.feedURL = feedURL
        }
        if let isOn = aDecoder.decodeObjectForKey("IsOn") as? Bool {
            self.isFeedOn = isOn
        }
        if let isStandard = aDecoder.decodeObjectForKey("IsStandard") as? Bool {
            self.isFeedStandard = isStandard
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let feedTitle = self.feedTitle {
            aCoder.encodeObject(feedTitle, forKey: "Title")
        }
        if let feedURL = self.feedURL {
            aCoder.encodeObject(feedURL, forKey: "URL")
        }
        if let isOn = self.isFeedOn {
            aCoder.encodeObject(isOn, forKey: "IsOn")
        }
        if let isStandard = self.isFeedStandard {
            aCoder.encodeObject(isStandard, forKey: "IsStandard")
        }
    }
    
    // MARK: FeedItems
    var onDownloadSuccess: ((Array<FeedItem>) -> Void)?
    var onDownloadFailure: ((String) -> Void)?
    var downloadedData:NSMutableData?
    
    func getFeedItems(onSuccess: ((Array<FeedItem>) -> Void), onFailure:((reason: String) -> Void)) -> Void {
        
        onDownloadSuccess = onSuccess
        onDownloadFailure = onFailure
        
        downloadedData = NSMutableData()
        
        print("Starter feed download")
        let defaultConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultSession = NSURLSession(configuration: defaultConfig, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
        let dataTask = defaultSession.dataTaskWithURL(self.feedURL)
        dataTask.resume()
        print("Task started!")
    }
    
    // MARK: NSURLSession stuff
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            onDownloadFailure?("Network error")
        }
        else {
            if downloadedData == nil {
                onDownloadFailure?("Network error")
            }
            else { // Data successfully downloaded!
                
                let xmlString = NSString(data: downloadedData!, encoding: NSUTF8StringEncoding)
                print("XMLString: \(xmlString)")
                
                let parser = FeedParser(data: downloadedData!)
                var feedItems:Array<FeedItem>?
                var tempAr:Array<FeedItem>?
                
                parser.parse({ () -> Void in
                    tempAr = parser.items!
                    }, onFailure: { (error) -> Void in
                        print("Error parsing: \(error)")
                        feedItems = Array()
                })
                
                while tempAr == nil { } // Waaaaait!
                
                feedItems = Array()
                for item in tempAr! {
                    item.ownerFeed = self.feedTitle
                    feedItems?.append(item)
                }
                
                onDownloadSuccess?(feedItems!)
            }
        }
        
        downloadedData = nil
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {

        print("AuthenticationChallenge!")
        completionHandler(.CancelAuthenticationChallenge, nil)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        if error != nil {
            onDownloadFailure?("Network error")
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        downloadedData?.appendData(data)
    }
    

}