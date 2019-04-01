//
//  Item.swift
//  AutoPack
//
//  Created by Harry Arakkal on 3/30/19.
//  Copyright © 2019 example. All rights reserved.
//

import Foundation

class Item {
    private var rfid: String
    public var name: String
    public var pocket: Int
    
    init(rfid: String, name: String, pocket: Int) {
        self.rfid = rfid
        self.name = name
        self.pocket = pocket
    }
}
