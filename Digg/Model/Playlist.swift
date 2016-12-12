//
//  Playlist.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/12/12.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {

    dynamic var playlistId = ""
    dynamic var playlistName = "Diggin' Playlist"
    dynamic var playlistDiscription = "This is a Diggin' playlist."

    let items = List<PlaylistItem>()
}

class PlaylistItem: Object {

    dynamic var collectionId = 0
    dynamic var collectionName = ""
    dynamic var trackId = 0
    dynamic var trackName = ""
    dynamic var trackTimeMillis = 0
    dynamic var artistId = 0
    dynamic var artistName = ""
    dynamic var artworkUrl = ""
}
