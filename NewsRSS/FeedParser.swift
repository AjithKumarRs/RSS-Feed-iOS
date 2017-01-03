//
//  FeedParser.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import UIKit

class FeedParser: NSObject, XMLParserDelegate {
    var parser = XMLParser()
    
    var items:Array<FeedItem>?
    var currentItem:FeedItem?
    
    var feedTitle:String?
    var currentElement:String?
    var currentElementData:String?
    
    var data:Data!
    
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?
    
    init(data: Data) {
        super.init()
        self.data = data
    }
    
    func parse(_ onSuccess: @escaping (() -> Void), onFailure:@escaping ((_ reason: String) -> Void)) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        
        items = []
        currentItem = FeedItem()

        parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
    }
    
    //MARK: NSXMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "channel" || elementName == "item" { // We only care about items or channels here
            self.currentElement = elementName
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.currentElementData == nil {
            self.currentElementData = ""
        }
        
        self.currentElementData? += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" { // Item done
            currentItem?.sanitize()
            self.items?.append(currentItem!)
            self.currentItem = FeedItem()
        }
        else if elementName == "title" { // Title done
            if self.currentElement == "channel" {
                self.feedTitle = self.currentElementData
            }
            else if self.currentElement == "item" {
                self.currentItem?.title = self.currentElementData
            }
        }
        else if elementName == "link" { // Link done
            if self.currentElement == "item" {
                self.currentItem?.link = self.currentElementData
            }
        }
        else if elementName == "pubDate" { // Date
            if self.currentElement == "item" {
                self.currentItem?.setDate(self.currentElementData)
            }
        }
        else if elementName == "description" { // Description done
            if self.currentElement == "item" {
                self.currentItem?.itemDescription = self.currentElementData
            }
        }
        
        self.currentElementData = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.onFailure?("Error parsing XML")
    }
    
    func parserDidEndDocument(_ _parser: XMLParser) {
        self.onSuccess?()
    }

}
