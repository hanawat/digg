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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var collectionView: UICollectionView!

    var artists = ["The Beatles"]
    var songs: [MPMediaItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let songs = MPMediaQuery.artistsQuery().items {
            artists = NSOrderedSet(array: songs.flatMap { $0.albumArtist }).array as! [String]
            self.songs = songs
        }

        if self.traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func showSearchBar(sender: UIBarButtonItem) {

        UIView.animateWithDuration(0.2) {
            self.searchBar.alpha = self.searchBar.alpha > 0.0 ? 0.0 : 1.0
        }
    }

    @IBAction func hiddenKeybord(sender: UITapGestureRecognizer) {

        view.endEditing(true)
        tapGestureRecognizer.enabled = false
    }
}

extension ArtistViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = collectionView.indexPathForItemAtPoint(collectionView.convertPoint(location, fromView: view)),
            cell = collectionView.cellForItemAtIndexPath(indexPath),
            viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as?SimilarArtistViewController  else { return nil }

        previewingContext.sourceRect = collectionView.convertRect(cell.frame, toView: view)
        viewController.artist = artists[indexPath.row]

        return viewController
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {

        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension ArtistViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

        tapGestureRecognizer.enabled = true
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = searchBar.text
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ArtistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = artists[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }

    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        UIView.animateWithDuration(0.2) { cell?.layer.opacity = 0.7 }
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        UIView.animateWithDuration(0.2) { cell?.layer.opacity = 1.0 }
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
