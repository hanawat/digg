//
//  ArtistDetailViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
import RealmSwift
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addNewPlaylist))

        if let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }

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

    @objc private func addNewPlaylist() {

        guard let viewController = UIStoryboard(name: "CreatePlaylist", bundle: nil).instantiateInitialViewController() as? CreatePlaylistViewController else { return }

        showViewController(viewController, sender: nil)
    }
}

extension ArtistDetailViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let music = albums[indexPath.section].tracks[indexPath.row]
        guard let trackId = music.trackId,
            isStremable = music.isStreamable where isStremable else { return }

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController else { return }

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

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MusicTrackCollectionViewCell.identifier, forIndexPath: indexPath) as! MusicTrackCollectionViewCell
        let music =  albums[indexPath.section].tracks[indexPath.row]

        cell.trackNameLabel.text = music.trackName
        cell.trackTimeMillis = music.trackTimeMillis

        if let isStremable = music.isStreamable {
            cell.trackNameLabel.alpha = isStremable ? 1.0 : 0.3
            cell.addPlaylistButton.enabled = isStremable ? true : false
        }

        cell.addPlaylistButton.addTarget(self, action: #selector(addPlaylist), forControlEvents: .TouchUpInside)

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ArtistDetailCollectionReusableView.identifier, forIndexPath: indexPath) as! ArtistDetailCollectionReusableView
        let album =  albums[indexPath.section]
        header.albumTitleLabel.text = album.collectionName
        header.artworkImageView.kf_setImageWithURL(album.artworkUrl)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandRow))
        header.addGestureRecognizer(tapGesture)

        return header
    }

    @objc private func expandRow(sender: UITapGestureRecognizer) {

        guard let indexPath = collectionView.indexPathForItemAtPoint(sender.locationInView(collectionView)) else { return }

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.first as? PlayerViewController else { return }

        let collectionId = albums[indexPath.section].collectionId
        playerViewController.player.setQueueWithStoreIDs([String(collectionId)])
        playerViewController.player.play()
    }

    @objc private func addPlaylist(sender: UIButton) {

        guard let cell = sender.superview?.superview as? MusicTrackCollectionViewCell,
            indexPath = collectionView.indexPathForCell(cell),
            realm = try? Realm() else { return }

        let playlist = realm.objects(Playlist).last ?? Playlist()
        let item = PlaylistItem()
        let track = albums[indexPath.section].tracks[indexPath.row]

        item.trackId = track.trackId ?? 0
        item.trackName = track.trackName ?? ""
        item.artistId = track.artistId ?? 0
        item.artistName = track.artistName ?? ""
        item.trackTimeMillis = track.trackTimeMillis ?? 0
        item.artworkUrl = track.artworkUrl100

        do {
            try realm.write() {
                playlist.items.append(item)
                realm.add(playlist)
            }
        } catch {
            fatalError()
        }
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
