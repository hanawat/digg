//
//  PlaylistCollectionViewCell.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/30.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!

    static let identifier = "PlaylistCollectionViewCell"
}
