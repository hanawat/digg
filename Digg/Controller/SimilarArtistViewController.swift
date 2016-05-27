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

@IBDesignable class GradientView: UIView {

    var gradientLayer: CAGradientLayer?

    @IBInspectable var topColor: UIColor = UIColor.whiteColor() {
        didSet { gradient() }
    }

    @IBInspectable var bottomColor: UIColor = UIColor.blackColor() {
        didSet { gradient() }
    }

    func gradient() {

        gradientLayer?.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()

        guard let gradientLayer = gradientLayer else { return }

        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        gradientLayer.frame.size = frame.size
        gradientLayer.frame.origin = CGPointMake(0.0, 0.0)
        gradientLayer.zPosition = -100.0
        layer.insertSublayer(gradientLayer, atIndex: 0)
        layer.masksToBounds = true
    }
}

class SimilarArtistViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var artist: String?
    var similarArtists: [LastfmSimilarArtist.Artist] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let artist = artist {

            let request = LastfmSimilarArtistRequest(artist: artist)
            Session.sendRequest(request) { result in
                switch result {
                case .Success(let data):
                    self.similarArtists =  data.similarartists
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

extension SimilarArtistViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let viewController = UIStoryboard(name: "ArtistDetail", bundle: nil).instantiateInitialViewController() as! ArtistDetailViewController
        viewController.artist = similarArtists[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SimilarArtistViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SimilarArtistCollectionViewCell.identifier, forIndexPath: indexPath) as! SimilarArtistCollectionViewCell
        let similarArtist = similarArtists[indexPath.row]
        cell.similarArtistNameLabel.text = similarArtist.name
        let imageUrl = similarArtist.images.filter { $0.size == "large" }.first?.url ?? similarArtist.images.first?.url
        if let imageUrl = imageUrl { cell.similarArtistImageView.kf_setImageWithURL(imageUrl) }
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
