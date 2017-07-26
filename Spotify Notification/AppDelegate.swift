//
//  AppDelegate.swift
//  Spotify Notification
//
//  Created by Marcos Timm on 08/06/17.
//  Copyright © 2017 Timm. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    var current: Music?
    
    enum SpotifyAppleScript: String {
        case status     = "tell application \"Spotify\" to player state as string"
        case artist     = "tell application \"Spotify\" to artist of current track as string"
        case album      = "tell application \"Spotify\" to album of current track as string"
        case track      = "tell application \"Spotify\" to name of current track as string"
        case isOpen     = "tell application \"System Events\" to (name of processes) contains \"Spotify\""
        case artwork    = "tell application \"Spotify\" to artwork url of current track"
    }
    
    @IBOutlet weak var autoStartButton: NSMenuItem!

    let userDefaults = UserDefaults.standard
    private let startAtLoginKey = "Initialized"
    let notificationName = Notification.Name(rawValue:"SpotifyNotification")
    var statusBar:NSStatusBar = NSStatusBar()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    @IBOutlet weak var statusMenu: NSMenu!
    
    var startAtLogin: Bool {
        get {
            return userDefaults.bool(forKey: startAtLoginKey)
        }
        set {
            userDefaults.set(newValue, forKey: startAtLoginKey)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let appBundleIdentifier = "com.marcostimm.test.spotify-notif-Helper"

        let factoryDefaults = [
            startAtLoginKey: startAtLogin,
        ]
        userDefaults.register(defaults: factoryDefaults)

        if (startAtLogin) {
            autoStartButton.state = NSOnState
        }else{
            autoStartButton.state = NSOffState
        }
        
        if SMLoginItemSetEnabled(appBundleIdentifier as CFString, startAtLogin) {
            if startAtLogin {
                NSLog("Successfully add login item.")
            } else {
                NSLog("Successfully remove login item.")
            }
            
        } else {
            NSLog("Failed to add login item.")
        }
        
        NSUserNotificationCenter.default.delegate = self
        
        self.statusItem.image = NSImage(named: "logo")
        self.statusItem.menu = self.statusMenu
        self.statusItem.highlightMode = true
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.check),userInfo: nil, repeats: true)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func autoLaunchButton(_ sender: Any) {
        self.startAtLogin = !self.startAtLogin
        
        if self.startAtLogin == true {
            autoStartButton.state = NSOnState
            //autoStartButton.changeColor(NSColor(calibratedRed: 255, green: 255, blue: 255, alpha: 0.5))
        }else{
            autoStartButton.state = NSOffState
            //autoStartButton.changeColor(NSColor(calibratedRed: 255, green: 255, blue: 255, alpha: 1.0))
        }
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func check() {

        var _album = ""
        var _artist = ""
        var _track = ""
        var _artwork = URL(string: "")

        if (isOpen()) { _album = runScript(script: SpotifyAppleScript.album) }
        if (isOpen()) { _artist = runScript(script: SpotifyAppleScript.artist) }
        if (isOpen()) { _track = runScript(script: SpotifyAppleScript.track) }
        if (isOpen()) { _artwork = URL(string: runScript(script: SpotifyAppleScript.artwork)) }

        if _album != "" && _artist != "" && _track != "" && _artwork?.description != "" {

            let newMusic = Music(track: _track, album: _album, artist: _artist, artwork: _artwork!)
            
            if current != nil {
                if !newMusic.equals(compareTo: current!) {
                    current = newMusic
                    showNotification(music: current!)
                }
            } else {
                current = newMusic
                showNotification(music: current!)
                
            }
        }
    }
    
    func isOpen() -> Bool {

        return NSString(string: runScript(script: SpotifyAppleScript.isOpen)).boolValue
    }
    
    func runScript(script: SpotifyAppleScript) -> String {
        
        let script = NSAppleScript(source: script.rawValue)!
        var errorDict : NSDictionary?
        let scriptReturn = script.executeAndReturnError(&errorDict)
        if errorDict != nil {
            print("Error: %@", errorDict ?? "unknow error")
        } else {
            return scriptReturn.stringValue!
        }
        return ""
    }
    
    func showNotification(music: Music) {

        let artworkData = try? Data(contentsOf: music.ArtworkURL)
        var image = NSImage()
        if let imageData = artworkData {
            image = NSImage(data: imageData)!
        }
        
        let notification = NSUserNotification()
        notification.title = "\(music.Track)"
        notification.informativeText = "\(music.Artist)"
        notification.contentImage = image
        
        NSUserNotificationCenter.default.deliver(notification)
        
        print("Artist: \(music.Artist) | Album: \(music.Album) | Track: \(music.Track)")
    }

    @IBAction func quitAction(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }

}

