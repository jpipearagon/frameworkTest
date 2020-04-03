//
//  EmojiKeyBoardService.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/18/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class EmojiKeyBoardService: NSObject {
    func loadTabs(success: @escaping (_ listOfTabs: [TabMenu]) -> Void, failure:@escaping (_ error: NSError) -> Void)  {
        TabMenuDao().loadEmojiTabsJson (success: { listOfTabs in
            success (listOfTabs)
        }) { error in failure(error) }
    }
}
