//
//  Tweet.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import Foundation
import CoreData

@objc(Tweet)

class Tweet: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var expanded_url: String
    @NSManaged var created_at: NSDate
    @NSManaged var saved_at: NSDate
    @NSManaged var id: NSNumber
    @NSManaged var includesPhotos: NSSet

}
