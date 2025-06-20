//
//  DateExtension.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/19/25.
//

import Foundation


extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
