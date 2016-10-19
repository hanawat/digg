//
//  iTunes.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/14.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import APIKit

class Utility {

    static var isJapanese: Bool {

        guard let language = Locale.preferredLanguages.first else { return false }
        return language.hasPrefix("ja-")
    }
}

protocol iTunesRequestType: Request { }

extension iTunesRequestType {

    var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
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
    let country = UserDefaults.standard.string(forKey: "countryCode")
    let media = "music"
    let entity: SearchRequestEntity
    let attribute: SearchRequestAttribute
    let limit: Int
    let lang = Utility.isJapanese ? "ja_jp" : "en_us"

    typealias Response = iTunesMusic

    let method: HTTPMethod = .get

    var parameters: Any? {
        return [
            "term": term as AnyObject,
            "country": country as AnyObject,
            "media": media as AnyObject,
            "entity": entity.rawValue as AnyObject,
            "attribute": attribute.rawValue as AnyObject,
            "limit": limit as AnyObject,
            "lang": lang as AnyObject
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> iTunesMusic {

        return try iTunesMusic.decodeValue(object)
    }
}

