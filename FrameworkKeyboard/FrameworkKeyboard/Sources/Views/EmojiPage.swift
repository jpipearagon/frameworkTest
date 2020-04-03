//
//  EmojiPage.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/29/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol EmojiPageDelegate {
    func copyImageToClipboard(url :NSURL, emoji :Emoji, tabMenu :TabMenu, success: @escaping(_ finish: Bool) -> Void)
    func openSponsorBanner(url :NSURL)
    func hideShadow(value :Bool)
    func startScroll()
    func startSeconViewEvent()
}

class EmojiPage: UIView {
    var collectionView: UICollectionView!
    var tabMenu :TabMenu?
    var delegate : EmojiPageDelegate?
    var sectionInsets : UIEdgeInsets
    var parentViewController: UIViewController?
    private var lastContentOffset: CGFloat = 0
    var tabMenuName: String?
    var numberEmojisPerRow: Int!
    var timerKeyboardTabScroll = Timer()
    var counterKeyboardTabScroll = 0
    
    override init(frame: CGRect) {
        self.timerKeyboardTabScroll.invalidate()
        self.counterKeyboardTabScroll = 0
        let layout = UICollectionViewFlowLayout()
        let width = frame.size.width  - 40
        let sizefItems = floor(width / CGFloat(AppContext.instance.numberOfEmojisPerRow))
        sectionInsets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        super.init(frame: frame)
        layout.sectionInset = sectionInsets
        layout.itemSize = CGSize(width: sizefItems , height: sizefItems)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.backgroundColor = UIColor.clear
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UINib(nibName: "EmojiViewCell", bundle:Bundle(for: EmojiViewCell.self)), forCellWithReuseIdentifier: "EmojiViewCell")
        collectionView.register(UINib(nibName: "EmojiSponsorViewCell", bundle:Bundle(for: EmojiSponsorViewCell.self)), forCellWithReuseIdentifier: "SponsorViewCell")
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        self.addSubview(collectionView)
    }
    
    func closeApp() {
        self.counterKeyboardTabScroll = 0
        self.timerKeyboardTabScroll.invalidate()
    }
    
    func updateLayout() {
        collectionView.layoutIfNeeded()
        collectionView.layoutSubviews()
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        self.counterKeyboardTabScroll = 0
        self.timerKeyboardTabScroll.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCell"), object: nil)
        
        if self.tabMenu != nil {
            self.tabMenu!.tabMenuEmojis = TabMenuDao().deleteSponsor(listOfTabs: self.tabMenu!.tabMenuEmojis, atIndex: 0)
            self.tabMenu!.tabMenuEmojis = TabMenuDao().restructureEmojiList(listOfEmojis: self.tabMenu!.tabMenuEmojis)
            self.tabMenu!.tabMenuEmojis = TabMenuDao().loadEmojiList(listOfEmojis: self.tabMenu!.tabMenuEmojis)
            self.tabMenu = TabMenuDao().addSponsorToTab(tab: self.tabMenu!)
        }
        
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            self.delegate?.hideShadow(value: true)
        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            self.delegate?.hideShadow(value: false)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            self.delegate?.hideShadow(value: true)
        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            self.delegate?.hideShadow(value: false)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
    }
}

