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
import APIKit

class DismissInteractor: UIPercentDrivenInteractiveTransition {

    var hasStarted = false
    var shouldFinish = false
}

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let transitionContext = transitionContext else { return 0.3 }

        return transitionContext.isInteractive ? 0.6 : 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }

        let screenBounds = UIScreen.main.bounds
        let finalFrame = CGRect(origin: CGPoint(x: 0, y: screenBounds.height), size: screenBounds.size)
        let options: UIViewAnimationOptions = transitionContext.isInteractive ? [UIViewAnimationOptions.curveLinear] : []

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: options, animations: { 
            fromViewController.view.frame = finalFrame

            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

class PlayerViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var timer = Timer()
    var isDisplayed = true
    var isPlayingPlaylist = true
    let player = MPMusicPlayerController.systemMusicPlayer()
    let interactor = DismissInteractor()
    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")

    var album: iTunesMusic.Album? {
        didSet {
            guard let _ = self.album else { return }
            isPlayingPlaylist = false
        }
    }

    var playlist: Playlist? {
        didSet {
            guard let _ = self.playlist else { return }
            isPlayingPlaylist = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(playStateChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        notification.addObserver(self, selector: #selector(playItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        player.beginGeneratingPlaybackNotifications()
        player.repeatMode = .all

        controlButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        if player.nowPlayingItem == nil { view.isHidden = true }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateProgress()
        playStateChanged()
        playItemChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {

        let notification = NotificationCenter.default
        player.endGeneratingPlaybackNotifications()
        notification.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        notification.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layer.backgroundColor = UIColor(white: 0.1, alpha: 1.0).cgColor
        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layer.backgroundColor = UIColor.clear.cgColor
        })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layer.backgroundColor = UIColor.clear.cgColor
        })
    }

    @IBAction func control(_ sender: UIButton) {

        switch player.playbackState {
        case .playing:
            player.pause()

        default:
            player.play()
        }
    }

    @objc fileprivate func playStateChanged() {

        switch player.playbackState {
        case .playing:
            controlButton.isSelected = true

            if timer.isValid == false {
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            }

        default:
            controlButton.isSelected = false
            timer.invalidate()
        }
    }

    @objc fileprivate func playItemChanged() {

        if player.nowPlayingItem == nil && player.playbackState != .playing && isDisplayed {

            self.isDisplayed = false
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0.0, dy: self.view.bounds.height)
            }, completion: { _ in
                if self.view.isHidden { self.view.isHidden = false }
            })

        } else if player.nowPlayingItem != nil && !isDisplayed {

            self.isDisplayed = true
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0.0, dy: -self.view.bounds.height)
            }) 
        }

        // FIXME: Get ArtWork from local player
        if isPlayingPlaylist, let playingTrack = playlist?.items
            .filter({ $0.collectionName == self.player.nowPlayingItem?.albumTitle }).first,
            let imageUrl = iTunesMusic.artworkUrl512(playingTrack.artworkUrl) {

            artworkImageView.kf.setImage(with: imageUrl)

        } else if let playingTrack = album?.tracks
            .filter({ $0.collectionName == self.player.nowPlayingItem?.albumTitle }).first,
            let imageUrl = iTunesMusic.artworkUrl512(playingTrack.artworkUrl100) {

            artworkImageView.kf.setImage(with: imageUrl)

        } else if let artwork = player.nowPlayingItem?.artwork {
            artworkImageView.image = artwork.image(at: artwork.bounds.size) ?? UIImage(named: "logo-short")
            playlist = nil
            album = nil
        }

        progressView.progress = 0.0
        trackLabel.text = player.nowPlayingItem?.title ?? trackLabel.text
        artistLabel.text = player.nowPlayingItem?.artist ?? artistLabel.text
    }

    @objc fileprivate func updateProgress() {

        if let durationTime = player.nowPlayingItem?.playbackDuration {
            progressView.setProgress(Float(player.currentPlaybackTime / durationTime), animated: false)
        }
    }
    
    @IBAction func showPlayer(_ sender: UITapGestureRecognizer) {


        guard let mainViewController = UIStoryboard(name: "MainPlayer", bundle: nil).instantiateViewController(withIdentifier: MainPlayerViewController.identifier) as? MainPlayerViewController else { return }

        mainViewController.album = album
        mainViewController.playlist = playlist
        mainViewController.isPlayingPlaylist = isPlayingPlaylist
        mainViewController.transitioningDelegate = self
        mainViewController.interactor = interactor
        present(mainViewController, animated: true, completion: nil)
    }
}

extension PlayerViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
