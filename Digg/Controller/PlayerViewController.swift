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

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(playItemChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()

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
            controlButton.setTitle("Play", forState: .Normal)
            player.pause()

        default:
            controlButton.setTitle("Pause", forState: .Normal)
            player.play()
        }
    }

    @objc private func playItemChanged() {

        trackLabel.text = player.nowPlayingItem?.title
        artistLabel.text = player.nowPlayingItem?.artist

        artworkImageView.image = player.nowPlayingItem?.artwork?.imageWithSize(artworkImageView.bounds.size) ?? nil

        switch player.playbackState {
        case .Playing:
            controlButton.setTitle("Pause", forState: .Normal)

        default:
            controlButton.setTitle("Play", forState: .Normal)
        }
    }
    
    @IBAction func showPlayer(sender: UITapGestureRecognizer) {

        guard let mainViewController = UIStoryboard(name: "Artist", bundle: nil).instantiateViewControllerWithIdentifier(MainPlayerViewController.identifier) as? MainPlayerViewController else { return }

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

class MainPlayerViewController: UIViewController {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var volumeView: MPVolumeView!

    static let identifier = "MainPlayerViewController"

    let player = MPMusicPlayerController.systemMusicPlayer()
    var interactor: DismissInteractor?
    var collection: MPMediaItemCollection? {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(playItemChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()

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

    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {

        guard let interactor = interactor else { return }

        let translation = sender.translationInView(view)
        let progress = translation.y / view.bounds.height

        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > 0.3
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finishInteractiveTransition() : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }

    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func control(sender: UIButton) {

        switch player.playbackState {
        case .Playing:
            controlButton.setTitle("Play", forState: .Normal)
            player.pause()

        default:
            controlButton.setTitle("Pause", forState: .Normal)
            player.play()
        }
    }

    @IBAction func next(sender: UIButton) {
        player.skipToNextItem()
    }

    @IBAction func previous(sender: UIButton) {
        player.skipToPreviousItem()
    }

    @objc private func playItemChanged() {

        trackLabel.text = player.nowPlayingItem?.title
        artistLabel.text = player.nowPlayingItem?.artist

        switch player.playbackState {
        case .Playing:
            controlButton.setTitle("Pause", forState: .Normal)

        default:
            controlButton.setTitle("Play", forState: .Normal)
        }

        collectionView.reloadData()
    }
}

extension MainPlayerViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return collection?.items.count ?? 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlaylistCollectionViewCell.identifier, forIndexPath: indexPath) as! PlaylistCollectionViewCell
        cell.artworkImageView.image = collection?.items[indexPath.row].artwork?.imageWithSize(cell.bounds.size) ?? player.nowPlayingItem?.artwork?.imageWithSize(cell.bounds.size)
        return cell
    }
}

extension MainPlayerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = UIScreen.mainScreen().bounds.size.width - 20.0
        return CGSize(width: size, height: size)
    }
}
