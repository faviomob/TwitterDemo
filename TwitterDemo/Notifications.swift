//
//  Notifications.swift
//  TwitterDemo
//
//  Created by Marat on 06/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    @discardableResult
    func addObserver(object: Any? = nil, using block: @escaping (Notification) -> Swift.Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: self, object: object, queue: OperationQueue.main, using: block)
    }
}

extension NSNotification.Name {
    
    public static let userAuthSuccess = Notification.Name("userAuthSuccess")
    public static let currentUserAvailable = Notification.Name("currentUserAvailable")
    public static let currentUserUnavailable = Notification.Name("currentUserUnavailable")
    public static let moreTweetsAvailable = Notification.Name("moreTweetsAvailable")
    public static let prefetchedTweetsAvailable = Notification.Name("prefetchedTweetsAvailable")
    
    public static let userAuthFailed = Notification.Name("userAuthFailed")
    public static let tweetsLoadingError = Notification.Name("tweetsLoadingError")
    public static let tweetsPrefetchingError = Notification.Name("tweetsPrefetchingError")
    public static let rateLimitExceeded = Notification.Name("rateLimitExceeded")
}

extension NSNotification.Name {
    public static let showAvatarsChanged = Notification.Name("showAvatarsChanged")
}
