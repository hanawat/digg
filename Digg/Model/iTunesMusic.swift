//
//  iTunesMusic.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/15.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import Himotoki
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

struct iTunesMusic: Decodable {

    let musics: [Music]

    static func albums(_ musics: [Music]) -> [Album] {

        let collectionIds = NSOrderedSet(array: musics.flatMap { $0.collectionId }).array as! [Int]

        return collectionIds.flatMap { collectionId -> Album? in

            let tracks =  musics.filter { music in
                guard let id = music.collectionId else { return false }
                return id == collectionId
            }

            guard let artistName = tracks.first?.artistName,
                let collectionName = tracks.first?.collectionName,
                let artworkUrl100 = tracks.first?.artworkUrl100,
                let artworkUrl = artworkUrl512(artworkUrl100) else { return nil }

            return Album(artistName: artistName,collectionId: collectionId, collectionName: collectionName, artworkUrl: artworkUrl, tracks: tracks)
        }
    }

    static func artworkUrl512(_ artworkUrl100: String?) -> URL? {

        guard let artworkUrl100 = artworkUrl100,
            let artworkUrl512 = URL(string: artworkUrl100.replacingOccurrences(of: "100x100", with: "512x512")) else { return nil }

        return artworkUrl512
    }

    struct Album {
        let artistName: String
        let collectionId: Int
        let collectionName: String
        let artworkUrl: URL
        let tracks: [Music]
    }

    static func decode(_ e: Extractor) throws -> iTunesMusic {

        return try iTunesMusic(musics: e.array("results"))
    }

    struct Music: Decodable {

        let wrapperType: String?
        let kind: String?
        let artistId: Int?
        let collectionId: Int?
        let trackId: Int?
        let artistName: String?
        let collectionName: String?
        let trackName: String?
        let collectionCensoredName: String?
        let trackCensoredName: String?
        let artistViewUrl: String?
        let collectionViewUrl :String?
        let trackViewUrl: String?
        let previewUrl: String?
        let artworkUrl30: String?
        let artworkUrl60: String?
        let artworkUrl100: String?
        let collectionPrice: Int?
        let releaseDate: String?
        let collectionExplicitness: String?
        let trackExplicitness: String?
        let discCount: Int?
        let discNumber: Int?
        let trackCount: Int?
        let trackNumber: Int?
        let trackTimeMillis: Int?
        let country: String?
        let currency: String?
        let primaryGenreName: String?
        let contentAdvisoryRating: String?
        let isStreamable: Bool?

        static func decode(_ e: Extractor) throws -> Music {

            return try Music(
                wrapperType: e.valueOptional("wrapperType"),
                kind: e.valueOptional("kind"),
                artistId: e.valueOptional("artistId"),
                collectionId: e.valueOptional("collectionId"),
                trackId: e.valueOptional("trackId"),
                artistName: e.valueOptional("artistName"),
                collectionName: e.valueOptional("collectionName"),
                trackName: e.valueOptional("trackName"),
                collectionCensoredName: e.valueOptional("collectionCensoredName"),
                trackCensoredName: e.valueOptional("trackCensoredName"),
                artistViewUrl: e.valueOptional("artistViewUrl"),
                collectionViewUrl: e.valueOptional("collectionViewUrl"),
                trackViewUrl: e.valueOptional("trackViewUrl"),
                previewUrl: e.valueOptional("previewUrl"),
                artworkUrl30: e.valueOptional("artworkUrl30"),
                artworkUrl60: e.valueOptional("artworkUrl60"),
                artworkUrl100: e.valueOptional("artworkUrl100"),
                collectionPrice: e.valueOptional("collectionPrice"),
                releaseDate: e.valueOptional("releaseDate"),
                collectionExplicitness: e.valueOptional("collectionExplicitness"),
                trackExplicitness: e.valueOptional("trackExplicitness"),
                discCount: e.valueOptional("discCount"),
                discNumber: e.valueOptional("discNumber"),
                trackCount: e.valueOptional("trackCount"),
                trackNumber: e.valueOptional("trackNumber"),
                trackTimeMillis: e.valueOptional("trackTimeMillis"),
                country: e.valueOptional("country"),
                currency: e.valueOptional("currency"),
                primaryGenreName: e.valueOptional("primaryGenreName"),
                contentAdvisoryRating: e.valueOptional("contentAdvisoryRating"),
                isStreamable: e.valueOptional("isStreamable")
            )
        }
    }
}
