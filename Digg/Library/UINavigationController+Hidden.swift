//
//  UINavigationController+Hidden.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/12/12.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {

    func hiddenNavigationBar(_ animation: Bool) {

        let originalFrame = self.navigationBar.frame
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let offsetHeight = originalFrame.size.height + statusBarHeight

        guard originalFrame.origin.y == statusBarHeight else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.navigationBar.frame = originalFrame.offsetBy(dx: 0.0, dy: -offsetHeight)
        }) 
    }

    func showNavigationBar(_ animation: Bool) {

        let originalFrame = self.navigationBar.frame
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let offsetHeight = originalFrame.size.height + statusBarHeight

        guard originalFrame.origin.y == -originalFrame.size.height else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.navigationBar.frame = originalFrame.offsetBy(dx: 0.0, dy: offsetHeight)
        }) 
    }
}
