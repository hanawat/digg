//
//  ArtistDetailViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
import Himotoki
import RealmSwift
import MediaPlayer
import NVActivityIndicatorView

protocol ArtistDetailPreviewItemDelegate: class {

    func showMoreSimilarArtist(_ name: String)
}

extension UICollectionView {

    func indexPathForSupplementaryView(_ elementKind: String, atPoint point: CGPoint) -> IndexPath? {

        for section in 0..<self.numberOfSections {
            let indexPath = IndexPath(row: 0, section: section)
            if let layoutAttribute = self.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) , layoutAttribute.frame.contains(point) { return indexPath }
        }

        return nil
    }
}

class ArtistDetailViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: ArtistDetailPreviewItemDelegate?

    var artist: LastfmSimilarArtist.Artist?
    var albums: [iTunesMusic.Album] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var originalFrame = CGRect.zero
    var pannedIndexPath: IndexPath?

    lazy var previewActions: [UIPreviewActionItem] = {

        func previewDigAction() -> UIPreviewAction? {

            guard let artistName = self.artist?.name else { return nil }

            return UIPreviewAction(title: "Dig in " + artistName, style: .default) { _, _ in

                self.delegate?.showMoreSimilarArtist(artistName)
            }
        }

        func previewPlayAction() -> UIPreviewAction? {

            guard let artistName = self.artist?.name,
                let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController else { return nil }

            return UIPreviewAction(title: "Play " + artistName, style: .default) { _, _ in

                // TODO: Make All Track Album
                let collectionIds = self.albums.flatMap { String($0.collectionId) }
                playerViewController.player.setQueueWithStoreIDs(collectionIds)
                playerViewController.player.play()
            }
        }

        guard let dig = previewDigAction(),
            let play = previewPlayAction() else { return [] }

        return [dig, play]
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = UIImage(named: "record-player") {
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showPlaylist))
            navigationItem.rightBarButtonItem = barButtonItem
        }

        if let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }

        if let artist = artist {

            navigationItem.title = artist.name
            startAnimating(nil, type: .lineScalePulseOutRapid, color: nil, padding: nil)

            let request = iTunesSearchRequest(term:artist.name , entity: .Song, attribute: .Artist, limit: 50)
            Session.send(request) { result in
                switch result {
                case .success(let data):

                    if data.musics.isEmpty {

                        // TODO: UIViewController Extension
                        guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController() as? MessageViewController else { fatalError() }

                        viewController.message = "The artist you supplied could not be found"
                        self.view.addSubview(viewController.view)
                    } else {

                        self.albums = iTunesMusic.albums(data.musics)
                    }

                    self.stopAnimating()

                case .failure(let error):

                    print(error)
                    guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController() as? MessageViewController else { return }

                    switch error {
                    case .responseError(let error):
                        if error is DecodeError { break }
                        viewController.message = error.localizedDescription

                    case .requestError(let error):
                        viewController.message = error.localizedDescription

                    case .connectionError(let error):
                        viewController.message = error.localizedDescription
                    }

                    self.stopAnimating()
                    self.view.addSubview(viewController.view)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private Methods

    @objc fileprivate func showPlaylist() {

        guard let viewController = UIStoryboard(name: "CreatePlaylist", bundle: nil).instantiateInitialViewController() as? CreatePlaylistViewController else { return }

        show(viewController, sender: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ArtistDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
            let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) else { return false }

        let location = panGesture.translation(in: collectionView.cellForItem(at: indexPath))
        pannedIndexPath = fabs(location.x) > fabs(location.y) ? indexPath : nil
        return fabs(location.x) > fabs(location.y) && location.x > 0.0 ? true : false
    }
}

// MARK: - UICollectionViewDelegate
extension ArtistDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController else { return }

        let trackIds = albums[indexPath.section].tracks.flatMap { item -> String? in
            guard let trackId = item.trackId else { return nil }
            return String(trackId)
        }

        playerViewController.playlist = nil
        playerViewController.album = albums[indexPath.section]

        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: trackIds)
        descriptor.startItemID = trackIds[indexPath.row]
        playerViewController.player.setQueueWith(descriptor)

        playerViewController.player.prepareToPlay(completionHandler: { error in

            if error == nil {
                playerViewController.player.play()
            } else {

                self.showAlertMessage(error?.localizedDescription)
                print(error?.localizedDescription)
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.layer.opacity = 0.7
            cell?.layer.backgroundColor = UIColor(white: 0.1, alpha: 1.0).cgColor
        }) 
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.layer.opacity = 1.0
            cell?.layer.backgroundColor = UIColor.black.cgColor
        }) 
    }
}

