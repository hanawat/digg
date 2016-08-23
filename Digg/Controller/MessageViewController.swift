//
//  MessageViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/08/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!

    var message: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let message = self.message {
            self.messageLabel.text = message
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
