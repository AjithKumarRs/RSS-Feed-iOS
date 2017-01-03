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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        feedListTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "ShowFeed" {
            let dest = segue.destination as? FeedItemListTableViewController
            dest!.feedToShow = selectedFeed
        }
    }
    
    
    //MARK: Segues
    
    func showAllFeeds() {
        // No feeds enabled
        if FeedManager.sharedManger.enabledFeeds().count == 0 {
            let alert = UIAlertController(title: "Error", message: "You have to enable some sites first!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in })
            alert.addAction(action)
            self.present(alert, animated: true, completion: { () -> Void in })
            return
        }
        
        selectedFeed = nil // selectedFeed to nil, should it be something else
        performSegue(withIdentifier: "ShowFeed", sender: self)
    }
    
    func showFeed(_ feed: Feed) {
        selectedFeed = feed
        performSegue(withIdentifier: "ShowFeed", sender: self)
    }
    
    @IBAction func showOptions(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowOptions", sender: self)
    }

    
    //MARK: UITableView delegate & datasource
    func tableView(_ _tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if indexPath.section == 0 {
            showAllFeeds()
        }
        else {
            showFeed(FeedManager.sharedManger.feeds[indexPath.row])
        }
        
        _tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ _tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = _tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "My sites"
        }
        else {
            let feed = FeedManager.sharedManger.feeds[indexPath.row]
            cell.textLabel?.text = feed.feedTitle
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(_ _tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ _tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return FeedManager.sharedManger.feeds.count
    }
    
    func tableView( _ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        
        return "Sites"
    }
    
    func tableView(_ _tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60 // 'My sites' is larger than normal cell
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ _tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return UITableViewAutomaticDimension
    }
}

