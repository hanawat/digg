//
//  CreatePlaylistCollectionReusableView.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/06.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class CreatePlaylistCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var playlistTitleLabel: UITextField!
    @IBOutlet weak var descriptionLabel: UITextField!
    @IBOutlet weak var artworkImageView: UIImageView!

    static let identifier = "CreatePlaylistCollectionReusableView"

    func offset(offset: CGPoint) {
        artworkImageView.layer.frame = CGRectOffset(artworkImageView.bounds, offset.x, offset.y)
    }
}
