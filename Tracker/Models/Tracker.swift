//
//  Tracker.swift
//  Tracker
//
//  Created by Vadim Nuretdinov on 19.08.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
}
