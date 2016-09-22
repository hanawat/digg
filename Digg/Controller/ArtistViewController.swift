//
//  ArtistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

extension MutableCollection where Indices.Iterator.Element == Index {

    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (unshuffledCount, firstUnshuffled) in zip(stride(from: c, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {

    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class ArtistViewController: UIViewController {

    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var collectionView: UICollectionView!

    var artists = ["The Beatles"]
    var songs: [MPMediaItem] = []

    var searchBar: UISearchBar = {

        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .blackTranslucent
        searchBar.placeholder = "Artist Name"

        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadArtists()

        if self.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        let titleImageView = UIImageView(image: UIImage(named: "title")!)
        navigationItem.titleView = titleImageView

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadArtists), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {

        if let frame = navigationController?.navigationBar.bounds {
            searchBar.frame = frame
        }

        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.titleView?.alpha = 0.0

        UIView.animate(withDuration: 0.5, animations: {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.titleView?.alpha = 1.0
        }, completion: { _ in
            self.navigationItem.titleView?.becomeFirstResponder()
        }) 
    }

    @IBAction func hiddenKeybord(_ sender: UITapGestureRecognizer) {
        hiddenSearchBar()
    }


    @objc private func loadArtists() {

        if let songs = MPMediaQuery.artists().items , !songs.isEmpty {

            let randomSongs = Array(songs.shuffled().prefix(100))
            artists = NSOrderedSet(array: randomSongs.flatMap { $0.albumArtist }).array as! [String]
            self.songs = randomSongs

            if collectionView.refreshControl == nil {
                collectionView.reloadData()
                return
            }

        } else {

            guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController() as? MessageViewController else { fatalError() }

            viewController.message = "Your Music application doesn't contain any tracks."
            view.addSubview(viewController.view)
            return
        }

        let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }

    fileprivate func hiddenSearchBar() {

        tapGestureRecognizer.isEnabled = false

        UIView.animate(withDuration: 0.5, animations: {
            self.navigationItem.titleView?.alpha = 0.0
        }, completion: { _ in

            self.navigationItem.titleView?.endEditing(true)
            let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.showSearchBar))
            self.navigationItem.rightBarButtonItem = barButton

            let titleImageView = UIImageView(image: UIImage(named: "title")!)
            self.navigationItem.titleView = titleImageView
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationItem.titleView?.alpha = 1.0
            }) 
        }) 
    }
}

extension ArtistViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view)),
            let cell = collectionView.cellForItem(at: indexPath),
            let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as?SimilarArtistViewController  else { return nil }

        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        viewController.artist = artists[(indexPath as NSIndexPath).row]

        return viewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension ArtistViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tapGestureRecognizer.isEnabled = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = searchBar.text
        navigationController?.pushViewController(viewController, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hiddenSearchBar()
    }
}

extension ArtistViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = artists[(indexPath as NSIndexPath).row]
        navigationController?.pushViewController(viewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: { cell?.layer.opacity = 0.7 }) 
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: { cell?.layer.opacity = 1.0 }) 
    }
}

extension ArtistViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCollectionViewCell.identifier, for: indexPath) as! ArtistCollectionViewCell
        cell.artistLabel.text = artists[(indexPath as NSIndexPath).row]

        let artworks = songs.filter { $0.albumArtist == artists[(indexPath as NSIndexPath).row] }.flatMap { $0.artwork }
        cell.artworkImageView.image = artworks.first?.image(at: cell.frame.size)

        let genre = songs.filter { $0.albumArtist == artists[(indexPath as NSIndexPath).row] }.flatMap { $0.genre }
        cell.genreLabel.text = genre.first ?? "No Genre"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return artists.count
    }
}

extension ArtistViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if velocity.y > 0.0 {
            navigationController?.hiddenNavigationBar(true)
        } else {
            navigationController?.showNavigationBar(true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let cells = collectionView.visibleCells as? [ArtistCollectionViewCell] else { return }

        cells.forEach { cell in
            let y = ((collectionView.contentOffset.y - cell.frame.origin.y) / cell.frame.height) * 25.0
            cell.offset(CGPoint(x: 0.0, y: y))
        }
    }
}

extension UINavigationController {

    func hiddenNavigationBar(_ animation: Bool) {

        let originalFrame = self.navigationBar.frame
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let offsetHeight = originalFrame.size.height + statusBarHeight

        guard originalFrame.origin.y == statusBarHeight else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.navigationBar.frame = originalFrame.offsetBy(dx: 0.0, dy: -offsetHeight)
        }) 
    }

    func showNavigationBar(_ animation: Bool) {

        let originalFrame = self.navigationBar.frame
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let offsetHeight = originalFrame.size.height + statusBarHeight

        guard originalFrame.origin.y == -originalFrame.size.height else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.navigationBar.frame = originalFrame.offsetBy(dx: 0.0, dy: offsetHeight)
        }) 
    }
}
