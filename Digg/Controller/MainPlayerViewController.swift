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
            timer.invalidate()

        default:
            controlButton.setTitle("Pause", forState: .Normal)
            player.play()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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

            timer = timer.valid ? NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true) : timer

        default:
            controlButton.setTitle("Play", forState: .Normal)
        }

        collectionView.reloadData()
    }

    @objc private func updateTime() {

        guard let cell = collectionView.visibleCells().first as? PlaylistCollectionViewCell else { return }
        cell.currentTime = player.currentPlaybackTime
    }
}

extension MainPlayerViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return collection?.items.count ?? 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlaylistCollectionViewCell.identifier, forIndexPath: indexPath) as! PlaylistCollectionViewCell
        cell.artworkImageView.image = collection?.items[indexPath.row].artwork?.imageWithSize(cell.bounds.size) ?? player.nowPlayingItem?.artwork?.imageWithSize(cell.bounds.size)
        cell.durationTime = player.nowPlayingItem?.playbackDuration ?? 1.0
        return cell
    }
}

extension MainPlayerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = UIScreen.mainScreen().bounds.size.width - 20.0
        return CGSize(width: size, height: size)
    }
}
