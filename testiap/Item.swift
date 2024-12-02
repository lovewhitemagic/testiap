//
//  Item.swift
//  testiap
//
//  Created by Hui Peng on 2024/12/1.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
