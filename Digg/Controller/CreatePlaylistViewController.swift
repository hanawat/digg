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

    static let identifier = "CreatePlaylistViewController"

    var playlist = Playlist() {
        didSet {
            collectionView.reloadData()
        }
    }

    var originalFrame = CGRect.zero
    var pannedIndexPath: IndexPath?
    var isModal = false

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let realm = try? Realm() else { return }
        playlist = realm.objects(Playlist.self).last ?? Playlist()

        navigationItem.title = playlist.playlistName

        if let image = UIImage(named: "itunes-logo") {
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(createiTunesPlaylist))
            navigationItem.rightBarButtonItem = barButtonItem
        }

        if isModal {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
            navigationItem.leftBarButtonItem = barButtonItem
        }

        if let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc fileprivate func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func createiTunesPlaylist() {

        if playlist.items.isEmpty {
            showAlertMessage("Please add several songs.")
            return
        }

        navigationItem.rightBarButtonItem?.isEnabled = false
        startAnimating(nil, message:"Exports to Music...", type: .lineScaleParty, color: nil, padding: nil)

        let library = MPMediaLibrary.default()
        let metadata = MPMediaPlaylistCreationMetadata(name: playlist.playlistName)
        metadata.descriptionText = playlist.playlistDiscription

        library.getPlaylist(with: UUID(), creationMetadata: metadata) { playlist, error in
            if error != nil { print(error); return }

            let delayTime = DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {

                let trackIds = self.playlist.items.map { String($0.trackId) }
                let offset = trackIds.count - 1
                trackIds.enumerated().forEach { trackId in

                    playlist?.addItem(withProductID: trackId.element) { error in

                        if error != nil { print(error) }
                        if trackId.offset == offset {

                            DispatchQueue.main.async {
                                self.stopAnimating()
                                self.navigationItem.rightBarButtonItem?.isEnabled = true

                                guard let realm = try? Realm() else { return }
                                self.playlist = Playlist()

                                do {
                                    try realm.write() {
                                        realm.add(self.playlist)
                                    }
                                } catch {
                                    print("Realm writing error.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CreatePlaylistViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
            let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) else { return false }

        let location = panGesture.translation(in: collectionView.cellForItem(at: indexPath))
        pannedIndexPath = fabs(location.x) > fabs(location.y) ? indexPath : nil
        return fabs(location.x) > fabs(location.y) && location.x < 0.0 ? true : false
    }
}

extension CreatePlaylistViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        guard let realm = try? Realm(),
            let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).first as? CreatePlaylistCollectionReusableView,
            let playlistName = header.playlistTitleLabel.text,
            let playlistDescription = header.descriptionLabel.text else { return true }

        do {
            try realm.write() {
                playlist.playlistName = playlistName
                playlist.playlistDiscription = playlistDescription
            }
        } catch {
            print("Realm writing error.")
        }

        navigationItem.title = playlist.playlistName

        return true
    }
}

extension CreatePlaylistViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController else { return }

        let trackIds = playlist.items.flatMap { String($0.trackId) } as [String]

        playerViewController.album = nil
        playerViewController.playlist = playlist

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

extension CreatePlaylistViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return playlist.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicTrackCollectionViewCell.identifier, for: indexPath) as! MusicTrackCollectionViewCell
        let music = playlist.items[indexPath.row]

        cell.trackNameLabel.text = music.trackName
        cell.trackArtistLabel.text = music.artistName
        cell.trackTimeMillis = music.trackTimeMillis

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(trackCellPanGesture(_:)))
        panGesture.delegate = self
        cell.addGestureRecognizer(panGesture)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CreatePlaylistCollectionReusableView.identifier, for: indexPath) as! CreatePlaylistCollectionReusableView
        header.playlistTitleLabel.text = playlist.playlistName
        header.descriptionLabel.text = playlist.playlistDiscription

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
            cell.frame = translation.x < 0.0 ? originalFrame.offsetBy(dx: translation.x, dy: 0.0) : originalFrame


        case .ended:
            guard let indexPath = collectionView.indexPath(for: cell)
                , cell.frame.origin.x < -cell.frame.size.width / 2.0 else {
                    UIView.animate(withDuration: 0.2, animations: { cell.frame = self.originalFrame }) ; return
            }

            UIView.animate(withDuration: 0.2, animations: {
                cell.frame = self.originalFrame.offsetBy(dx: -cell.frame.size.width, dy: 0.0)

                }, completion: { _ in
                    cell.alpha = 0.0
                    self.removePlaylist(indexPath)
            })


        default:
            return
        }
    }

    @objc fileprivate func removePlaylist(_ indexPath: IndexPath) {

        guard let realm = try? Realm() else { return }

        do {
            try realm.write() {
                collectionView.performBatchUpdates({
                    self.playlist.items.remove(objectAtIndex: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    }, completion: nil)
            }
        } catch {
            fatalError()
        }
    }
}

extension CreatePlaylistViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: 60.0)
    }
}

extension CreatePlaylistViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).first as? ArtistDetailCollectionReusableView else { return }

        let y = ((collectionView.contentOffset.y - header.frame.origin.y) / header.frame.height) * 25.0
        header.offset(CGPoint(x: 0.0, y: y))
    }
}
