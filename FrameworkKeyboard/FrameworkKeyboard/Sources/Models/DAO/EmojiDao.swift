//
//  EmojiDao.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 6/9/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class EmojiDao: NSObject {
    
    func loadEmojiThumbnail(emoji: Emoji) {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(emoji.emojiResourceName)
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            let headers : [String : String] = ["api_key": Config.instance.API_KEY]
            
            Alamofire.download(URL(string: emoji.emojiUrlThumbnails)!, method: .post, headers: headers, to: destination).response(completionHandler: { (DefaultDownloadResponse) in
                if DefaultDownloadResponse.error == nil {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: emoji.emojiName), object: nil)
                }
            })
    }
    
    func loadEmojiFullScreen(url :URL, success: @escaping (_ response: Data) -> Void, failure:@escaping (_ error: Error) -> Void) {
        let headers : [String : String] = [
            "api_key": Config.instance.API_KEY]
        
        Alamofire.request(url, method: .post, headers: headers)
            .validate()
            .responseData { response in switch response.result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure(error)
                }
        }
    }
    
    func loadImageBy(name:String, url:String) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(name)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                
                }
            }
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let headers : [String : String] = ["api_key": Config.instance.API_KEY]
        
        Alamofire.download(URL(string: url)!, method: .post, headers: headers, to: destination).response(completionHandler: { (DefaultDownloadResponse) in
            if DefaultDownloadResponse.error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SponsorBannerDownloaded"), object: nil)
            }
        })
    }
}
