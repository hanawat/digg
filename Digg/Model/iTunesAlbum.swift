//
//  iTunesAlbum.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/15.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import Himotoki

struct iTunesAlbum: Decodable {

    let musics: [Album]

    static func decode(e: Extractor) throws -> iTunesAlbum {

        return try iTunesAlbum(musics: e.array("results"))
    }

    struct Album: Decodable {

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

        static func decode(e: Extractor) throws -> Album {

            return try Album(
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
