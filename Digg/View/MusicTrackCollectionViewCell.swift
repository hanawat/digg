//
//  MusicTrackCollectionViewCell.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class MusicTrackCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackTimeLabel: UILabel!

    static let identifier = "MusicTrackCollectionViewCell"

    var trackTimeMillis: Int? {
        didSet {

            guard let trackTimeMillis = trackTimeMillis else { return }

            let min = trackTimeMillis / 1000 / 60 % 60
            let sec = trackTimeMillis / 1000 % 60
            trackTimeLabel.text = "\(min):\(String(format: "%02d", sec))"
        }
    }
}
