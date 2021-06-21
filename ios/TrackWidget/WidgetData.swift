//
//  WidgetData.swift
//  Runner
//
//  Created by John Huang on 6/21/21.
//

import Foundation

struct FlutterWidgetData: Decodable, Hashable{
    let streakList: [StreakItem]
}

struct StreakItem: Decodable, Hashable{
    let name: String
    let prevHighestStreak: Int
    let currHighestStreak: Int
    let checked: Bool
}
