//
//  ArtistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer
import NVActivityIndicatorView

class ArtistViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var collectionView: UICollectionView!

    var artists = [String]()
    var songs = [MPMediaItem]()

    var searchBar: UISearchBar = {

        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .blackTranslucent
        searchBar.placeholder = "Artist Name"

        return searchBar
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        switch MPMediaLibrary.authorizationStatus() {
        case .authorized:
            loadArtists()
        default:
            let userDefaults = UserDefaults.standard
            userDefaults.set(false, forKey: "isShowedAuthorizationAlert")
            userDefaults.synchronize()

            startAnimating(nil, type: .lineScalePulseOutRapid, color: nil, padding: nil)
            MPMediaLibrary.requestAuthorization{ status in

                switch status {
                case .authorized:
                    let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.loadArtists()
                        self.stopAnimating()
                    }
                default:
                    DispatchQueue.main.async {
                        self.showAlertMessage("Access to the Music Library is unauthorized.")
                        self.stopAnimating()
                    }
                }
            }
        }

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

    // MARK: - Action Methods

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

    // MARK: - Private Methods

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

// MARK: - UIViewControllerPreviewingDelegate
extension ArtistViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view)),
            let cell = collectionView.cellForItem(at: indexPath),
            let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as?SimilarArtistViewController  else { return nil }

        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        viewController.artist = artists[indexPath.row]

        return viewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - UISearchBarDelegate
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

// MARK: - UICollectionViewDelegate
extension ArtistViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let viewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        viewController.artist = artists[indexPath.row]
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

// MARK: - UICollectionViewDataSource
extension ArtistViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCollectionViewCell.identifier, for: indexPath) as! ArtistCollectionViewCell

        let artist = artists[indexPath.row]
        cell.artistLabel.text = artist

        let artworks = songs.filter { $0.albumArtist == artist || $0.artist == artist }.flatMap { $0.artwork }
        cell.artworkImageView.image = artworks.first?.image(at: cell.frame.size) ?? UIImage(named: "logo-long")

        let genre = songs.filter { $0.albumArtist == artist }.flatMap { $0.genre }
        cell.genreLabel.text = genre.first ?? "No Genre"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return artists.count
    }
}

// MARK: - UIScrollViewDelegate
extension ArtistViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        guard scrollView.contentOffset.y > -40.0 else { return }

        if velocity.y > 0.0 {
            navigationController?.hiddenNavigationBar(true)
        } else {
            navigationController?.showNavigationBar(true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y < -40.0 {
            navigationController?.showNavigationBar(true)
        }

        guard let cells = collectionView.visibleCells as? [ArtistCollectionViewCell] else { return }

        cells.forEach { cell in
            let y = ((collectionView.contentOffset.y - cell.frame.origin.y) / cell.frame.height) * 25.0
            cell.offset(CGPoint(x: 0.0, y: y))
        }
    }
}
