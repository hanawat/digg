//
//  MessageViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/08/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlertMessage(_ message: String?) {

        guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateViewController(withIdentifier: AlertMessageViewController.identifier) as? AlertMessageViewController else { return }

        viewController.message = message
        viewController.view.alpha = 0.0
        present(viewController, animated: false) { 
            UIView.animate(withDuration: 0.2, animations: { 
                viewController.view.alpha = 1.0
            })
        }
    }
}

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

class AlertMessageViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!

    static let identifier = "AlertMessageViewController"
    var message: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let message = self.message {
            self.messageLabel.text = message
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let delayTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0.0
            }) { _ in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
