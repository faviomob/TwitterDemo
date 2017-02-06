//
//  TweetTableViewCell.swift
//  TwitterDemo
//
//  Created by Marat on 04/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var profileImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewLeft: NSLayoutConstraint!

    var showAvatar = true
    
    var tweet: Tweet! {
        didSet {
            self.profileImageViewWidth.constant = showAvatar ? 51 : 1
            self.profileImageViewHeight.constant = showAvatar ? 51 : 1
            self.profileImageViewLeft.constant = showAvatar ? 11 : 1
            self.profileImageView.image = nil
            if showAvatar {
                if let avatarNormalUrl = tweet.author?.avatarNormalUrl {
                    self.profileImageView.setImageWith(URL(string: avatarNormalUrl)!)
                }
            }
            self.tweetTextLabel.text = tweet.text ?? "<Empty tweet>"
            self.nameLabel.text = tweet.author?.name ?? "<Author>"
            self.dateLabel.text = tweet.timeAgoString ?? "--s"
        }
    }
}
