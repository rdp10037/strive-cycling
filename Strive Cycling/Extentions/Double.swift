//
//  Double.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import Foundation

extension Double {
    
    /// Converts a Double into a string representation.  - RDP
    ///  ```
    /// Convert 1.2345 to "1.23"
    ///  ```
    func asNumberString() -> String {
        return String(format: "%.2f", self)
    }
    
}
