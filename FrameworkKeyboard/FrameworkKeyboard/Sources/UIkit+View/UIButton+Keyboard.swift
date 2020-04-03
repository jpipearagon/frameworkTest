//
//  UIButton+Extension.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 6/17/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

extension UIButton {
    
    private struct CustomProperties {
        static var TabName  = "TabMenu"
    }

    var TabMenuName: String? {
        get {
            return objc_getAssociatedObject(self, &CustomProperties.TabName) as? String
        }
        set {
            objc_setAssociatedObject(self, &CustomProperties.TabName, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
