//
//  PlayerViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/01.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer
import RealmSwift

class DismissInteractor: UIPercentDrivenInteractiveTransition {

    var hasStarted = false
    var shouldFinish = false
}

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        guard let transitionContext = transitionContext else { return 0.3 }

        return transitionContext.isInteractive() ? 0.6 : 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }

        let screenBounds = UIScreen.mainScreen().bounds
        let finalFrame = CGRect(origin: CGPoint(x: 0, y: screenBounds.height), size: screenBounds.size)
        let options: UIViewAnimationOptions = transitionContext.isInteractive() ? [UIViewAnimationOptions.CurveLinear] : []

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: options, animations: { 
            fromViewController.view.frame = finalFrame

            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}

class PlayerViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!

    let player = MPMusicPlayerController.systemMusicPlayer()
    let interactor = DismissInteractor()
    let playImage = UIImage(named: "play")?.imageWithRenderingMode(.AlwaysTemplate)
    let pauseImage = UIImage(named: "pause")?.imageWithRenderingMode(.AlwaysTemplate)

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(playItemChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()

        controlButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        playItemChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {

        let notification = NSNotificationCenter.defaultCenter()
        player.endGeneratingPlaybackNotifications()
        notification.removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
    }

    @IBAction func control(sender: UIButton) {

        switch player.playbackState {
        case .Playing:
            controlButton.setImage(playImage, forState: .Normal)
            player.pause()

        default:
            controlButton.setImage(pauseImage, forState: .Normal)
            player.play()
        }
    }

    @objc private func playItemChanged() {

        trackLabel.text = player.nowPlayingItem?.title
        artistLabel.text = player.nowPlayingItem?.artist

        artworkImageView.image = player.nowPlayingItem?.artwork?.imageWithSize(artworkImageView.bounds.size) ?? nil

        switch player.playbackState {
        case .Playing:
            controlButton.setImage(pauseImage, forState: .Normal)

        default:
            controlButton.setImage(playImage, forState: .Normal)
        }
    }
    
    @IBAction func showPlayer(sender: UITapGestureRecognizer) {


        guard let mainViewController = UIStoryboard(name: "MainPlayer", bundle: nil).instantiateViewControllerWithIdentifier(MainPlayerViewController.identifier) as? MainPlayerViewController else { return }

        mainViewController.transitioningDelegate = self
        mainViewController.interactor = interactor
        presentViewController(mainViewController, animated: true, completion: nil)
    }
}

extension PlayerViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
