//
//  TWSavedTableViewController.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import CoreData

class TWSavedTableViewController: TWTweetsTableViewController, NSFetchedResultsControllerDelegate {

    var frc: NSFetchedResultsController!
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Tweets"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IconPhotos"), style: .Plain) { _ in
            var layout = ZLBalancedFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            var photosViewController = TWPhotosCollectionViewController(collectionViewLayout: layout)
            self.navigationController?.pushViewController(photosViewController, animated: true)
            return
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search) {_ in
            var searchTableViewController = TWSearchTableViewController(style: .Plain)
            searchTableViewController.modalTransitionStyle = .CrossDissolve
            var searchNav = UINavigationController(rootViewController: searchTableViewController)
            self.presentViewController(searchNav, animated: true, completion: nil)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext!

        let fetchRequest = NSFetchRequest(entityName:"Tweet")
        let dateSort = NSSortDescriptor(key: "saved_at", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        var error: NSError?
        if !frc.performFetch(&error) {
            println(error)
        }
    }
    
    
    // MARK: - NSFetchedResultControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if type == .Delete {
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        } else if type == .Insert {
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numOfRows = self.frc.sections?[section].numberOfObjects {
            return numOfRows
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {                var cell: TWTweetTableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? TWTweetTableViewCell
        if cell == nil {
            cell = TWTweetTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        if let tweet = frc.objectAtIndexPath(indexPath) as? Tweet {
            cell.setupWithTweet(tweet)
        }
        
        cell.defaultColor = UIColor(red: 227.0 / 255.0, green: 227.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
        let greenColor = UIColor(red: 232.0 / 255.0, green: 61.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
        let saveView = viewWithImageNamed("IconTrashSelected");
        
        cell.setSwipeGestureWithView(saveView, color: greenColor, mode: .Exit, state: .State3) { cell, state, mode in
            // get the actual indexPath
            if let indexPath = self.tableView.indexPathForCell(cell) {
                var tweet = self.frc.objectAtIndexPath(indexPath) as Tweet
                self.managedObjectContext.deleteObject(tweet)
                if tweet.deleted {
                    var error: NSError?
                    if !self.managedObjectContext.save(&error) {
                        println(error)
                    }
                }
            }
        }

        return cell
    }

    
}
