//
//  OtherActionViewCell.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/24/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class OtherActionViewCell: UITableViewCell {
    @IBOutlet weak var emojiIcon: UIImageView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var textAction: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        registerPostNotifications()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func registerPostNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "changeAppColor"), object: nil)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeAppColor), name:NSNotification.Name(rawValue: "changeAppColor"), object: nil)
    }
    
    @objc func changeAppColor() {
        self.backgroundColor = AppContext.instance.getTabButtonColor()
    }
}
