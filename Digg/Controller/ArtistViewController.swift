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

    var artists: [String] = ["The Beatles"]

    override func viewDidLoad() {
        super.viewDidLoad()

        if let songs = MPMediaQuery.artistsQuery().items {
            artists = NSOrderedSet(array: songs.flatMap { $0.albumArtist }).array as! [String]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ArtistViewController: UICollectionViewDelegate {

}

extension ArtistViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ArtistCollectionViewCell.identifier, forIndexPath: indexPath) as! ArtistCollectionViewCell
        cell.ArtistLabel.text = artists[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return artists.count
    }
}
