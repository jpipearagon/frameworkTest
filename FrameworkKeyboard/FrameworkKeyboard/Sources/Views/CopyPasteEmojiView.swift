//
//  CopyPasteEmojiView.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 6/10/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

class CopyPasteEmojiView: UIView {
    var timer = Timer()
    @IBOutlet weak var viewWithSponsor: UIView!
    @IBOutlet weak var sponsorMessage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var sponsorBannerName : String = ""
    
    class func instanceFromNib() -> CopyPasteEmojiView {
        return UINib(nibName: "CopyPasteEmojiView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CopyPasteEmojiView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func registerPostNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SponsorBannerDownloaded"), object: nil)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(CopyPasteEmojiView.loadSponsorBanner as (CopyPasteEmojiView) -> () -> ()), name:NSNotification.Name(rawValue: "SponsorBannerDownloaded"), object: nil)
        
    }
    
    func open(view :UIView, success: @escaping (_ finish: Bool) -> Void) {
        self.registerPostNotifications()
        self.viewWithSponsor.backgroundColor =  AppContext.instance.getAppColor()
        self.sponsorMessage.image = nil
        
        var frame = view.bounds
        frame.origin.y = frame.size.height
        self.frame = frame
        self.alpha = 1.0
        let interfaceOrientation = getDevicePortaitLandscapeOrientation()
        var image = UIImage(named:NSLocalizedString("copyPaste", comment: ""))

        DispatchQueue.main.async {
            switch interfaceOrientation {
            case .Portrait:
                image = UIImage(named: NSLocalizedString("copyPaste", comment: ""))
            case .Landscape:
                image = UIImage(named: NSLocalizedString("copyPasteLandScape", comment: ""))
            }
            self.sponsorMessage.image = image
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        self.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.addSubview(self)
            self.alpha = 1.0
            var frame = view.bounds
            frame.origin.y = 0
            self.frame = frame
        }, completion: { (finished: Bool) in
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
            success(true)
        })
    }
    
    func openWithSponsor(view :UIView, urlBanner :String, success: @escaping (_ finish: Bool) -> Void) {
        self.registerPostNotifications()
        self.viewWithSponsor.backgroundColor =  AppContext.instance.getAppColor()
        self.sponsorMessage.image = nil
        self.sponsorBannerName = urlBanner
        var frame = view.bounds
        frame.origin.y = frame.size.height
        self.frame = frame
        self.alpha = 1.0
        self.spinner.startAnimating()

       let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(urlBanner)
        print(fileURL.absoluteString)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchQueue.global(qos: .userInitiated).async {
                let data = FileManager.default.contents(atPath: fileURL.path)
                if (data != nil) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        self.sponsorMessage.image = image
                        self.spinner.stopAnimating()
                        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
                    }
                }
                
            }
        } else {
            let interfaceOrientation = getDevicePortaitLandscapeOrientation()
            var image = UIImage(named: NSLocalizedString("copyPaste", comment: ""))
            
            DispatchQueue.main.async {
                switch interfaceOrientation {
                case .Portrait:
                    image = UIImage(named: NSLocalizedString("copyPaste", comment: ""))
                case .Landscape:
                    image = UIImage(named: NSLocalizedString("copyPasteLandScape", comment: ""))
                }
                self.sponsorMessage.image = image
            }
            
            self.sponsorMessage.image = image
            self.spinner.stopAnimating()
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
        }
 
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        self.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.addSubview(self)
            self.alpha = 1.0
            var frame = view.bounds
            frame.origin.y = 0
            self.frame = frame
        }, completion: { (finished: Bool) in
            success(true)
        })
    }
    
    @objc func loadSponsorBanner() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(self.sponsorBannerName)
        print(fileURL.absoluteString)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            DispatchQueue.global(qos: .userInitiated).async {
                let data = FileManager.default.contents(atPath: fileURL.path)
                if (data != nil) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        self.sponsorMessage.image = image
                        self.spinner.stopAnimating()
                        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
                    }
                }
                
            }
        } else {
            let interfaceOrientation = getDevicePortaitLandscapeOrientation()
            var image = UIImage(named: NSLocalizedString("copyPaste", comment: ""))
            
            DispatchQueue.main.async {
                switch interfaceOrientation {
                case .Portrait:
                    image = UIImage(named: NSLocalizedString("copyPaste", comment: ""))
                case .Landscape:
                    image = UIImage(named: NSLocalizedString("copyPasteLandScape", comment: ""))
                }
                self.sponsorMessage.image = image
            }
            self.sponsorMessage.image = image
            self.spinner.stopAnimating()
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
        }
    }
    
    @objc func close() {
        for recognizer in self.gestureRecognizers! {
            self.removeGestureRecognizer(recognizer)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            var frame = self.bounds
            frame.origin.y = frame.size.height
            self.frame = frame
            
        }, completion: { (finished: Bool) in
            self.timer.invalidate()
            self.sponsorMessage.image = nil
            self.removeFromSuperview()
        })
    }
    
    func getDevicePortaitLandscapeOrientation() -> DeviceOrientation {
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            return DeviceOrientation.Portrait
        } else {
            return DeviceOrientation.Landscape
        }
    }
}
