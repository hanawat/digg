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
import StoreKit
import MediaPlayer

class SimilarArtistViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var artist: String?
    var similarArtists: [LastfmSimilarArtist.Artist] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let artist = artist {

            let request = LastfmSimilarArtistRequest(artist: artist)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.similarArtists =  data.similarartists
                    self.collectionView.reloadData()
                case .Failure(let error):
                    print(error)
                }
            }
        }

        SKCloudServiceController.requestAuthorization { _ in }
        SKCloudServiceController().requestCapabilitiesWithCompletionHandler { _, _ in }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SimilarArtistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let term = similarArtists[indexPath.row].name
        let request = iTunesSearchRequest(term:term , entity: .Song, attribute: .Artist, limit: 50)
        Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    guard let trackId = data.musics.first?.trackId else { return }
                    let player = MPMusicPlayerController.applicationMusicPlayer()
                    player.setQueueWithStoreIDs([String(trackId)])
                    player.play()
                case .Failure(let error):
                    print(error)
                }
        }
    }
}

extension SimilarArtistViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimilarArtistCollectionViewCell.identifier, forIndexPath: indexPath) as! SimilarArtistCollectionViewCell
        let similarArtist = similarArtists[indexPath.row]
        let imageUrl = similarArtist.images.filter { $0.size == "large" }.first?.url ?? similarArtist.images.first?.url
        if let imageUrl = imageUrl { cell.similarArtistImageView.kf_setImageWithURL(imageUrl) }
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return similarArtists.count
    }
}
