//
//  Music.swift
//  Spotify Notification
//
//  Created by Marcos Timm on 20/07/17.
//  Copyright © 2017 Timm. All rights reserved.
//

import Foundation

enum MusicStatus: String {
    case Paused = "paused"
    case Playing = "playing"
}

class Music {
    
    var Track: String
    var Album: String
    var Artist: String
    var ArtworkURL: URL
    var Status: MusicStatus?

    init(track: String, album: String, artist: String, artwork: URL) {
    
        self.Track = track
        self.Album = album
        self.Artist = artist

        let artworkString = String(describing: artwork)
        self.ArtworkURL = URL(string:  artworkString.replacingOccurrences(of: "http://", with: "https://"))!
    }

    func equals (compareTo:Music) -> Bool {
        return
            self.Track == compareTo.Track &&
            self.Album == compareTo.Album &&
            self.Artist == compareTo.Artist
    }
    
}
