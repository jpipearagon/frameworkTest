//
//  Config.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/11/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

public class Config: NSObject {
    public var API_KEY : String
    public var API_SECRET : String
    public var KEYBOARD_SHARE_TEXT : String
    public var URL_SERVICE : String
    public var URL_HOSTAPP : String
    public var URL_VIEW_KEYBOARD_SETTINGS : String
    public var TOP_BUTTON_RIGHT_TITLE : String
    public var TOP_BUTTON_LEFT_TITLE : String
    public var IMAGE_NO_ACCESS : String
    public var URL_REGISTER : String
    public var URL_LOGIN : String
    public var URL_TOKEN : String
    public var URL_SERVICE_DUMMY : String
    public var APP_PREFIX : String

    public static let instance = Config()
    
    private override init() {
        API_KEY = ""
        API_SECRET = ""
        KEYBOARD_SHARE_TEXT = ""
        URL_SERVICE = ""
        URL_HOSTAPP = ""
        URL_VIEW_KEYBOARD_SETTINGS = ""
        TOP_BUTTON_RIGHT_TITLE = ""
        TOP_BUTTON_LEFT_TITLE = ""
        IMAGE_NO_ACCESS = ""
        URL_REGISTER = ""
        URL_LOGIN = ""
        URL_TOKEN = ""
        URL_SERVICE_DUMMY = ""
        APP_PREFIX = ""

        super.init()
    }
}
