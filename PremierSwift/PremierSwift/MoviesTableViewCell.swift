//
//  MoviesTableViewCell.swift
//  PremierSwift
//
//  Created by Richard Pickup on 04/11/2016.
//  Copyright © 2016 Deliveroo. All rights reserved.
//

import UIKit

import Kingfisher

class MoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func didEndDisplaying() {
        self.posterImage.kf.cancelDownloadTask()
    }
    
    
    func setImage(urlString: String) {
        
        let imageURL = URL(string: urlString)
        
        self.posterImage.kf.indicatorType = .activity
        self.posterImage.kf.setImage(with: imageURL,
                                     placeholder: nil,
                                     options: [.transition(ImageTransition.fade(1)), .forceTransition],
                                     progressBlock: { receivedSize, totalSize in
                                        //print("\(receivedSize)/\(totalSize)")
            },
                                     completionHandler: { image, error, cacheType, imageURL in
                                        self.posterImage.sizeToFit()
                                       // print(" Finished")
        })
    }
    

}
