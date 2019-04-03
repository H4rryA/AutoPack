//
//  ViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 4/3/19.
//  Copyright © 2019 example. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabs = tabBar.items {
            for tab in tabs {
                switch tab.title {
                case "Backpack":
                    tab.image = UIImage(named: "BackpackIcon")
                case "Events":
                    let formatter = DateFormatter()
                    formatter.setLocalizedDateFormatFromTemplate("d")
                    let day = formatter.string(from: Date(timeIntervalSinceNow: 0.0))
                    tab.image = UIImage(named: "calendar" + String(day))
                default:
                    break
                }
            }
        }
    }
}
