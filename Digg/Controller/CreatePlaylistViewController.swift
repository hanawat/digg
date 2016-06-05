//
//  CreatePlaylistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/05.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import RealmSwift

class CreatePlaylistViewController: UIViewController {

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

        if let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension CreatePlaylistViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return playlist.items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ArtistDetaiCollectionViewCell.identifier, forIndexPath: indexPath) as! ArtistDetaiCollectionViewCell
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
