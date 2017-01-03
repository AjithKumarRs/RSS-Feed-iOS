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
    var detailFormatter:DateFormatter?
    
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
        
    
        self.detailFormatter = DateFormatter()
        self.detailFormatter?.dateFormat = "EEEE 'kl.' HH:mm" // Mandag kl. 13:37
        
        loadFeedItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        loadingView.backgroundColor = UIColor.white
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingIndicator.color = UIColor.black
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingIndicator.startAnimating()
        
        self.navigationController?.view.insertSubview(loadingView, belowSubview: (self.navigationController?.navigationBar)!)
    }
    
    // MARK: Feeds
    @IBAction func refreshFeed(_ sender: AnyObject) {
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
        self.loadingView.isHidden = false
        self.view.bringSubview(toFront: self.loadingView)
        
        if self.feedToShow != nil { // Normal feed
            print("Loading normal feed")
            
            DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                self.feedToShow?.getFeedItems({ (items) -> Void in
                    self.feedItems = items
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                        self.loadingView.isHidden = true
                    })
                    
                    }, onFailure: { (reason) -> Void in
                        DispatchQueue.main.async(execute: { () -> Void in
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
                
                DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                    feed.getFeedItems({ (items) -> Void in
                            DispatchQueue.main.async(execute: {() -> Void in
                                print("Download done")
                                
                                tempDownloadedItems.append(contentsOf: items)
                                currentRunningDownloads -= 1
                                
                                if currentRunningDownloads == 0 {
                                    self.completedLoad(tempDownloadedItems)
                                }
                            })
                        },
                        onFailure: { (reason) -> Void in
                            DispatchQueue.main.async(execute: { () -> Void in
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
    
    func completedLoad(_ downloadedItems: Array<FeedItem>) {
        // Sort and load!
        let sortedItems = downloadedItems.sorted(by: { $0.pubDate!.compare($1.pubDate! as Date) == ComparisonResult.orderedAscending })
        self.feedItems = sortedItems.reversed()
        
        self.loadingView.isHidden = true
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = self.feedItems![indexPath.row]
        
        let vc = SFSafariViewController(url: URL(string: feedItem.link!)!)
        vc.delegate = self
        present(vc, animated: true) { () -> Void in }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.feedItems != nil {
            return 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedItems != nil {
            return self.feedItems!.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let feedItem = self.feedItems?[indexPath.row]
        cell.textLabel?.text = feedItem?.title
        cell.accessoryType = .disclosureIndicator
        
        var detailText = self.detailFormatter?.string(from: (feedItem?.pubDate)! as Date)
        
        if self.feedToShow == nil { // If in 'My sites', show item website
            detailText! += " - " + (feedItem?.ownerFeed)!
        }
        
        cell.detailTextLabel?.text = detailText
        return cell
    }
    
    
    // MARK: SFSafariWebViewDelegate
    func safariViewController(_ _controller: SFSafariViewController,
        didCompleteInitialLoad didLoadSuccessfully: Bool) {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    func safariViewControllerDidFinish(_ _controller: SFSafariViewController) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
