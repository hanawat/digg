//
//  ArtistCollectionViewCell.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/22.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class ArtistCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    static let identifier = "ArtistCollectionViewCell"

    func offset(_ offset: CGPoint) {
        artworkImageView.layer.frame = artworkImageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
}
