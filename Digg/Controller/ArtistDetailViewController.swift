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
import NVActivityIndicatorView

class ArtistDetailViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var collectionView: UICollectionView!

    var artist: LastfmSimilarArtist.Artist?
    var albums: [iTunesMusic.Album] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var originalFrame = CGRectZero
    var pannedIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        SKCloudServiceController.requestAuthorization { _ in }
        SKCloudServiceController().requestCapabilitiesWithCompletionHandler { _, _ in }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addNewPlaylist))

        if let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }

        if let artist = artist {

            startActivityAnimating(nil, type: .LineScalePulseOutRapid, color: nil, padding: nil)

            let request = iTunesSearchRequest(term:artist.name , entity: .Song, attribute: .Artist, limit: 50)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.albums = iTunesMusic.albums(data.musics)

                case .Failure(let error):
                    print(error)
                }

                self.stopActivityAnimating()
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

extension ArtistDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
            indexPath = collectionView.indexPathForItemAtPoint(gestureRecognizer.locationInView(collectionView)) else { return false }

        let location = panGesture.translationInView(collectionView.cellForItemAtIndexPath(indexPath))
        pannedIndexPath = fabs(location.x) > fabs(location.y) ? indexPath : nil
        return fabs(location.x) > fabs(location.y) && location.x > 0.0 ? true : false
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
        cell.trackArtistLabel.text = music.artistName
        cell.trackTimeMillis = music.trackTimeMillis

        if let isStreamable = music.isStreamable {
            cell.trackNameLabel.alpha = isStreamable ? 1.0 : 0.3
            cell.trackTimeLabel.alpha = isStreamable ? 1.0 : 0.3
            cell.userInteractionEnabled = isStreamable ? true : false
        }

        if let isStreamable = albums[indexPath.section].tracks[indexPath.row].isStreamable where isStreamable {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(trackCellPanGesture(_:)))
            panGesture.delegate = self
            cell.addGestureRecognizer(panGesture)
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ArtistDetailCollectionReusableView.identifier, forIndexPath: indexPath) as! ArtistDetailCollectionReusableView
        let album =  albums[indexPath.section]
        header.albumTitleLabel.text = album.collectionName
        header.albumArtistLabel.text = album.artistName
        header.artworkImageView.kf_setImageWithURL(album.artworkUrl)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandRow))
        header.addGestureRecognizer(tapGesture)

        return header
    }

    @objc private func trackCellPanGesture(sender: UIPanGestureRecognizer) {

        guard let pannedIndexPath = pannedIndexPath,
            cell = collectionView.cellForItemAtIndexPath(pannedIndexPath) as? MusicTrackCollectionViewCell else { return }

        switch sender.state {
        case .Began:
            originalFrame = cell.frame

        case .Changed:
            let translation = sender.translationInView(cell)
            cell.frame = translation.x > 0.0 ? CGRectOffset(originalFrame, translation.x, 0.0) : originalFrame


        case .Ended:
            guard let indexPath = collectionView.indexPathForCell(cell)
                where cell.frame.origin.x > cell.frame.size.width / 2.0 else {
                    UIView.animateWithDuration(0.2) { cell.frame = self.originalFrame }; return
            }

            UIView.animateWithDuration(0.2, animations: {
                cell.frame = CGRectOffset(self.originalFrame, cell.frame.size.width, 0.0)

                }, completion: { _ in
                    cell.frame = CGRectOffset(self.originalFrame, -cell.frame.size.width, 0.0)
                    UIView.animateWithDuration(0.2) { cell.frame = self.originalFrame }
            })

            addPlaylist(indexPath)

        default:
            return
        }
    }

    @objc private func addPlaylist(indexPath: NSIndexPath) {

        guard let realm = try? Realm() else { return }

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

    @objc private func expandRow(sender: UITapGestureRecognizer) {

        guard let indexPath = collectionView.indexPathForItemAtPoint(sender.locationInView(collectionView)) else { return }

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.first as? PlayerViewController else { return }

        let collectionId = albums[indexPath.section].collectionId
        playerViewController.player.setQueueWithStoreIDs([String(collectionId)])
        playerViewController.player.play()
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
