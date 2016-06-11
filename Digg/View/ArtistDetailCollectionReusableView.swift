//
//  ArtistDetailCollectionReusableView.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/27.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class ArtistDetailCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!

    static let identifier = "ArtistDetailCollectionReusableView"

    func offset(offset: CGPoint) {
        artworkImageView.layer.frame = CGRectOffset(artworkImageView.bounds, offset.x, offset.y)
    }
}
