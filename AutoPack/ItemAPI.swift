//
//  ItemAPI.swift
//  AutoPack
//
//  Created by Harry Arakkal on 4/18/19.
//  Copyright © 2019 example. All rights reserved.
//

import Siesta

class ItemAPI {
    static let sharedInstance = ItemAPI()
    
    private let service = Service(baseURL: "http://10.0.0.8:3000", standardTransformers: [.text, .image, .json])
    
    private init() {
        LogCategory.enabled = [.network, .pipeline, .observers]
        
        service.configure("**") {
            $0.expirationTime = 1
        }
    }
    
    func itemList() -> Resource {
        return service
            .resource("/items")
    }
}
