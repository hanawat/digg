//
//  Lastfm.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/05/08.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation
import APIKit

protocol LastfmRequestType: RequestType { }

extension LastfmRequestType {

    var baseURL: NSURL {
        return NSURL(string: "http://ws.audioscrobbler.com")!
    }

    var path: String {
        return "/2.0"
    }

    var apiKey: String {
        return "78ed1d74ab6d35dfffda7623a03758c9"
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

struct SimilarTrackRequest: LastfmRequestType {

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
