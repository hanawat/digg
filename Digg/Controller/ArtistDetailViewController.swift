//
//  ArtistDetailViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import APIKit
import MediaPlayer
import StoreKit

class ArtistDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var artist: LastfmSimilarArtist.Artist?
    var musics: [iTunesAlbum.Album] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SKCloudServiceController.requestAuthorization { _ in }
        SKCloudServiceController().requestCapabilitiesWithCompletionHandler { _, _ in }

        if let artist = artist {

            let request = iTunesSearchRequest(term:artist.name , entity: .Song, attribute: .Artist, limit: 50)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.musics = data.musics
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ArtistDetailViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let trackId = musics[indexPath.row].trackId else { return }
        let player = MPMusicPlayerController.systemMusicPlayer()
        player.setQueueWithStoreIDs([String(trackId)])
        player.play()
    }
}

extension ArtistDetailViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(ArtistDetaiTableViewCell.identifier) as! ArtistDetaiTableViewCell
        let music =  musics[indexPath.row]
        cell.trackNameLabel.text = music.trackName
        if let imageString = music.artworkUrl100 ?? music.artworkUrl60 ?? music.artworkUrl30,
            imageUrl = NSURL(string: imageString) {
            cell.artworkImageView.kf_setImageWithURL(imageUrl)
        }

        return cell
    }
}
