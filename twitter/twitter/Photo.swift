//
//  Photo.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var sizeH: NSNumber
    @NSManaged var sizeW: NSNumber
    @NSManaged var includedBy: Tweet

}
