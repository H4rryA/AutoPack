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
    
    init(rfid: String, name: String) {
        self.rfid = rfid
        self.name = name
    }
}