// MARK: - UICollectionViewDataSource
extension ArtistDetailViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return albums.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums[section].tracks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicTrackCollectionViewCell.identifier, for: indexPath) as! MusicTrackCollectionViewCell
        let music =  albums[(indexPath as NSIndexPath).section].tracks[indexPath.row]

        cell.trackNameLabel.text = music.trackName
        cell.trackArtistLabel.text = music.artistName
        cell.trackTimeMillis = music.trackTimeMillis

        if let isStreamable = music.isStreamable {
            cell.trackNameLabel.alpha = isStreamable ? 1.0 : 0.3
            cell.trackArtistLabel.alpha = isStreamable ? 0.7 : 0.3
            cell.trackTimeLabel.alpha = isStreamable ? 0.7 : 0.3
            cell.isUserInteractionEnabled = isStreamable ? true : false
        }

        if let isStreamable = albums[(indexPath as NSIndexPath).section].tracks[indexPath.row].isStreamable , isStreamable {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(trackCellPanGesture(_:)))
            panGesture.delegate = self
            cell.addGestureRecognizer(panGesture)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ArtistDetailCollectionReusableView.identifier, for: indexPath) as! ArtistDetailCollectionReusableView
        let album =  albums[(indexPath as NSIndexPath).section]
        header.albumTitleLabel.text = album.collectionName
        header.albumArtistLabel.text = album.artistName
        header.artworkImageView.kf.setImage(with: album.artworkUrl, placeholder: UIImage(named: "logo-long"), options: [.transition(.fade(1.0))], progressBlock: nil, completionHandler: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playAlbum(_:)))
        header.addGestureRecognizer(tapGesture)

        return header
    }

    @objc fileprivate func trackCellPanGesture(_ sender: UIPanGestureRecognizer) {

        guard let pannedIndexPath = pannedIndexPath,
            let cell = collectionView.cellForItem(at: pannedIndexPath) as? MusicTrackCollectionViewCell else { return }

        switch sender.state {
        case .began:
            originalFrame = cell.frame

        case .changed:
            let translation = sender.translation(in: cell)
            cell.frame = translation.x > 0.0 ? originalFrame.offsetBy(dx: translation.x, dy: 0.0) : originalFrame

            let percentage = translation.x > 0.0 ? translation.x / cell.bounds.width : 0.0
            cell.contentView.backgroundColor = UIColor(red: percentage, green: 0.0, blue: percentage, alpha: 1.0)

        case .ended:
            UIView.animate(withDuration: 0.2, animations: {
                cell.contentView.backgroundColor = UIColor.black
            })

            guard let indexPath = collectionView.indexPath(for: cell)
                , cell.frame.origin.x > cell.frame.size.width / 3.0 else {
                    UIView.animate(withDuration: 0.2, animations: { cell.frame = self.originalFrame }) ; return
            }

            collectionView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                cell.frame = self.originalFrame.offsetBy(dx: cell.frame.size.width, dy: 0.0)

                }, completion: { _ in
                    cell.frame = self.originalFrame.offsetBy(dx: -cell.frame.size.width, dy: 0.0)

                    UIView.animate(withDuration: 0.2, animations: {
                        cell.frame = self.originalFrame

                    }, completion: { _ in
                        self.collectionView.isUserInteractionEnabled = true
                    })
            })

            addPlaylist(indexPath)

        default:
            return
        }
    }

    @objc fileprivate func addPlaylist(_ indexPath: IndexPath) {

        guard let realm = try? Realm() else { return }

        let playlist = realm.objects(Playlist.self).last ?? Playlist()
        let item = PlaylistItem()
        let track = albums[(indexPath as NSIndexPath).section].tracks[indexPath.row]

        item.collectionId = track.collectionId ?? 0
        item.collectionName = track.collectionName ?? ""
        item.trackId = track.trackId ?? 0
        item.trackName = track.trackName ?? ""
        item.artistId = track.artistId ?? 0
        item.artistName = track.artistName ?? ""
        item.trackTimeMillis = track.trackTimeMillis ?? 0
        item.artworkUrl = track.artworkUrl100 ?? ""

        do {
            try realm.write() {
                playlist.items.append(item)
                realm.add(playlist)
            }
        } catch {
            fatalError()
        }
    }

    @objc fileprivate func playAlbum(_ sender: UITapGestureRecognizer) {

        guard let artist = artist else { return }

        let similarViewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        similarViewController.artist = artist.name
        self.navigationController?.pushViewController(similarViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ArtistDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: 60.0)
    }
}

// MARK: - UIScrollViewDelegate
extension ArtistDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let visibleHeaders = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader) as? [ArtistDetailCollectionReusableView] else { return }

        visibleHeaders.forEach { header in
            let y = ((collectionView.contentOffset.y - header.frame.origin.y) / header.frame.height) * 25.0
            header.offset(CGPoint(x: 0.0, y: y))
        }
    }
}
