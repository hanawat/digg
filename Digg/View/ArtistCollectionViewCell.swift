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

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

        let featuredHeight: CGFloat = Constant.featuredHeight
        let standardHeight: CGFloat = Constant.standardHegiht

        let delta = 1 - (featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight)

        let minAlpha: CGFloat = Constant.minAlpha
        let maxAlpha: CGFloat = Constant.maxAlpha

        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        visualEffectView.alpha = alpha

        let scale = max(delta, 0.5)
        artistLabel.transform = CGAffineTransformMakeScale(scale, scale)

        genreLabel.alpha = delta
    }
}

extension ArtistCollectionViewCell {

    struct Constant {
        static let featuredHeight: CGFloat = 280
        static let standardHegiht: CGFloat = 100

        static let minAlpha: CGFloat = 0.5
        static let maxAlpha: CGFloat = 1.0
    }
}
