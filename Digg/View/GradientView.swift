//
//  GradientView.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/28.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {

    var gradientLayer: CAGradientLayer?

    @IBInspectable var topColor: UIColor = UIColor.whiteColor() {
        didSet { gradient() }
    }

    @IBInspectable var bottomColor: UIColor = UIColor.blackColor() {
        didSet { gradient() }
    }

    func gradient() {

        gradientLayer?.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()

        guard let gradientLayer = gradientLayer else { return }

        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        gradientLayer.frame.size = frame.size
        gradientLayer.frame.origin = CGPointMake(0.0, 0.0)
        gradientLayer.zPosition = -100.0
        layer.insertSublayer(gradientLayer, atIndex: 0)
        layer.masksToBounds = true
    }
}
