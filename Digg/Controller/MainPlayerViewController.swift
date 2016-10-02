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
    var timer = Timer()
    var interactor: DismissInteractor?
    var isPlayingPlaylist = true
    var currentPage = 0

    var album: iTunesMusic.Album?
    var playlist: Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(playStateChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        notification.addObserver(self, selector: #selector(playItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        player.beginGeneratingPlaybackNotifications()

        updateProgress()
        playItemChanged()
        playStateChanged()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        changeArtwork()
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

    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {

        guard let interactor = interactor else { return }

        let translation = sender.translation(in: view)
        let progress = translation.y / view.bounds.height

        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > 0.3
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func control(_ sender: UIButton) {

        switch player.playbackState {
        case .playing:
            player.pause()

        default:
            player.play()
        }
    }

    @IBAction func next(_ sender: UIButton) {
        player.skipToNextItem()
    }

    @IBAction func previous(_ sender: UIButton) {
        player.skipToPreviousItem()
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

        trackLabel.text = player.nowPlayingItem?.title ?? trackLabel.text
        artistLabel.text = player.nowPlayingItem?.artist ?? artistLabel.text

        changeArtwork()
    }

    @objc fileprivate func updateProgress() {

        guard let cell = collectionView.visibleCells.first as? PlaylistCollectionViewCell else { return }

        // FIXME: Progress View
        if let durationTime = player.nowPlayingItem?.playbackDuration {
            cell.progressView.setProgress(Float(player.currentPlaybackTime / durationTime), animated: false)
        }
    }

    fileprivate func changeArtwork() {

        if player.indexOfNowPlayingItem == NSNotFound && player.playbackState != .playing {
            dismiss(animated: true, completion: nil)

        } else if album != nil || playlist != nil {

            let indexOfAlbum = album?.tracks.index(where: { $0.trackName == player.nowPlayingItem?.title && $0.collectionName == player.nowPlayingItem?.albumTitle })
            let indexOfPlaylist = playlist?.items.index(where: { $0.trackName == player.nowPlayingItem?.title && $0.collectionName == player.nowPlayingItem?.albumTitle })

            if let indexOfNowPlayingItem = indexOfAlbum ?? indexOfPlaylist {

                let indexPath = IndexPath(item: indexOfNowPlayingItem, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                collectionView.reloadData()

                currentPage = indexOfNowPlayingItem
            }
        }
    }
}

extension MainPlayerViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return isPlayingPlaylist ? playlist?.items.count ?? 1 : album?.tracks.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.identifier, for: indexPath) as! PlaylistCollectionViewCell

        cell.progressView.setProgress(0.0, animated: false)

        if isPlayingPlaylist, let imageUrl = iTunesMusic.artworkUrl512(playlist?.items[indexPath.row].artworkUrl) {

            cell.artworkImageView.kf.setImage(with: imageUrl)

        } else if let imageUrl = album?.artworkUrl {
            cell.artworkImageView.kf.setImage(with: imageUrl)

        } else if let artwork = player.nowPlayingItem?.artwork {
            cell.artworkImageView.image = artwork.image(at: artwork.bounds.size) ?? UIImage(named: "logo-short")
        }

        return cell
    }
}

extension MainPlayerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = UIScreen.main.bounds.size.width
        return CGSize(width: size, height: size)
    }
}

extension MainPlayerViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let currentPage = Int(ceil(collectionView.contentOffset.x / collectionView.bounds.size.width))
        guard currentPage != self.currentPage else { return }

        var trackIds: [String] = []
        if let album = self.album {

            trackIds = album.tracks.flatMap { item -> String? in
                guard let trackId = item.trackId else { return nil }
                return String(trackId)
            }

        } else if let playlist = self.playlist {

            trackIds = playlist.items.flatMap { String($0.trackId) }
        }

        guard (0..<trackIds.count) ~= currentPage else { return }

        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: trackIds)
        descriptor.startItemID = trackIds[currentPage]
        player.setQueueWith(descriptor)

        player.prepareToPlay(completionHandler: { error in
            if error == nil {
                self.player.play()
            } else {

                self.showAlertMessage(error?.localizedDescription)
                print(error?.localizedDescription)
            }
        })

        self.currentPage = currentPage
    }
}
