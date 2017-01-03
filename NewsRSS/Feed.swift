//
//  Feed.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import Foundation

class Feed : NSObject, NSCoding, URLSessionDelegate {
    var feedTitle:String!
    var feedURL:URL!
    var isFeedOn:Bool!
    var isFeedStandard:Bool!
    
    // MARK: Constructors
    init(title: String, URL: Foundation.URL, isOn: Bool, isStandard: Bool) {
        super.init()
        
        self.feedTitle = title
        self.feedURL = URL
        self.isFeedOn = isOn
        self.isFeedStandard = isStandard
        
        self.sanitize()
    }
    
    init(title: String, URL: Foundation.URL) { // When creating a new site
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
        tempTitle = tempTitle?.replacingOccurrences(of: "\n", with: "")
        
        self.feedTitle = tempTitle
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObject(forKey: "Title") as? String {
            self.feedTitle = title
        }
        if let feedURL = aDecoder.decodeObject(forKey: "URL") as? URL {
            self.feedURL = feedURL
        }
        if let isOn = aDecoder.decodeObject(forKey: "IsOn") as? Bool {
            self.isFeedOn = isOn
        }
        if let isStandard = aDecoder.decodeObject(forKey: "IsStandard") as? Bool {
            self.isFeedStandard = isStandard
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let feedTitle = self.feedTitle {
            aCoder.encode(feedTitle, forKey: "Title")
        }
        if let feedURL = self.feedURL {
            aCoder.encode(feedURL, forKey: "URL")
        }
        if let isOn = self.isFeedOn {
            aCoder.encode(isOn, forKey: "IsOn")
        }
        if let isStandard = self.isFeedStandard {
            aCoder.encode(isStandard, forKey: "IsStandard")
        }
    }
    
    // MARK: FeedItems
    var onDownloadSuccess: ((Array<FeedItem>) -> Void)?
    var onDownloadFailure: ((String) -> Void)?
    var downloadedData:NSMutableData?
    
    func getFeedItems(_ onSuccess: @escaping ((Array<FeedItem>) -> Void), onFailure:@escaping ((_ reason: String) -> Void)) -> Void {
        
        onDownloadSuccess = onSuccess
        onDownloadFailure = onFailure
        
        downloadedData = NSMutableData()
        
        print("Starter feed download")
        let defaultConfig = URLSessionConfiguration.default
        let defaultSession = Foundation.URLSession(configuration: defaultConfig, delegate: self, delegateQueue: OperationQueue.current)
        let dataTask = defaultSession.dataTask(with: self.feedURL)
        dataTask.resume()
        print("Task started!")
    }
    
    // MARK: NSURLSession stuff
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didBecomeDownloadTask downloadTask: URLSessionDownloadTask) {
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            onDownloadFailure?("Network error")
        }
        else {
            if downloadedData == nil {
                onDownloadFailure?("Network error")
            }
            else { // Data successfully downloaded!
                
                let xmlString = NSString(data: downloadedData! as Data, encoding: String.Encoding.utf8.rawValue)
                print("XMLString: \(xmlString)")
                
                let parser = FeedParser(data: downloadedData! as Data)
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
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        print("AuthenticationChallenge!")
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if error != nil {
            onDownloadFailure?("Network error")
        }
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        downloadedData?.append(data)
    }
    

}
