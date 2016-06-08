//
//  PlayerViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/01.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!

    let player = MPMusicPlayerController.systemMusicPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(playItemChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()

        trackLabel.text = player.nowPlayingItem?.title
        artistLabel.text = player.nowPlayingItem?.artist
        artworkImageView.image = player.nowPlayingItem?.artwork?.imageWithSize(artworkImageView.frame.size)

        switch player.playbackState {
        case .Playing:
            controlButton.setTitle("Pause", forState: .Normal)

        default:
            controlButton.setTitle("Play", forState: .Normal)
        }
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

        if let artwork = player.nowPlayingItem?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            artworkImageView.image = artwork.imageWithSize(artwork.bounds.size)
        }

        switch player.playbackState {
        case .Playing:
            controlButton.setTitle("Pause", forState: .Normal)

        default:
            controlButton.setTitle("Play", forState: .Normal)
        }
    }
    
    @IBAction func showPlayer(sender: UITapGestureRecognizer) {

        // TODO: Show music player
    }
}
