//
//  MainPlayerViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/17.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

class MainPlayerViewController: UIViewController {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var volumeView: MPVolumeView!

    static let identifier = "MainPlayerViewController"

    let player = MPMusicPlayerController.systemMusicPlayer()
    var timer = NSTimer()
    var interactor: DismissInteractor?
    var isPlayingPlaylist = true

    var album: iTunesMusic.Album?
    var playlist: Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(playStateChanged), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        notification.addObserver(self, selector: #selector(playItemChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()

        updateProgress()
        playItemChanged()
        playStateChanged()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {

        let notification = NSNotificationCenter.defaultCenter()
        player.endGeneratingPlaybackNotifications()
        notification.removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
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
            player.pause()

        default:
            player.play()
        }
    }

    @IBAction func next(sender: UIButton) {
        player.skipToNextItem()
    }

    @IBAction func previous(sender: UIButton) {
        player.skipToPreviousItem()
    }

    @objc private func playStateChanged() {

        switch player.playbackState {
        case .Playing:
            controlButton.selected = true

            if timer.valid == false {
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            }

        default:
            controlButton.selected = false
            timer.invalidate()
        }
    }

    @objc private func playItemChanged() {

        trackLabel.text = player.nowPlayingItem?.title
        artistLabel.text = player.nowPlayingItem?.artist

        collectionView.reloadData()
    }

    @objc private func updateProgress() {

        guard let cell = collectionView.visibleCells().first as? PlaylistCollectionViewCell else { return }

        // FIXME: Progress View
        if let durationTime = player.nowPlayingItem?.playbackDuration {
            cell.progressView.setProgress(Float(player.currentPlaybackTime / durationTime), animated: false)
        }
    }
}

extension MainPlayerViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return isPlayingPlaylist ? playlist?.items.count ?? 1 : album?.tracks.count ?? 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlaylistCollectionViewCell.identifier, forIndexPath: indexPath) as! PlaylistCollectionViewCell

        cell.progressView.setProgress(0.0, animated: false)

        if isPlayingPlaylist, let imageUrl = iTunesMusic.artworkUrl512(playlist?.items[indexPath.row].artworkUrl) {

            cell.artworkImageView.kf_setImageWithURL(imageUrl)

        } else if let imageUrl = album?.artworkUrl {

            cell.artworkImageView.kf_setImageWithURL(imageUrl)
        }

        return cell
    }
}

extension MainPlayerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = UIScreen.mainScreen().bounds.size.width
        return CGSize(width: size, height: size)
    }
}
