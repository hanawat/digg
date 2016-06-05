//
//  ArtistDetaiCollectionViewCell.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class ArtistDetaiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackTimeLabel: UILabel!
    @IBOutlet weak var addPlaylistButton: UIButton!

    static let identifier = "ArtistDetaiCollectionViewCell"
    
    var trackTimeMillis: Int? {
        didSet {

            guard let trackTimeMillis = trackTimeMillis else { return }

            let min = trackTimeMillis / 1000 / 60 % 60
            let sec = trackTimeMillis / 1000 % 60
            trackTimeLabel.text = "\(min):\(sec)"
        }
    }
}
