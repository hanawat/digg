//
//  Lastfm.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/08.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import APIKit
import Keys

protocol LastfmRequestType: Request { }

extension LastfmRequestType {

    var baseURL: URL {
        return URL(string: "http://ws.audioscrobbler.com")!
    }

    var path: String {
        return "/2.0"
    }

    var apiKey: String {
        return DiggKeys().lastfmAPIKey
    }
}

struct LastfmSimilarArtistRequest: LastfmRequestType {

    let artist: String

    typealias Response = LastfmSimilarArtist

    let method: HTTPMethod = .get

    var parameters: Any? {
        return [
            "artist": artist as AnyObject,
            "autocorrect": 1 as AnyObject,
            "api_key": apiKey as AnyObject,
            "method": "artist.getsimilar" as AnyObject,
            "format": "json" as AnyObject
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LastfmSimilarArtist {

        return try LastfmSimilarArtist.decodeValue(object)
    }
}

struct LastfmSimilarTrackRequest: LastfmRequestType {

    let artist: String
    let track: String

    typealias Response = LastfmSimilarTrack

    let method: HTTPMethod = .get

    var parameters: Any? {
        return [
            "artist": artist as AnyObject,
            "track": track as AnyObject,
            "autocorrect": 1 as AnyObject,
            "api_key": apiKey as AnyObject,
            "method": "track.getsimilar" as AnyObject,
            "format": "json" as AnyObject
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LastfmSimilarTrack {

        return try LastfmSimilarTrack.decodeValue(object)
    }
}