// MARK: - Collection view data source delegate & collection view delegate flow layout
extension EmojiPage: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.tabMenu != nil {
            return self.tabMenu!.tabMenuEmojis.count
        }
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = self.tabMenu!.tabMenuEmojis[section].count
        return number!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->   UICollectionViewCell{
        var cell: UICollectionViewCell!
        let list = self.tabMenu!.tabMenuEmojis[indexPath.section]
        let item = list.object(at: indexPath.row)
        if (item is Emoji) {
            let cellEmoji = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiViewCell", for: indexPath) as! EmojiViewCell
            cellEmoji.index = indexPath as NSIndexPath
            cellEmoji.emoji = item as? Emoji
            cellEmoji.loadEmoji()
            cellEmoji.image.stopAnimating()
            cell = cellEmoji
        } else if(item is Sponsor) {
            let cellSponsor = collectionView.dequeueReusableCell(withReuseIdentifier: "SponsorViewCell", for: indexPath) as! EmojiSponsorViewCell
            let sponsor =  item as! Sponsor
            cellSponsor.image.image = nil
            let headers : [String : String] = [
                "api_key": Config.instance.API_KEY]
            
            Alamofire.request(sponsor.sponsorBanner!, method: .post , headers: headers).responseImage(completionHandler: { (DataResponse) in
                guard let image = DataResponse.result.value else { return }
                cellSponsor.image.image = image
            })
        
            cell = cellSponsor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = self.tabMenu!.tabMenuEmojis[indexPath.section]
        let item = list.object(at: indexPath.row)
        
        if item is Emoji {
            let emoji = item as! Emoji
            self.isUserInteractionEnabled = false
            
            self.delegate?.copyImageToClipboard( url: NSURL(string:emoji.emojiUrlFullScreen)!, emoji:emoji, tabMenu:self.tabMenu!,
                                                 success: { (finish) in
                                                    self.isUserInteractionEnabled = true
            })
        }
        
        if item is Sponsor {
            let sponsor = item as! Sponsor
            self.delegate?.openSponsorBanner(url: sponsor.sponsorLink)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let list = self.tabMenu!.tabMenuEmojis[indexPath.section]
        let item = list.object(at: indexPath.row)
        
        if item is Emoji {
            let emoji = item as! Emoji
            self.isUserInteractionEnabled = false

            self.delegate?.copyImageToClipboard( url: NSURL(string:emoji.emojiUrlFullScreen)!, emoji:emoji, tabMenu:self.tabMenu!,
                                                success: { (finish) in
                                                    self.isUserInteractionEnabled = true
            })
        }
        
        if item is Sponsor {
            let sponsor = item as! Sponsor
            self.delegate?.openSponsorBanner(url: sponsor.sponsorLink)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.startScroll()
        
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.y > 0){
            //print("up")
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-\(tabMenuName!)")
        }else{
            //print("down")
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-\(tabMenuName!)-scroll")
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.startScroll()

        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.y > 0){
            //print("up")
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-\(tabMenuName!)")
        }else{
            //print("down")
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-\(tabMenuName!)-scroll")
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= 0.0 {
            self.timerKeyboardTabScroll.invalidate()
            self.counterKeyboardTabScroll = 0
            self.delegate?.startSeconViewEvent()
        } else {
            self.startTimerKeyboardScroll()
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView,
                                    willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= 0.0 {
            self.timerKeyboardTabScroll.invalidate()
            self.counterKeyboardTabScroll = 0
            self.delegate?.startSeconViewEvent()
        } else {
            self.startTimerKeyboardScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 {
            self.timerKeyboardTabScroll.invalidate()
            self.counterKeyboardTabScroll = 0
            self.delegate?.startSeconViewEvent()
        } else {
            self.startTimerKeyboardScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 {
            self.timerKeyboardTabScroll.invalidate()
            self.counterKeyboardTabScroll = 0
            self.delegate?.startSeconViewEvent()
        } else {
            self.startTimerKeyboardScroll()
        }
    }
    
    func startTimerKeyboardScroll() {
        self.timerKeyboardTabScroll.invalidate()
        self.counterKeyboardTabScroll = 0
        self.timerKeyboardTabScroll = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerKeyboardTabScrollEvent), userInfo: nil, repeats: true)
    }
    
    @objc func timerKeyboardTabScrollEvent() {
        self.counterKeyboardTabScroll = self.counterKeyboardTabScroll + 5
        GoogleAnalitycs.instance.sendEventTrack(category: "keyboard", eventName: "keyboard-\(tabMenuName!) - scroll - \(self.counterKeyboardTabScroll) second view", label: "")
    }
}

extension EmojiPage : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frame.size.width  - 40
        let widthOfItems = floor(width / CGFloat(AppContext.instance.numberOfEmojisPerRow))
        var size = CGSize(width: widthOfItems, height: widthOfItems)
        let list = self.tabMenu!.tabMenuEmojis[indexPath.section]
        let item = list.object(at: indexPath.row)
        
        if item is Sponsor {
            size = CGSize(width: frame.size.width, height: 50)
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let list = self.tabMenu!.tabMenuEmojis[section]
        let item = list.object(at: 0)
        
        if item is Emoji {
            return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        }
        
        //Sponsor
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
}
