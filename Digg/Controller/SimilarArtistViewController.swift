//
//  SimilarArtistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
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

        func previewDiggAction(title: String = "Play back ", style: UIPreviewActionStyle = .Default) -> UIPreviewAction? {

            guard let artistName = self.artist else { return nil }

            return UIPreviewAction(title: title + artistName, style: style) { _, _ in

                let request = iTunesSearchRequest(term:artistName , entity: .Song, attribute: .Artist, limit: 50)
                Session.sendRequest(request) { result in
                    switch result {
                    case .Success(let data):

                        let storeIds = data.musics.flatMap { music -> String? in
                            guard let trackId = music.trackId else { return nil }
                            return String(trackId)
                        }

                        let player = MPMusicPlayerController.systemMusicPlayer()
                        player.setQueueWithStoreIDs(storeIds)
                        player.prepareToPlay()
                        player.play()

                    case .Failure(let error):
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


        if let artist = artist {

            startActivityAnimating(nil, type: .LineScalePulseOutRapid, color: nil, padding: nil)

            let request = LastfmSimilarArtistRequest(artist: artist)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.similarArtists =  data.similarartists

                case .Failure(let error):
                    print(error)
                }

                self.stopActivityAnimating()
            }
        }

        if let playerViewController = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[1] as? PlayerViewController {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: playerViewController.view.frame.size.height, right: 0.0)
        }

        if self.traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SimilarArtistViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = collectionView.indexPathForItemAtPoint(collectionView.convertPoint(location, fromView: view)),
            cell = collectionView.cellForItemAtIndexPath(indexPath),
            viewController = UIStoryboard(name: "ArtistDetail", bundle: nil).instantiateInitialViewController() as? ArtistDetailViewController  else { return nil }

        previewingContext.sourceRect = collectionView.convertRect(cell.frame, toView: view)
        viewController.artist = similarArtists[indexPath.row]
        viewController.delegate = self

        return viewController
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {

        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension SimilarArtistViewController: ArtistDetailPreviewItemDelegate {

    func showMoreSimilarArtist(name: String) {

        let similarViewController = UIStoryboard(name: "SimilarArtist", bundle: nil).instantiateInitialViewController() as! SimilarArtistViewController
        similarViewController.artist = name
        self.navigationController?.pushViewController(similarViewController, animated: true)
    }
}

extension SimilarArtistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let viewController = UIStoryboard(name: "ArtistDetail", bundle: nil).instantiateInitialViewController() as! ArtistDetailViewController
        viewController.artist = similarArtists[indexPath.row]
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

extension SimilarArtistViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimilarArtistCollectionViewCell.identifier, forIndexPath: indexPath) as! SimilarArtistCollectionViewCell
        let similarArtist = similarArtists[indexPath.row]
        cell.similarArtistNameLabel.text = similarArtist.name
        let imageUrl = similarArtist.images.filter { $0.size == "large" }.first?.url ?? similarArtist.images.first?.url

        if let imageUrl = imageUrl {
            cell.similarArtistImageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: [.Transition(.FlipFromLeft(1.0))], progressBlock: nil, completionHandler: nil)
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return similarArtists.count
    }
}

extension SimilarArtistViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = UIScreen.mainScreen().bounds.size.width / 2.0
        return CGSize(width: size, height: size)
    }
}
