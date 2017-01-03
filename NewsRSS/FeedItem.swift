//
//  FeedItem.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import UIKit

class FeedItem: NSObject {
    var title:String?
    var link:String?
    var itemDescription:String?
    var pubDate:NSDate?
    var ownerFeed:String?
    
    func setDate(dateString: String?) {
        if let date = dateString {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en") // Required on non-english devices, apparently
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
            
            self.pubDate = formatter.dateFromString(date)
        }
    }
    
    // Apparently newlines and spaces are acceptable in titles and links
    func sanitize() {
        var tempTitle = self.title!
        tempTitle = tempTitle.stringByReplacingOccurrencesOfString("\n", withString: "")
        tempTitle = tempTitle.stringByReplacingOccurrencesOfString("\t", withString: "")
        tempTitle = tempTitle.stringByReplacingOccurrencesOfString("  ", withString: "")
        
        var tempLink = self.link!
        tempLink = tempLink.stringByReplacingOccurrencesOfString("\n", withString: "")
        tempLink = tempLink.stringByReplacingOccurrencesOfString("\t", withString: "")
        tempLink = tempLink.stringByReplacingOccurrencesOfString("  ", withString: "")
        
        self.title = tempTitle
        self.link = tempLink
    }
}
