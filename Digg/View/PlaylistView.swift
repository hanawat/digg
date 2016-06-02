//
//  PlaylistView.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/30.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!

    static let nibName = "PlaylistView"

    var playlist: MPMediaPlaylist? {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }
}

extension PlaylistView: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.first as? PlayerViewController else { return }
        playerViewController.player.nowPlayingItem = playlist?.items[indexPath.row]
        playerViewController.player.play()
    }
}

extension PlaylistView: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return playlist?.items.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlaylistCollectionViewCell.identifier, forIndexPath: indexPath) as! PlaylistCollectionViewCell
        cell.artworkImageView.image = playlist?.items[indexPath.row].artwork?.imageWithSize(cell.frame.size)
        return cell
    }
}
