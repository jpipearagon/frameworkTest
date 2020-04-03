//
//  EmojiViewCell.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/29/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class EmojiViewCell: UICollectionViewCell {
    @IBOutlet weak var image: YLImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var index: NSIndexPath
    var emoji: Emoji!
    
    func loadEmoji() {
        image.image = nil
        image.alpha = 1.0
        
        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: self.emoji.emojiName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmojiViewCell.loadEmojiFromFile as (EmojiViewCell) -> () -> ()), name:NSNotification.Name(rawValue: self.emoji.emojiName), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmojiViewCell.reloadCell as (EmojiViewCell) -> () -> ()), name:NSNotification.Name(rawValue: "reloadCell"), object: nil)
        
        
        self.indicator.startAnimating()
        self.image.image = nil
        
        let fileManager = FileManager.default
        let emoji = self.emoji
        let path = emoji?.emojiLocalPath.path
        if fileManager.fileExists(atPath: path!) {
            self.loadEmojiFromFile()
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                EmojiDao().loadEmojiThumbnail(emoji: self.emoji)
            })
        }
        
        if emoji!.lock {
            image.alpha = 1
        }
    }
    
    @objc func loadEmojiFromFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            let emoji = self.emoji
            let path = emoji?.emojiLocalPath.path
            if fileManager.fileExists(atPath: path!) {
                var data = FileManager.default.contents(atPath: path!)
                if (data != nil) {
                    let type: TypeImage = Util.getTypeOfFile(data: data! as NSData)
                    self.emoji.imagetype = type
                    if type == .GIF {
                        var image = YLGIFImage(data: data!)

                        DispatchQueue.main.async {
                                self.image.image = image
                                self.indicator.stopAnimating()
                                data = nil
                                image = nil
                        }
                        
                    } else if (type == .IMAGE) {
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async {
                            self.image.image = image
                            self.indicator.stopAnimating()
                        }
                    } else {
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                            do {
                                let documentsDirectoryURL: NSURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
                               
                                let  filePath = documentsDirectoryURL.appendingPathComponent(self.emoji.emojiResourceName)
                                let fileManager = FileManager.default
                                try fileManager.removeItem(atPath: filePath!.path)
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                            
                            EmojiDao().loadEmojiThumbnail(emoji: self.emoji)
                        })
                    }
                }
            }
        }
    }
    
    @objc func reloadCell() {
        self.image.stopAnimating()
        self.image.image = nil
        //self.image.removeFromSuperview()
        //self.image = nil
    }
    
    required init(coder aDecoder: NSCoder) {
        self.index = NSIndexPath()
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        self.index = NSIndexPath()
        super.init(frame: frame)
    }
}
