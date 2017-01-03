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
    var pubDate:Date?
    var ownerFeed:String?
    
    func setDate(_ dateString: String?) {
        if let date = dateString {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en") // Required on non-english devices, apparently
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
            
            self.pubDate = formatter.date(from: date)
        }
    }
    
    // Apparently newlines and spaces are acceptable in titles and links
    func sanitize() {
        var tempTitle = self.title!
        tempTitle = tempTitle.replacingOccurrences(of: "\n", with: "")
        tempTitle = tempTitle.replacingOccurrences(of: "\t", with: "")
        tempTitle = tempTitle.replacingOccurrences(of: "  ", with: "")
        
        var tempLink = self.link!
        tempLink = tempLink.replacingOccurrences(of: "\n", with: "")
        tempLink = tempLink.replacingOccurrences(of: "\t", with: "")
        tempLink = tempLink.replacingOccurrences(of: "  ", with: "")
        
        self.title = tempTitle
        self.link = tempLink
    }
}
