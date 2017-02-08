//
//  ViewController.swift
//  TwitterDemo
//
//  Created by Marat on 03/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import UIKit
import CoreData

class TweetsViewController: UITableViewController {

    @IBOutlet var newsButton: UIButton?
    @IBOutlet var loginButton: UIButton?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    
    var showAvatars = true

    var controller: TableViewController? {
        return self.tableView.dataSource as? TableViewController
    }
    
    func configureCells() {
        self.showAvatars = UserDefaults.standard.bool(forKey: SettingsViewController.showAvatarsKey)
        self.controller?.configureCell = { [unowned self] (cell: UITableViewCell, object: NSManagedObject, indexPath: IndexPath) in
            if let tweetCell = cell as? TweetTableViewCell, let tweet = object as? Tweet {
                tweetCell.showAvatar = self.showAvatars || indexPath.row == 0
                tweetCell.tweet = tweet
            }
        }
    }
    
    func setLoginHandling() {
        NSNotification.Name.currentUserAvailable.addObserver() { _ in
            self.loginButton?.isEnabled = true
            self.loginButton?.setTitle("Sign out", for: .normal)
        }
        NSNotification.Name.currentUserUnavailable.addObserver() { _ in
            self.loginButton?.isEnabled = true
            self.loginButton?.setTitle("Sign in", for: .normal)
        }
    }

    func setPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    func setInfiniteScroll() {
        self.controller?.infiniteScroll = {
            if let lastTweet = $1 as? Tweet {
                self.activityIndicatorView?.startAnimating()
                self.controller?.infiniteScrollEnabled = false
                Twitter.client.homeTweets(beforeId: lastTweet.tweetId)
            }
        }
        NSNotification.Name.moreTweetsAvailable.addObserver() { _ in
            self.refreshControl?.endRefreshing()
            self.activityIndicatorView?.stopAnimating()
            self.controller?.infiniteScrollEnabled = true
        }
    }
    
    func setTweetsPrefetching() {
        NSNotification.Name.prefetchedTweetsAvailable.addObserver() { _ in
            self.newsButton?.isHidden = false
            self.newsButton?.setTitle("News! (\(Twitter.client.prefetchedTweets.count))", for: .normal)
        }
    }
    
    func setSettingsHandling() {
        NSNotification.Name.showAvatarsChanged.addObserver() { _ in
            self.showAvatars = UserDefaults.standard.bool(forKey: SettingsViewController.showAvatarsKey)
            self.controller?.reloadItemsAnimated()
        }
    }

    func setErrorHandling() {
        NSNotification.Name.rateLimitExceeded.addObserver() { _ in
            self.refreshControl?.endRefreshing()
            self.activityIndicatorView?.stopAnimating()
            self.controller?.infiniteScrollEnabled = true
            self.showAlert(title: "Rate Limit Exceeded", message: "Too many requests. Try again later.")
        }
        NSNotification.Name.tweetsLoadingError.addObserver() { (notification) in
            self.refreshControl?.endRefreshing()
            self.activityIndicatorView?.stopAnimating()
            self.controller?.infiniteScrollEnabled = true
            let error = notification.userInfo?["error"] as? Error
            self.showAlert(title: "Error", message: error?.localizedDescription ?? "Unknown error")
        }
    }
    
    func refresh() {
        Twitter.client.homeTweets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TweetDetailsViewController, let cell = sender as? TweetTableViewCell {
            vc.tweet = cell.tweet
        }
    }
    
    @IBAction func newsTap(_ sender: NSObject) {
        self.tableView!.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
            Twitter.client.showPrefetchedHomeTweets()
            self.newsButton?.isHidden = true
        }
    }

    @IBAction func loginLogoutTap(_ sender: NSObject) {
        self.loginButton?.isEnabled = false
        if User.currentUser == nil {
            Twitter.client.login()
        }
        else {
            Twitter.client.logout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCells()
        self.setLoginHandling()
        self.setPullToRefresh()
        self.setInfiniteScroll()
        self.setTweetsPrefetching()
        self.setSettingsHandling()
        self.setErrorHandling()
    }
}
