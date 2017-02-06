//
//  TweetDetailsViewController.swift
//  TwitterDemo
//
//  Created by Marat on 05/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let avatarOriginalUrl = tweet.author?.avatarOriginalUrl {
            self.profileImageView.setImageWith(URL(string: avatarOriginalUrl)!)
        }
        self.tweetTextLabel.text = tweet.text ?? "<Empty tweet>"
        self.nameLabel.text = tweet.author?.name ?? "<Author>"
        self.screenNameLabel.text = "@\(tweet.author!.screenName!)"
        self.dateLabel.text = tweet.timestampString()
        self.favoritesLabel.text = String(tweet.favoritesCount)
        self.retweetsLabel.text = String(tweet.retweetCount)
    }
}
