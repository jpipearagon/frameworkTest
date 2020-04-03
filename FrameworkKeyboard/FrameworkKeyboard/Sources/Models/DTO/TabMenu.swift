//
//  TabMenu.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/12/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class TabMenu: NSObject {
    var tabMenuId : String = ""
    var tabMenuName : String = ""
    var tabMenuImageOffUrl : String = ""
    var tabMenuImageOnUrl : String = ""
    var tabMenuImageNoAccess : String?

    lazy var tabMenuEmojis : [AnyObject] = []
    var sponsor : Sponsor!
}
