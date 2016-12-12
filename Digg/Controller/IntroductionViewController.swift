//
//  IntroductionViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/12/12.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import UIKit

class IntroductionViewController:UIViewController {

    static let identifier = "IntroductionViewController"

    @IBAction func getStarted(_ sender: UIButton) {

        guard let viewController = UIStoryboard(name: "Artist", bundle: nil).instantiateInitialViewController(),
            let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        UIView.animate(withDuration: 0.2, animations: { 
            self.view.alpha = 0.0
        }) { _ in
            appDelegate.window?.rootViewController = viewController
        }
    }
}
