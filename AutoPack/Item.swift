//
//  Item.swift
//  AutoPack
//
//  Created by Harry Arakkal on 3/30/19.
//  Copyright © 2019 example. All rights reserved.
//

import Foundation

struct Item: Codable {
    public var rfid: String
    public var name: String
}

struct ItemArray: Codable {
    public var items: [Item]
}

extension Item: Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.rfid == rhs.rfid
    }
}
