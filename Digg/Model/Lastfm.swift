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

protocol LastfmRequestType: RequestType { }

extension LastfmRequestType {

    var baseURL: NSURL {
        return NSURL(string: "http://ws.audioscrobbler.com")!
    }

    var path: String {
        return "/2.0"
    }

    var apiKey: String {
        return DiggKeys().lastfmAPIKey()
    }
}

struct LastfmSimilarArtistRequest: LastfmRequestType {

    let artist: String

    typealias Response = LastfmSimilarArtist

    let method: HTTPMethod = .GET

    var parameters: [String : AnyObject] {
        return [
            "artist": artist,
            "autocorrect": 1,
            "api_key": apiKey,
            "method": "artist.getsimilar",
            "format": "json"
        ]
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {

        return try? LastfmSimilarArtist.decodeValue(object)
    }
}

struct LastfmSimilarTrackRequest: LastfmRequestType {

    let artist: String
    let track: String

    typealias Response = LastfmSimilarTrack

    let method: HTTPMethod = .GET

    var parameters: [String : AnyObject] {
        return [
            "artist": artist,
            "track": track,
            "autocorrect": 1,
            "api_key": apiKey,
            "method": "track.getsimilar",
            "format": "json"
        ]
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {

        do { return try LastfmSimilarTrack.decodeValue(object) }
        catch { print(error); return nil }
    }
}
