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
