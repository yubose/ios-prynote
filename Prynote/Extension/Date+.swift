//
//  Date+.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Date {
    var components: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    var year: Int {
        return components.year ?? 0
    }
    
    var month: Int {
        return components.month ?? 0
    }
    
    var day: Int {
        return components.day ?? 0
    }
    
    var formattedDate: String {
        return String(month) + "/" + String(day) + "/" + String("\(year)".suffix(2))
    }
    
    func elapseDateString() -> String {
        guard self.timeIntervalSinceNow <= 0 else { return "" }
        let elapse = abs(self.timeIntervalSinceNow)
        switch elapse {
        case ..<10:
            return "just now"
        case 10..<60:
            return "less than 1 minute"
        case 60..<3600:
            return "\(Int(elapse/60)) minutes ago"
        case 3600..<(3600 * 24):
            let hours = Int(elapse/3600)
            if hours == 1 {
                return "\(hours) hour ago"
            } else {
                return "\(hours) hours ago"
            }
        default:
            let days = Int(elapse/(3600 * 24))
            if days == 1 {
                return "\(days) day ago"
            } else {
                return "\(days) days ago"
            }
        }
    }
    
    init?(year: Int?, month: Int?, day: Int?, hour: Int?, min: Int?, sec: Int?) {
        
        guard let year = year, let month = month, let day = day, let hour = hour, let min = min, let sec = sec else { return nil }
        
        let calendar = Calendar.current
        let timeZone = TimeZone.current
        
        let components = DateComponents(calendar: calendar, timeZone: timeZone, era: nil, year: year, month: month, day: day, hour: hour, minute: min, second: sec, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        if let date = components.date {
            self = date
        } else {
            return nil
        }
    }
    
    var formattedString: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM d, HH:mm"
        
        return dateFormatter.string(from: self)
    }
}
