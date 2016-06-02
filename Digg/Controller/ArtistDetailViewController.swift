//
//  ArtistDetailViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
import MediaPlayer
import StoreKit

class ArtistDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var artist: LastfmSimilarArtist.Artist?
    var albums: [iTunesMusic.Album] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SKCloudServiceController.requestAuthorization { _ in }
        SKCloudServiceController().requestCapabilitiesWithCompletionHandler { _, _ in }

        if let artist = artist {

            let request = iTunesSearchRequest(term:artist.name , entity: .Song, attribute: .Artist, limit: 50)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.albums = iTunesMusic.albums(data.musics)
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ArtistDetailViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let music = albums[indexPath.section].tracks[indexPath.row]
        guard let trackId = music.trackId,
            isStremable = music.isStreamable where isStremable else { return }

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.first as? PlayerViewController else { return }

        playerViewController.player.setQueueWithStoreIDs([String(trackId)])
        playerViewController.player.play()
    }
}

extension ArtistDetailViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return albums.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums[section].tracks.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ArtistDetaiCollectionViewCell.identifier, forIndexPath: indexPath) as! ArtistDetaiCollectionViewCell
        let music =  albums[indexPath.section].tracks[indexPath.row]
        cell.trackNameLabel.text = music.trackName

        if let isStremable = music.isStreamable {
            cell.trackNameLabel.alpha = isStremable ? 1.0 : 0.3
        }

        if let imageUrl = music.artworkUrl100 ?? music.artworkUrl60 ?? music.artworkUrl30,
            url = NSURL(string: imageUrl) {
            cell.trackImageView.kf_setImageWithURL(url)
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ArtistDetailCollectionReusableView.identifier, forIndexPath: indexPath) as! ArtistDetailCollectionReusableView
        let album =  albums[indexPath.section]
        header.albumTitleLabel.text = album.collectionName
        header.artworkImageView.kf_setImageWithURL(album.artworkUrl)

        return header
    }
}

extension ArtistDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let width = UIScreen.mainScreen().bounds.size.width
        return CGSize(width: width, height: 50.0)
    }
}

extension ArtistDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {

        guard let visibleHeaders = collectionView.visibleSupplementaryViewsOfKind(UICollectionElementKindSectionHeader) as? [ArtistDetailCollectionReusableView] else { return }

        visibleHeaders.forEach { header in
            let y = ((collectionView.contentOffset.y - header.frame.origin.y) / header.frame.height) * 25.0
            header.offset(CGPointMake(0.0, y))
        }
    }
}
