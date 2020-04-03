//
//  Emojis.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/29/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

enum TypeImage {
    case GIF
    case IMAGE
    case OTHER
}

enum TypeEmoji {
    case FREE
    case PURCHASE
    case REWARD
    case SPONSOR
}

class Emoji: NSObject {
    var emojiId : String = ""
    var emojiName : String = ""
    var emojiUrlThumbnails : String = ""
    var emojiUrlFullScreen : String = ""
    var emojiStatus : Bool = true
    var imagetype : TypeImage = .GIF
    var emojiResourceName : String = ""
    var emojiLocalPath : NSURL = NSURL(string: "")!
    var appleProductId : String = ""

    var lock : Bool = false
    var isPack : Bool = false
    var emojiType : TypeEmoji = .FREE
}
