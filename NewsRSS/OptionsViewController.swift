//
//  OptionsViewController.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    @IBOutlet var feedTableView:UITableView!
    @IBOutlet var loadingView:UIView!
    var editButton:UIBarButtonItem?

    //MARK: iOS Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit and Add buttons
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addFeedButtonClicked:")
        editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editButtonClicked:")
        let buttonAr = [editButton!, addButton]
        
        self.navigationItem.setRightBarButtonItems(buttonAr, animated: true)
    }
    
    
    //MARK: Interface actions
    func addFeedButtonClicked(sender: AnyObject) {
        if feedTableView.editing { // Stop editing and do button title
            editButtonClicked(self)
        }

        // Show alert with URL box (Name comes from feed itself when downloaded!)
        let alert = UIAlertController(title: "Enter feed URL", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Feed URL"
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in }
        
        // Add
        let addAction = UIAlertAction(title: "Add", style: .Default) { (action) -> Void in
            if let url = alert.textFields![0].text {
                self.testAndSave(url)
            }
            else {
                self.inputError("URL can not be empty!")
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true) { () -> Void in }
    }
    
    // Sets tableview in editing mode and changes button title
    func editButtonClicked(sender: AnyObject) {
        feedTableView.setEditing(!feedTableView.editing, animated: true)
        editButton?.title = feedTableView.editing ? "Done" : "Edit"
    }
    
    
    //MARK: Add
    // Show error and try again
    func inputError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.addFeedButtonClicked(self)
        }
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: { () -> Void in })
    }
    
    // Feed added, success!
    func feedAdded() {
        let alert = UIAlertController(title: "Success", message: "Feed was added successfully!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in }
        let enableAction = UIAlertAction(title: "Enable feed", style: .Default) { (action) -> Void in
            let newFeed = FeedManager.sharedManger.feeds.last
            newFeed?.isFeedOn = true
            
            FeedManager.sharedManger.saveAll()
            self.feedTableView.reloadData()
        }
        
        alert.addAction(okAction)
        alert.addAction(enableAction)
        presentViewController(alert, animated: true) { () -> Void in }
    }
    
    // Tests URL and saves if valid, if not, present error
    func testAndSave(URLString: String) {
        self.loadingView.hidden = false
        
        let testingFeed = Feed(title: "testingFeed", URL: NSURL(string: URLString)!, isOn: false, isStandard: false)
        testingFeed.getFeedItems({ (items) -> Void in
                print("Hentet fra feed: \(testingFeed.feedTitle)")
            }) { (reason) -> Void in
                
        }
    }
    
    //MARK: UITableView delegate & datasource
    func tableView(_tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        feed.isFeedOn = !feed.isFeedOn
        
        if feed.isFeedOn! {
            _tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
        else {
            _tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        }
        
        _tableView.deselectRowAtIndexPath(indexPath, animated: true)
        FeedManager.sharedManger.saveAll()
    }
    
    func tableView(_tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = _tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        
        if feed.isFeedOn! {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        cell.textLabel?.text = feed.feedTitle
        
        return cell
    }
    
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FeedManager.sharedManger.feeds.count
    }
    
    func tableView(_tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        if feed.isFeedStandard! {
            return .None
        }
        
        return .Delete
    }
    
    func tableView(_tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        return !feed.isFeedStandard
    }
    
    func tableView(_tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let feed = FeedManager.sharedManger.feeds[indexPath.row]
            FeedManager.sharedManger.removeFeed(feed)
            
            feedTableView.reloadData()
        }
    }
}
