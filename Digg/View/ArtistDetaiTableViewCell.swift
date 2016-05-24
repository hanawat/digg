//
//  ArtistDetaiTableViewCell.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/24.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit

class ArtistDetaiTableViewCell: UITableViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!

    static let identifier = "ArtistDetaiTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
