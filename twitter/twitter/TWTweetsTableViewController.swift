//
//  TWTweetsTableViewController.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import SVWebViewController

let cellIdentifier = "cell identifier"

class TWTweetsTableViewController: UITableViewController {
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    func setup() {
        tableView.rowHeight = TWTweetTableViewCell.heightForCell()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var tableViewCell = tableView.cellForRowAtIndexPath(indexPath) as TWTweetTableViewCell
        let url = tableViewCell.expanded_url
        if url != "" {
            var webView = SVWebViewController(address: url)
            self.navigationController?.pushViewController(webView, animated: true)
        }
    }
    
}
