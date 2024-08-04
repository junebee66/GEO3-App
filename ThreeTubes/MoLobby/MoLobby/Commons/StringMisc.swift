//
//  StringMisc.swift
//  MoGallery
//
//  Created by jht2 on 12/31/22.
//

import Foundation


// https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}

func prefix(_ str: String, _ count: Int) -> String {
    return str[0..<count]
}
