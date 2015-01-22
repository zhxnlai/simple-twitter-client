//
//  TWSearchTableViewController.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import Accounts
import Social
import ReactiveUI
import SwiftyJSON
import CoreData

class TWSearchTableViewController: TWTweetsTableViewController, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var managedObjectContext: NSManagedObjectContext!
    var twitterAccount: ACAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "Search for Tweets"
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel) {_ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext!
        
        var accountStore = ACAccountStore()
        var accountTypeTwitter = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountTypeTwitter, options: nil) { granted, error in
            if error == nil {
                if granted {
                    if let account = accountStore.accountsWithAccountType(accountTypeTwitter).first as? ACAccount {
                        self.twitterAccount = account
                        dispatch_async(dispatch_get_main_queue()) {
                            self.searchBar.becomeFirstResponder()
                            return
                        }
                    } else {
                        println("no twitter account avialable")
                        let alertController = UIAlertController(title: "No Twitter account available", message: "No Twitter account is currently available. Go to settings -> Twitter to login or create one.", preferredStyle: .Alert)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        alertController.addAction(cancelAction)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { action in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        alertController.addAction(OKAction)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Access not granted", message: "Twitter access is not granted. Go to settings -> Twitter to enable it. Do you want to do it now?", preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertController.addAction(cancelAction)
                    
                    let OKAction = UIAlertAction(title: "Sure", style: .Default) { action in
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertController.addAction(OKAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(error)
            }
        }
    }

    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        resetRequest()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "sendRequest", userInfo: nil, repeats: false)
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var bottomY = scrollView.contentOffset.y + scrollView.bounds.height - scrollView.contentInset.bottom
        if scrollView.contentSize.height <= bottomY + TWTweetTableViewCell.heightForCell() {
            sendRequest()
        }
    }
    
    // MARK: - SLRequest

    var sinceId = -1
    var maxId = 0
    var loading = false
    var results = [JSON]()
    var timer: NSTimer?

    func resetRequest() {
        sinceId = -1
        maxId = 0
        loading = false
        results = [JSON]()
        timer?.invalidate()
    }
    
    func sendRequest() {
        if loading || maxId == sinceId {
            return
        }
        
        var url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        var parameters = [
            "max_id": maxId,
            "since_id": sinceId,
            "q": searchBar.text
        ]
        sinceId = maxId

        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: parameters)
        request.account = twitterAccount
        
        loading = true
        request.performRequestWithHandler({ data, response, error in
            if error == nil {
                let result = JSON(data: data)
                self.results.append(result)
                self.sinceId = result["search_metadata"]["max_id"].intValue
                if let next_url = result["search_metadata"]["next_results"].string {
                    self.maxId = next_url.substringFromIndex(advance(next_url.startIndex, 1)).componentsSeparatedByString("&").reduce(0, {
                        acc, s in
                        var pair = s.componentsSeparatedByString("=")
                        if pair.first! == "max_id" {
                            return Int(NSNumberFormatter().numberFromString(pair.last!)!)
                        } else {
                            return acc
                        }
                    })
                }
                
                // println("since: \(self.sinceId) max: \(self.maxId)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.loading = false
                }
            } else {
                println(error)
            }
        })
    }
    
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results[section]["statuses"].arrayValue.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TWTweetTableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? TWTweetTableViewCell
        if cell == nil {
            cell = TWTweetTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        let json = results[indexPath.section]["statuses"][indexPath.row]
        cell.setupWithJSON(json)
        
        cell.defaultColor = UIColor(red: 227.0 / 255.0, green: 227.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
        let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        let saveView = viewWithImageNamed("IconDownloadSelected");
 
        cell.setSwipeGestureWithView(saveView, color: greenColor, mode: .Switch, state: .State3) { cell, state, mode in
            self.saveTweet(json)
            return
        }
        
        return cell
    }
    
    // MARK: - ()
    
    func saveTweet(json: JSON) {
        let (succeed, message) = Tweet.addTweetFromJSON(json, toManagedObjectContext: managedObjectContext)
        if succeed {
            var error: NSError?
            if !managedObjectContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        } else {
            let alertController = UIAlertController(title: "Cannot save Tweet", message: message, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { action in
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }

}
