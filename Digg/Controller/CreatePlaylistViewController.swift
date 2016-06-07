//
//  CreatePlaylistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/05.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import RealmSwift
import MediaPlayer
import NVActivityIndicatorView

class CreatePlaylistViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var collectionView: UICollectionView!

    var playlist = Playlist() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let realm = try? Realm() else { return }
        playlist = realm.objects(Playlist).last ?? Playlist()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(createiTunesPlaylist))

        if let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc private func createiTunesPlaylist() {

        navigationItem.rightBarButtonItem?.enabled = false
        startActivityAnimating(nil, type: .LineScaleParty, color: nil, padding: nil)

        let library = MPMediaLibrary.defaultMediaLibrary()
        let metadata = MPMediaPlaylistCreationMetadata(name: playlist.playlistName)
        metadata.descriptionText = playlist.playlistDiscription

        library.getPlaylistWithUUID(NSUUID(), creationMetadata: metadata) { playlist, error in
            if error != nil { print(error); return }

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let trackIds = self.playlist.items.map { String($0.trackId) }

                var addedPlaylistItemsCount = 0
                trackIds.forEach { trackId in

                    playlist?.addItemWithProductID(trackId) { error in
                        if error != nil { print(error) }

                        addedPlaylistItemsCount += 1
                        if addedPlaylistItemsCount == trackIds.count {

                            dispatch_async(dispatch_get_main_queue()) {
                                self.stopActivityAnimating()
                                self.navigationItem.rightBarButtonItem?.enabled = true
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CreatePlaylistViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        guard let realm = try? Realm(),
            header = collectionView.visibleSupplementaryViewsOfKind(UICollectionElementKindSectionHeader).first as? CreatePlaylistCollectionReusableView,
            playlistName = header.playlistTitleLabel.text,
            playlistDescription = header.descriptionLabel.text else { return true }

        do {
            try realm.write() {
                playlist.playlistName = playlistName
                playlist.playlistDiscription = playlistDescription
            }
        } catch {
            print("Realm writing error.")
        }

        return true
    }
}

extension CreatePlaylistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController else { return }

        let trackIds = playlist.items.map { String($0.trackId) }
            .enumerate().filter { $0.index >= indexPath.row }.map { $0.element }

        playerViewController.player.setQueueWithStoreIDs(trackIds)
        playerViewController.player.prepareToPlay()
        playerViewController.player.play()
    }
}

extension CreatePlaylistViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return playlist.items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MusicTrackCollectionViewCell.identifier, forIndexPath: indexPath) as! MusicTrackCollectionViewCell
        let music = playlist.items[indexPath.row]

        cell.trackNameLabel.text = music.trackName
        cell.trackTimeMillis = music.trackTimeMillis

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: CreatePlaylistCollectionReusableView.identifier, forIndexPath: indexPath) as! CreatePlaylistCollectionReusableView
        header.playlistTitleLabel.text = playlist.playlistName
        header.descriptionLabel.text = playlist.playlistDiscription

        return header
    }
}

extension CreatePlaylistViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let width = UIScreen.mainScreen().bounds.size.width
        return CGSize(width: width, height: 50.0)
    }
}

extension CreatePlaylistViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {

        guard let header = collectionView.visibleSupplementaryViewsOfKind(UICollectionElementKindSectionHeader).first as? ArtistDetailCollectionReusableView else { return }

        let y = ((collectionView.contentOffset.y - header.frame.origin.y) / header.frame.height) * 25.0
        header.offset(CGPointMake(0.0, y))
    }
}
