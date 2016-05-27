//
//  iTunes.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/14.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import APIKit

protocol iTunesRequestType: RequestType { }

extension iTunesRequestType {

    var baseURL: NSURL {
        return NSURL(string: "https://itunes.apple.com")!
    }

    var path: String {
        return "/search"
    }
}

struct iTunesSearchRequest: iTunesRequestType {

    enum SearchRequestEntity: String {
        case Artist = "musicArtist"
        case Track = "musicTrack"
        case Album = "album"
        case Video = "musicVideo"
        case Mix = "mix"
        case Song = "song"
    }

    enum SearchRequestAttribute: String {
        case Mix = "mixTerm"
        case Genre = "genreIndex"
        case Artist = "artistTerm"
        case Composer = "composerTerm"
        case Album = "albumTerm"
        case Rating = "ratingIndex"
        case Song = "songTerm"
    }

    let term: String
    let country = "JP"
    let media = "music"
    let entity: SearchRequestEntity
    let attribute: SearchRequestAttribute
    let limit: Int
    let lang = "ja_jp"

    typealias Response = iTunesMusic

    let method: HTTPMethod = .GET

    var parameters: [String : AnyObject] {
        return [
            "term": term,
            "country": country,
            "media": media,
            "entity": entity.rawValue,
            "attribute": attribute.rawValue,
            "limit": limit,
            "lang": lang
        ]
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        do { return try iTunesMusic.decodeValue(object) }
        catch { print(error); return nil }
    }
}

