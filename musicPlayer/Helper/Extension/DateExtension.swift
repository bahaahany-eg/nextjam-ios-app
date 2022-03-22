//
//  DateExtension.swift
//  DateExtension
//
//  Created by apple on 04/10/21.
//

import Foundation

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date())!, locale: .current)
    }
     
    func compareTimeOnly(to: Date) -> ComparisonResult {
        let calendar = Calendar.current
        let components2 = calendar.dateComponents([.hour, .minute, .second], from: to)
        let date3 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!
        
        let seconds = calendar.dateComponents([.second], from: self, to: date3).second!
        if seconds == 0 {
            return .orderedSame
        } else if seconds > 0 {
            // Ascending means before
            return .orderedAscending
        } else {
            // Descending means after
            return .orderedDescending
        }
    }
    func offsetFrom(fromDate: Date, toDate: Date) -> Int {
        var diff : Int = 0
        let calendar = Calendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: fromDate)
        let date2 = calendar.startOfDay(for: toDate)

        let components = calendar.dateComponents([.day,.minute,.second,.hour], from: date1, to: date2)
        if components.day! > 0 {
            let sec = components.day!*24*60*60
            diff += sec
        }
        if components.hour! > 0 {
            let sec = components.hour!*60*60
            diff += sec
        }
        if components.minute! > 0{
            let sec = components.minute!*60
            diff += sec
        }
        if components.second! > 0 {
            diff += components.second!
        }
        return diff
        }
    
}
