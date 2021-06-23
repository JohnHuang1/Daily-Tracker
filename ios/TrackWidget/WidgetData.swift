//
//  WidgetData.swift
//  Runner
//
//  Created by John Huang on 6/21/21.
//

import Foundation

struct FlutterWidgetData: Decodable, Hashable{
    var streakList: [StreakItem]
    let lastUpdated: Date
}

struct StreakItem: Decodable, Hashable{
    let name: String
    var prevHighestStreak: Int
    var currHighestStreak: Int
    var checked: Bool
}
