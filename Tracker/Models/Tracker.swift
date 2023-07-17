//
//  Tracker.swift
//  Tracker
//
//  Created by Vadim Nuretdinov on 16.07.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
}
