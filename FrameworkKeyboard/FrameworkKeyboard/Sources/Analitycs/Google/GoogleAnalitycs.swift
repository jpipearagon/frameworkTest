//
//  GoogleAnalitycs.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 6/15/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit
import Firebase


class GoogleAnalitycs: NSObject {
    static let instance = GoogleAnalitycs()
    
    private override init() {
        super.init()
        self.setUpGoogleAnalitycs()
    }
    
    func setUpGoogleAnalitycs() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
    }
    
    func sendViewTrack(screenName: String) {
        Analytics.logEvent("keyboard", parameters: [
            "screenName": screenName
        ])
    }
    
    func sendEventTrack(category: String, eventName: String, label: String) {
        Analytics.logEvent(category, parameters: [
            "action": eventName,
            "label": label
        ])
    }
}
