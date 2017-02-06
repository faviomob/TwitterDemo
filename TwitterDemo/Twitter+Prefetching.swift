//
//  Twitter+Prefetching.swift
//  TwitterDemo
//
//  Created by Marat on 06/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import Groot

extension Twitter {
    
    func prefetchHomeTweets() {
        get("1.1/statuses/home_timeline.json",
            parameters: ["count": "5"],
            progress: nil,
            success: { (_:  URLSessionDataTask, response: Any?) -> Void in
                
                if let tweetsArr = response as? [JSONDictionary] {
                    for tweetJson in tweetsArr {
                        let tweetId = tweetJson["id_str"] as! String
                        let tweet = NSManagedObject.objects(ofEntity: "\(Tweet.self)", with: NSPredicate(format: "SELF.tweetId = %@", tweetId), in: self.moc)?.first
                        if tweet == nil {
                            self.prefetchedTweets[tweetId] = tweetJson
                        }
                    }
                    if self.prefetchedTweets.count > 0 {
                        NotificationCenter.default.post(name: .prefetchedTweetsAvailable, object: nil)
                    }
                    print("Prefetched tweets count: \(self.prefetchedTweets.count)")
                }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            self.handleError(error, inTask: task, withNotification: .tweetsPrefetchingError)
        })
    }
    
    func showPrefetchedHomeTweets() {
        if self.prefetchedTweets.count > 0 {
            let tweets = try? Groot.objects(fromJSONArray: Array(self.prefetchedTweets.values), inContext: self.moc) as [Tweet]
            NotificationCenter.default.post(name: .moreTweetsAvailable, object: nil)
            self.prefetchedTweets.removeAll()
            print("Tweets shown count: \(tweets?.count)")
        }
    }
}
