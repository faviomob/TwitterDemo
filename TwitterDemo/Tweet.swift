//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Marat on 04/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import Foundation

extension Tweet {
    
    static let dateFormatter = DateFormatter()
    
    func timestampString() -> String {
        Tweet.dateFormatter.timeStyle = .medium
        Tweet.dateFormatter.dateStyle = .long
        let str = Tweet.dateFormatter.string(from: self.timestamp as! Date)
        return str
    }
    
    func timeAgoString(from date: NSDate) -> String {
        let interval = date.timeIntervalSinceNow
        let intervalInt = Int(interval) * -1
        let days = (intervalInt / 3600) / 24
        if days != 0 {
            let daysStr = String(days) + "d"
            return daysStr
        }
        let hours = (intervalInt / 3600)
        if hours != 0 {
            return String(hours) + "h"
        }
        let minutes = (intervalInt / 60) % 60
        if minutes != 0 {
            return String(minutes) + "m"
        }
        let seconds = intervalInt % 60
        if seconds != 0 {
            return String(seconds) + "s"
        }
        else {
            return "Now"
        }
    }

    var timeAgoString: String? {
        if self.formattedTimestamp == nil && self.timestamp != nil {
            self.formattedTimestamp = timeAgoString(from: self.timestamp!)
        }
        return self.formattedTimestamp
    }
}
