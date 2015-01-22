//
//  TWUtilties.swift
//  twitter
//
//  Created by Zhixuan Lai on 1/20/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

func viewWithImageNamed(imageName: String) -> UIView? {
    if let image = UIImage(named: imageName) {
        var imageView = UIImageView(image: image.imageWithRenderingMode(.AlwaysTemplate))
        imageView.tintColor = UIColor.whiteColor()
        imageView.contentMode = .Center
        return imageView
    }
    return nil
}