//
//  AppDelegate.swift
//  TwitterDemo
//
//  Created by Marat on 03/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var prefetchTimer: Timer?
    
    func setPrefetching(active: Bool) {
        if active {
            prefetchTimer?.invalidate()
            prefetchTimer = Timer.scheduledTimer(timeInterval: 60, target: Twitter.client, selector: #selector(Twitter.prefetchHomeTweets), userInfo: nil, repeats: true)
        }
        else {
            prefetchTimer?.invalidate()
            prefetchTimer = nil
        }
    }
    
    func setup() {
        UserDefaults.standard.register(defaults: [SettingsViewController.showAvatarsKey : true])
        setDateTransformer(withName: "strToDate", dateFormat: Twitter.dateFormat)
        NSNotification.Name.currentUserAvailable.addObserver() { _ in
            self.setPrefetching(active: true)
        }
        NSNotification.Name.currentUserUnavailable.addObserver() { _ in
            self.setPrefetching(active: false)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setup()
        Twitter.client.currentUser()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if User.currentUser != nil {
            self.setPrefetching(active: true)
            Twitter.client.homeTweets()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.setPrefetching(active: false)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Twitter.client.handleOpenUrl(url: url)
        return true
    }
}
