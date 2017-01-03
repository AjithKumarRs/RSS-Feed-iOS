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
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(OptionsViewController.addFeedButtonClicked(_:)))
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(OptionsViewController.editButtonClicked(_:)))
        let buttonAr = [editButton!, addButton]
        
        self.navigationItem.setRightBarButtonItems(buttonAr, animated: true)
    }
    
    
    //MARK: Interface actions
    func addFeedButtonClicked(_ sender: AnyObject) {
        if feedTableView.isEditing { // Stop editing and do button title
            editButtonClicked(self)
        }

        // Show alert with URL box (Name comes from feed itself when downloaded!)
        let alert = UIAlertController(title: "Enter feed URL", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Feed URL"
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        // Add
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) -> Void in
            if let url = alert.textFields![0].text {
                self.testAndSave(url)
            }
            else {
                self.inputError("URL can not be empty!")
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true) { () -> Void in }
    }
    
    // Sets tableview in editing mode and changes button title
    func editButtonClicked(_ sender: AnyObject) {
        feedTableView.setEditing(!feedTableView.isEditing, animated: true)
        editButton?.title = feedTableView.isEditing ? "Done" : "Edit"
    }
    
    
    //MARK: Add
    // Show error and try again
    func inputError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
            self.addFeedButtonClicked(self)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: { () -> Void in })
    }
    
    // Feed added, success!
    func feedAdded() {
        let alert = UIAlertController(title: "Success", message: "Feed was added successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in }
        let enableAction = UIAlertAction(title: "Enable feed", style: .default) { (action) -> Void in
            let newFeed = FeedManager.sharedManger.feeds.last
            newFeed?.isFeedOn = true
            
            FeedManager.sharedManger.saveAll()
            self.feedTableView.reloadData()
        }
        
        alert.addAction(okAction)
        alert.addAction(enableAction)
        present(alert, animated: true) { () -> Void in }
    }
    
    // Tests URL and saves if valid, if not, present error
    func testAndSave(_ URLString: String) {
        self.loadingView.isHidden = false
        
        let testingFeed = Feed(title: "testingFeed", URL: URL(string: URLString)!, isOn: false, isStandard: false)
        testingFeed.getFeedItems({ (items) -> Void in
                print("Hentet fra feed: \(testingFeed.feedTitle)")
            }) { (reason) -> Void in
                
        }
    }
    
    //MARK: UITableView delegate & datasource
    func tableView(_ _tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        feed.isFeedOn = !feed.isFeedOn
        
        if feed.isFeedOn! {
            _tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        else {
            _tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
        _tableView.deselectRow(at: indexPath, animated: true)
        FeedManager.sharedManger.saveAll()
    }
    
    func tableView(_ _tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = _tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        
        if feed.isFeedOn! {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = feed.feedTitle
        
        return cell
    }
    
    func numberOfSectionsInTableView(_ _tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ _tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FeedManager.sharedManger.feeds.count
    }
    
    func tableView(_ _tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        if feed.isFeedStandard! {
            return .none
        }
        
        return .delete
    }
    
    func tableView(_ _tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_ _tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        let feed = FeedManager.sharedManger.feeds[indexPath.row]
        return !feed.isFeedStandard
    }
    
    func tableView(_ _tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            let feed = FeedManager.sharedManger.feeds[indexPath.row]
            FeedManager.sharedManger.removeFeed(feed)
            
            feedTableView.reloadData()
        }
    }
}
