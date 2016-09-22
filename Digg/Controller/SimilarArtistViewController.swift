//
//  SimilarArtistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
import Himotoki
import Kingfisher
import MediaPlayer
import NVActivityIndicatorView

class SimilarArtistViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var collectionView: UICollectionView!

    var artist: String?
    var similarArtists: [LastfmSimilarArtist.Artist] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    lazy var previewActions: [UIPreviewActionItem] = {

        func previewDiggAction(_ title: String = "Play diggin' ", style: UIPreviewActionStyle = .default) -> UIPreviewAction? {

            guard let artistName = self.artist else { return nil }

            return UIPreviewAction(title: title + artistName, style: style) { _, _ in

                let request = iTunesSearchRequest(term:artistName , entity: .Song, attribute: .Artist, limit: 50)
                Session.send(request) { result in
                    switch result {
                    case .success(let data):

                        let storeIds = data.musics.flatMap { music -> String? in
                            guard let trackId = music.trackId else { return nil }
                            return String(trackId)
                        }

                        let player = MPMusicPlayerController.systemMusicPlayer()
                        player.setQueueWithStoreIDs(storeIds)
                        player.prepareToPlay()
                        player.play()

                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }

        guard let action = previewDiggAction() else { return [] }
        return [action]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.showNavigationBar(true)

        if let artist = artist {

            navigationItem.title = "Dig in " + artist
            startAnimating(nil, type: .lineScalePulseOutRapid, color: nil, padding: nil)

            let request = LastfmSimilarArtistRequest(artist: artist)
            Session.send(request) { result in
                switch result {
                case .success(let data):

                    if data.similarartists.isEmpty {
                        guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController() as? MessageViewController else { fatalError() }

                        viewController.message = "The artist you supplied could not be found"
                        self.view.addSubview(viewController.view)
                    } else {

                        self.similarArtists =  data.similarartists
                    }

                    self.stopAnimating()

                case .failure(let error):

                    print(error)
                    guard let viewController = UIStoryboard(name: "Message", bundle: nil).instantiateInitialViewController() as? MessageViewController else { fatalError() }

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

        if let playerViewController = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }

        if self.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SimilarArtistViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view)),
            let cell = collectionView.cellForItem(at: indexPath),
            let viewController = UIStoryboard(name: "ArtistDetail", bundle: nil).instantiateInitialViewController() as? ArtistDetailViewController  else { return nil }

        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        viewController.artist = similarArtists[(indexPath as NSIndexPath).row]
        viewController.delegate = self

        return viewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension SimilarArtistViewController: ArtistDetailPreviewItemDelegate {

    func showMoreSimilarArtist(_ name: String) {

        let similarViewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        similarViewController.artist = name
        self.navigationController?.pushViewController(similarViewController, animated: true)
    }
}

extension SimilarArtistViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let viewController = UIStoryboard(name: "ArtistDetail", bundle: nil).instantiateInitialViewController() as! ArtistDetailViewController
        viewController.artist = similarArtists[(indexPath as NSIndexPath).row]
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

extension SimilarArtistViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimilarArtistCollectionViewCell.identifier, for: indexPath) as! SimilarArtistCollectionViewCell
        let similarArtist = similarArtists[(indexPath as NSIndexPath).row]
        cell.similarArtistNameLabel.text = similarArtist.name
        let imageUrl = similarArtist.images.filter { $0.size == "large" }.first?.url ?? similarArtist.images.first?.url

        if let imageUrl = imageUrl {
            cell.similarArtistImageView.kf.setImage(with: imageUrl, placeholder: nil, options: [.transition(.flipFromLeft(1.0))], progressBlock: nil, completionHandler: nil)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return similarArtists.count
    }
}

extension SimilarArtistViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = UIScreen.main.bounds.size.width / 2.0
        return CGSize(width: size, height: size)
    }
}
