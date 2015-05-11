//
//  ProfileHeaderCell.swift
//  Yep
//
//  Created by NIX on 15/3/18.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithMyInfo() {
        YepUserDefaults.avatarURLString.bindAndFireListener("ProfileHeaderCell.Avatar") { avatarURLString in
            if let avatarURLString = avatarURLString {
                self.updateAvatarWithAvatarURLString(avatarURLString)
            }
        }

        YepLocationService.sharedManager // TODO: 要迁走

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAddress", name: "YepLocationUpdated", object: nil)
    }

    func configureWithDiscoveredUser(discoveredUser: DiscoveredUser) {
        updateAvatarWithAvatarURLString(discoveredUser.avatarURLString)

        let location = CLLocation(latitude: discoveredUser.latitude, longitude: discoveredUser.longitude)

        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in

            if (error != nil) {
                println("reverse geodcode fail: \(error.localizedDescription)")
            }

            if let placemarks = placemarks as? [CLPlacemark] {
                if let firstPlacemark = placemarks.first {
                    self.locationLabel.text = firstPlacemark.locality
                }
            }
        })
    }

    func configureWithUser(user: User) {
        updateAvatarWithAvatarURLString(user.avatarURLString)

        // TODO: User Location
    }

    func updateAvatarWithAvatarURLString(avatarURLString: String) {
        avatarImageView.alpha = 0

        AvatarCache.sharedInstance.avatarFromURL(NSURL(string: avatarURLString)!) { image in
            dispatch_async(dispatch_get_main_queue()) {
                self.avatarImageView.image = image
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                    self.avatarImageView.alpha = 1
                }, completion: { (finished) -> Void in
                })
            }
        }
    }
    
    func updateAddress() {
        
//        println("Location YepLocationUpdated")
        
        self.locationLabel.text = YepLocationService.sharedManager.address
    }
    
}
