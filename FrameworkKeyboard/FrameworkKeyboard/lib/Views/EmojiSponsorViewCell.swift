//
//  EmojiSponsorViewCell.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 7/8/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class EmojiSponsorViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppContext.instance.getAppColor()
        // Initialization code
    }

}
