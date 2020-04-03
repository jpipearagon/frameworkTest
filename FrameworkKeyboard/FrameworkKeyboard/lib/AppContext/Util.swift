//
//  Util.swift
//  EmojiKeyboard
//
//  Created by Jorge on 3/04/17.
//  Copyright © 2017 com.antediem.keyboard. All rights reserved.
//

import UIKit

class Util: NSObject {

    static func getTypeOfFile(data: NSData ) -> TypeImage {
        var c = [UInt32](repeating: 0, count: 1)
        data.getBytes(&c, length: 1)
        var  type: TypeImage = .OTHER
        switch (c[0]) {
        case 0xFF, 0x89, 0x00:
            type = .IMAGE
        case 0x47:
            type = .GIF
        default:
            type = .OTHER
            print("unknown type file: \(c[0])")
        }
        
        return type
    }
}
