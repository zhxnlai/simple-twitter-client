//
//  TWTweetTableViewCell.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import SwiftyJSON
import MCSwipeTableViewCell
import CoreData

class TWTweetTableViewCell: MCSwipeTableViewCell {
    
    var expanded_url: String?
    var imageURL: String? {
        didSet {
            if let url = imageURL {
                imageView?.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "placeholder")) {
                    image, error, cacheType, imageURL in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                    }
                }
            } else {
                imageView?.image = nil
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        imageView?.contentMode = .ScaleAspectFill
        textLabel?.numberOfLines = 0
    }
    
    func setupWithTweet(tweet: Tweet) {
        textLabel?.text = tweet.text
        if let photo = tweet.includesPhotos.anyObject()? as? Photo {
            imageURL = photo.url
        } else {
            imageURL = nil
        }
        expanded_url = tweet.expanded_url
        accessoryType = expanded_url != "" ? .DisclosureIndicator : .None
    }
    
    func setupWithJSON(json: JSON) {
        if let text = json["text"].string {
            textLabel?.text = text
        } else {
            textLabel?.text = "Text"
        }
        
        imageURL = json["entities"]["media"].arrayValue.filter({$0["type"].stringValue == "photo"}).first?["media_url"].string?

        expanded_url = json["entities"]["urls"].arrayValue.first?["expanded_url"].string
        accessoryType = expanded_url != nil ? .DisclosureIndicator : .None
    }
    
    class func heightForCell() -> CGFloat {
        return 90
    }
    
}
