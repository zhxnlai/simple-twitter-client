//
//  TWPhotosCollectionViewController.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/21/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "Cell"

class TWPhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    var frc: NSFetchedResultsController!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos from saved Tweets"
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Photo")
        let dateSort = NSSortDescriptor(key: "includedBy.saved_at", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        var error: NSError?
        if !frc.performFetch(&error) {
            println(error)
        }

    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfRows = self.frc.sections?[section].numberOfObjects {
            return numOfRows
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        if let photo = frc.objectAtIndexPath(indexPath) as? Photo {
            var imageView = UIImageView()
            imageView.sd_setImageWithURL(NSURL(string: photo.url), placeholderImage: UIImage(named: "placeholder"))
            imageView.contentMode = .ScaleAspectFill
            cell.backgroundView = imageView
            cell.clipsToBounds = true
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let photo = frc.objectAtIndexPath(indexPath) as? Photo {
            return CGSize(width: photo.sizeW.doubleValue, height: photo.sizeH.doubleValue)
        }
        return CGSizeZero
    }

}
