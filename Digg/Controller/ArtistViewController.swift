//
//  ArtistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistViewController: UIViewController {

    var artists = ["The Beatles"]
    var songs: [MPMediaItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let songs = MPMediaQuery.artistsQuery().items {
            artists = NSOrderedSet(array: songs.flatMap { $0.albumArtist }).array as! [String]
            self.songs = songs
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ArtistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = artists[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ArtistViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ArtistCollectionViewCell.identifier, forIndexPath: indexPath) as! ArtistCollectionViewCell
        cell.artistLabel.text = artists[indexPath.row]
        let artworks = songs.filter { $0.albumArtist == artists[indexPath.row] }.flatMap { $0.artwork }
        if let artwork = artworks.first { cell.artworkImageView.image = artwork.imageWithSize(cell.frame.size) }
        let genre = songs.filter { $0.albumArtist == artists[indexPath.row] }.flatMap { $0.genre }
        if let genre = genre.first { cell.genreLabel.text = genre }
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return artists.count
    }
}
