//
//  getElapsedInterval.swift
//  MoGallery
//
//  Created by jht2 on 1/21/23.
//

import Foundation


// https://stackoverflow.com/questions/34457434/swift-convert-time-to-time-ago

extension Date
{
    func getElapsedInterval() -> String
    {
        let interval = Calendar.current.dateComponents(
            [.year, .month, .day,.hour, .minute, .second],
            from: self, to: Date())
        
        if let yearsPassed = interval.year,
           yearsPassed > 0
        {
            return "\(yearsPassed) year\(yearsPassed == 1 ? "" : "s") ago"
        }
        else if let monthsPassed = interval.month,
                monthsPassed > 0
        {
            return "\(monthsPassed) month\(monthsPassed == 1 ? "" : "s") ago"
        }
        else if let daysPassed = interval.day,
                daysPassed > 0
        {
            return "\(daysPassed) day\(daysPassed == 1 ? "" : "s") ago"
        }
        else if let hoursPassed = interval.hour,
                hoursPassed > 0
        {
            return "\(hoursPassed) hour\(hoursPassed == 1 ? "" : "s") ago"
        }
        else if let minutesPassed = interval.minute,
                minutesPassed > 0
        {
            return "\(minutesPassed) minute\(minutesPassed == 1 ? "" : "s") ago"
        }
        else if let secondsPassed = interval.second,
                secondsPassed > 0
        {
            return "\(secondsPassed) second\(secondsPassed == 1 ? "" : "s") ago"
        }

        return "a moment ago"
    }
}

