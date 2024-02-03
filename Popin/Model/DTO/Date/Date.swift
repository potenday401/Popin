//
//  Date.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import Foundation

// MARK: - DateRecord
struct DateRecord: Codable {
    let dayOfMonthToItem: [DayOfMonthToItem]
    let month, year: Int
}

// MARK: - DayOfMonthToItem
struct DayOfMonthToItem: Codable {
    let createdAt, date: Int
    let photoPinID, photoURL: String

    enum CodingKeys: String, CodingKey {
        case createdAt, date
        case photoPinID = "photoPinId"
        case photoURL = "photoUrl"
    }
}


