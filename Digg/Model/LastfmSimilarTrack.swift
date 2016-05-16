//
//  LastfmSimilarTrack.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/08.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import Himotoki

struct LastfmSimilarTrack: Decodable {

    let similartracks: [Track]

    static func decode(e: Extractor) throws -> LastfmSimilarTrack {

        return try LastfmSimilarTrack(similartracks: e.array(["similartracks", "track"]))
    }

    struct Track: Decodable {

        let name: String
        let playcount: Int
        let match: Int
        let url: NSURL
        let streamable: Streamable
        let duration: Int
        let artist: Artist
        let images: [Image]

        static func decode(e: Extractor) throws -> Track {

            let urlString = try e.value("url") as String

            guard let url = NSURL(string: urlString) else {
                throw typeMismatch("NSURL", actual: urlString)
            }

            return try Track(
                name: e.value("name"),
                playcount: e.value("playcount"),
                match: e.value("match"),
                url: url,
                streamable: e.value("streamable"),
                duration: e.value("duration"),
                artist: e.value("artist"),
                images: e.array("image")
            )
        }
    }

    struct Streamable: Decodable {

        let text: String
        let fulltrack: String

        static func decode(e: Extractor) throws -> Streamable {

            return try Streamable(
                text: e.value("#text"),
                fulltrack: e.value("fulltrack")
            )
        }
    }

    struct Artist: Decodable {

        let name: String
        let url: NSURL

        static func decode(e: Extractor) throws -> Artist {

            let urlString = try e.value("url") as String

            guard let url = NSURL(string: urlString) else {
                throw typeMismatch("NSURL", actual: urlString)
            }

            return try Artist(
                name: e.value("name"),
                url: url
            )
        }
    }

    struct Image: Decodable {

        let url: NSURL
        let size: String

        static func decode(e: Extractor) throws -> Image {

            let urlString = try e.value("#text") as String

            guard let url = NSURL(string: urlString) else {
                throw typeMismatch("NSURL", actual: urlString)
            }

            return try Image(
                url: url,
                size: e.value("size")
            )
        }
    }
}
