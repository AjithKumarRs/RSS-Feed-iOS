//
//  ViewController.swift
//  NewsRSS
//
//  Created by Christian on 09/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import UIKit

class FeedListViewController: UIViewController {
    @IBOutlet var feedListTableView:UITableView!
    var selectedFeed:Feed?
    
    //MARK: iOS Views
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        feedListTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject?) {
        if segue.identifier == "ShowFeed" {
            let dest = segue.destinationViewController as? FeedItemListTableViewController
            dest!.feedToShow = selectedFeed
        }
    }
    
    
    //MARK: Segues
    
    func showAllFeeds() {
        // No feeds enabled
        if FeedManager.sharedManger.enabledFeeds().count == 0 {
            let alert = UIAlertController(title: "Error", message: "You have to enable some sites first!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: { () -> Void in })
            return
        }
        
        selectedFeed = nil // selectedFeed to nil, should it be something else
        performSegueWithIdentifier("ShowFeed", sender: self)
    }
    
    func showFeed(feed: Feed) {
        selectedFeed = feed
        performSegueWithIdentifier("ShowFeed", sender: self)
    }
    
    @IBAction func showOptions(sender: AnyObject) {
        performSegueWithIdentifier("ShowOptions", sender: self)
    }

    
    //MARK: UITableView delegate & datasource
    func tableView(_tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            showAllFeeds()
        }
        else {
            showFeed(FeedManager.sharedManger.feeds[indexPath.row])
        }
        
        _tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(_tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = _tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.accessoryType = .DisclosureIndicator
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "My sites"
        }
        else {
            let feed = FeedManager.sharedManger.feeds[indexPath.row]
            cell.textLabel?.text = feed.feedTitle
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return FeedManager.sharedManger.feeds.count
    }
    
    func tableView( tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        
        return "Sites"
    }
    
    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60 // 'My sites' is larger than normal cell
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return UITableViewAutomaticDimension
    }
}

