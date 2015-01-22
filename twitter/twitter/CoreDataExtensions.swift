//
//  Tweet+Init.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Tweet {
    
    func addPhotoObject(photo: Photo) {
        self.mutableSetValueForKey("includesPhotos").addObject(photo)
    }

    class func addTweetFromJSON(json: JSON, toManagedObjectContext managedObjectContext: NSManagedObjectContext) -> (Bool, String) {
        
        let id = NSNumber(integer: json["id"].intValue)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Tweet")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        var error: NSError?
        if let matches = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
            if matches.count > 0 {
                return (false, "The tweet has been saved already.")
            } else {
                if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: managedObjectContext) as? Tweet {
                    tweet.id = json["id"].intValue
                    tweet.text = json["text"].stringValue
                    let dateString = json["created_at"].stringValue
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
                    if let date = dateFormatter.dateFromString(dateString) {
                        tweet.created_at = date
                    }
                    tweet.saved_at = NSDate()
                    
                    if let url = json["entities"]["urls"].arrayValue.first?["expanded_url"].string {
                        tweet.expanded_url = url
                    } else {
                        tweet.expanded_url = ""
                    }
                    
                    let media = json["entities"]["media"].arrayValue.filter({$0["type"].stringValue == "photo"})
                    Photo.addPhotosFromJSONs(media, tweet: tweet, toManagedObjectContext: managedObjectContext)
                } else {
                    println("failed to create tweet")
                    return (false, "failed to create tweet")
                }
            }
        } else {
            println(error)
            return (false, "error: \(error)")
        }
        
        return (true, "successful")
    }
    
}


extension Photo {
    
    class func addPhotosFromJSONs(jsons: [JSON], tweet: Tweet,toManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        for media in jsons {
            if let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: managedObjectContext) as? Photo {
                photo.url = media["media_url"].stringValue
                var numberFormatter = NSNumberFormatter()
                if let sizeW = numberFormatter.numberFromString(media["sizes"]["medium"]["w"].stringValue) {
                    photo.sizeW = sizeW.doubleValue
                }
                if let sizeH = numberFormatter.numberFromString(media["sizes"]["medium"]["h"].stringValue) {
                    photo.sizeH = sizeH.doubleValue
                }
                tweet.addPhotoObject(photo)
            }
        }
    }
    
}