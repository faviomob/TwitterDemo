//
//  Twitter.swift
//  TwitterDemo
//
//  Created by Marat on 03/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import Groot

class Twitter: BDBOAuth1SessionManager {
    
    static var dateFormat = "EEE MMM d HH:mm:ss Z y"
    
    static let client: Twitter = Twitter(baseURL: URL(string:"https://api.twitter.com"),
                                         consumerKey: "VYw9RB3kDoT15kZIWiw662907",
                                         consumerSecret: "6BXB1c3hl2K8eGAhyr2kPQeGn0PB7wmjAOVwIKgNHC1tjvZCCE")
    
//    static let client: Twitter = Twitter(baseURL: URL(string:"https://api.twitter.com"),
//                                         consumerKey: "17mu0YBdAu21owZZ6M2YQGVMB",
//                                         consumerSecret: "jUrdLKuGxfHBHnrQcEZ7h7b2f1mdKEf9MclO9icwMxkqosAY0V") // old
    
    var moc: NSManagedObjectContext {
        return CoreDataManager.defaultInstance()!.managedObjectContext!
    }
    
    var prefetchedTweets = [String: JSONDictionary]()
    
    func login() {
        self.deauthorize()
        self.fetchRequestToken(withPath: "oauth/request_token",
                               method: "GET",
                               callbackURL: URL(string:"faviotwitter://oauth"),
                               scope: nil,
                               success: { (requestToken: BDBOAuth1Credential?) -> Void in
                                if let token = requestToken?.token {
                                    let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
                                    UIApplication.shared.openURL(url)
                                }
        }, failure: {(error: Error?) -> Void in
            print(error?.localizedDescription ?? "")
            NotificationCenter.default.post(name: .userAuthFailed, object: nil)
        })
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        self.fetchAccessToken(withPath: "oauth/access_token",
                              method: "POST",
                              requestToken: requestToken,
                              success: { (accessToken: BDBOAuth1Credential?) -> Void in
                                
                                debugPrint("Access token received: \(accessToken!)")
                                Twitter.client.currentUser()
                                NotificationCenter.default.post(name: .userAuthSuccess, object: nil)
        }, failure: { (error: Error?) -> Void in
            print(error?.localizedDescription ?? "")
            NotificationCenter.default.post(name: .userAuthFailed, object: nil)
        })
    }
    
    func handleError(_ error: Error, inTask task: URLSessionDataTask?, withNotification name: NSNotification.Name) {
        if let response = task?.response as? HTTPURLResponse {
            if response.statusCode == 429 {
                NotificationCenter.default.post(name: .rateLimitExceeded, object: nil, userInfo: [ "error" : error ])
            }
            else {
                NotificationCenter.default.post(name: name, object: nil, userInfo: [ "error" : error ])
            }
        }
        else {
            NotificationCenter.default.post(name: name, object: nil, userInfo: [ "error" : error ])
        }
    }
    
    func homeTweets(afterId: String? = nil, beforeId: String? = nil, count: Int = 20) {
        var params = ["count": "\(count)"]
        if beforeId != nil {
            params["max_id"] = beforeId!
        }
        else if afterId != nil {
            params["since_id"] = afterId!
        }
        get("1.1/statuses/home_timeline.json",
            parameters: params,
            progress: nil,
            success: { (_:  URLSessionDataTask, response: Any?) -> Void in
                
                if let tweetsArr = response as? [NSDictionary] {
                    let tweets = try? Groot.objects(fromJSONArray: tweetsArr, inContext: self.moc) as [Tweet]
                    NotificationCenter.default.post(name: .moreTweetsAvailable, object: nil)
                    print("Tweets count: \(tweets?.count)")
                }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            self.handleError(error, inTask: task, withNotification: .tweetsLoadingError)
        })
    }
    
    func currentUser() {
        get("1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (_:  URLSessionDataTask, response: Any?) -> Void in
            
            if let userDict = response as? JSONDictionary {
                let user = try? Groot.object(fromJSONDictionary: userDict, inContext: self.moc) as User
                if let user = user {
                    User.currentUser = user
                    NotificationCenter.default.post(name: .currentUserAvailable, object: nil)
                    Twitter.client.homeTweets()
                    print("Current user: \(user)")
                }
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            self.handleError(error, inTask: task, withNotification: .currentUserUnavailable)
        })
    }
    
    func logout() {
        self.deauthorize()
        User.currentUser = nil
        NSManagedObject.clear(entity: "\(User.self)", in: self.moc)
        NSManagedObject.clear(entity: "\(Tweet.self)", in: self.moc)
        NotificationCenter.default.post(name: .currentUserUnavailable, object: nil)
    }
}
