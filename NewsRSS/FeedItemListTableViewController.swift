//
//  FeedItemListTableViewController.swift
//  NewsRSS
//
//  Created by Christian on 10/12/2015.
//  Copyright © 2015 Christian Lundtofte Sørensen. All rights reserved.
//

import UIKit
import SafariServices

class FeedItemListTableViewController: UITableViewController, SFSafariViewControllerDelegate {
    var feedToShow:Feed?
    var feedItems:Array<FeedItem>?
    var detailFormatter:NSDateFormatter?
    
    var loadingView:UIView!

    // MARK: iOS Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoadingView()
        
        if let title = self.feedToShow?.feedTitle {
            self.title = title
        }
        else {
            self.title = "My sites"
        }
        
    
        self.detailFormatter = NSDateFormatter()
        self.detailFormatter?.dateFormat = "EEEE 'kl.' HH:mm" // Mandag kl. 13:37
        
        loadFeedItems()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.loadingView.removeFromSuperview() // Cleanup!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Interface
    func addLoadingView() {
        // Ugly hack from StackOverflow, but hey, it works!
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        loadingView.backgroundColor = UIColor.whiteColor()
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        loadingIndicator.color = UIColor.blackColor()
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingIndicator.startAnimating()
        
        self.navigationController?.view.insertSubview(loadingView, belowSubview: (self.navigationController?.navigationBar)!)
    }
    
    // MARK: Feeds
    @IBAction func refreshFeed(sender: AnyObject) {
        self.feedItems?.removeAll()
        loadFeedItems()
        
        if sender is UIRefreshControl {
            (sender as? UIRefreshControl)?.endRefreshing()
        }
    }
    
    func showError() {
        print("Error")
    }
    
    func loadFeedItems() {
        self.loadingView.hidden = false
        self.view.bringSubviewToFront(self.loadingView)
        
        if self.feedToShow != nil { // Normal feed
            print("Loading normal feed")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                self.feedToShow?.getFeedItems({ (items) -> Void in
                    self.feedItems = items
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        self.loadingView.hidden = true
                    })
                    
                    }, onFailure: { (reason) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.showError()
                        })
                })
            })
        }
        else { // All enabled feeds
            print("Loading all enabled feeds.")
            
            let enabledFeeds = FeedManager.sharedManger.enabledFeeds()
            var tempDownloadedItems:Array<FeedItem> = Array()
            var currentRunningDownloads = 0
            
            // Download items from all feeds
            for feed in enabledFeeds {
                currentRunningDownloads += 1
                print("Download started")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    feed.getFeedItems({ (items) -> Void in
                            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                                print("Download done")
                                
                                tempDownloadedItems.appendContentsOf(items)
                                currentRunningDownloads -= 1
                                
                                if currentRunningDownloads == 0 {
                                    self.completedLoad(tempDownloadedItems)
                                }
                            })
                        },
                        onFailure: { (reason) -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.showError()
                            })
                    })
                })
            }
        }
        
        if self.feedItems != nil {
            self.tableView.reloadData()
        }
    }
    
    func completedLoad(downloadedItems: Array<FeedItem>) {
        // Sort and load!
        let sortedItems = downloadedItems.sort({ $0.pubDate!.compare($1.pubDate!) == NSComparisonResult.OrderedAscending })
        self.feedItems = sortedItems.reverse()
        
        self.loadingView.hidden = true
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feedItem = self.feedItems![indexPath.row]
        
        let vc = SFSafariViewController(URL: NSURL(string: feedItem.link!)!)
        vc.delegate = self
        presentViewController(vc, animated: true) { () -> Void in }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.feedItems != nil {
            return 1
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedItems != nil {
            return self.feedItems!.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let feedItem = self.feedItems?[indexPath.row]
        cell.textLabel?.text = feedItem?.title
        cell.accessoryType = .DisclosureIndicator
        
        var detailText = self.detailFormatter?.stringFromDate((feedItem?.pubDate)!)
        
        if self.feedToShow == nil { // If in 'My sites', show item website
            detailText! += " - " + (feedItem?.ownerFeed)!
        }
        
        cell.detailTextLabel?.text = detailText
        return cell
    }
    
    
    // MARK: SFSafariWebViewDelegate
    func safariViewController(_controller: SFSafariViewController,
        didCompleteInitialLoad didLoadSuccessfully: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func safariViewControllerDidFinish(_controller: SFSafariViewController) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
