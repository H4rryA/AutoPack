//
//  Color.swift
//  Power
//
//  Created by Harry Arakkal on 10/5/18.
//  Copyright © 2018 harryarakkal. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color0() -> UIColor {
        return UIColor(hue: 317/360.0, saturation: 34/100.0, brightness: 100/100.0, alpha: 1.0)
    }
    
    static func color1() -> UIColor {
        return UIColor(hue: 270/360.0, saturation: 80/100.0, brightness: 80/100.0, alpha: 1.0)
    }
    
    static func backgroundColor() -> UIColor {
        return UIColor(hue: 217/360.0, saturation: 0/100.0, brightness: 97/100.0, alpha: 1.0)
    }
    
    static func gradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.color0().cgColor, UIColor.color1().cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.locations = [0.0, 1.0]
        return gradient
    }
}
