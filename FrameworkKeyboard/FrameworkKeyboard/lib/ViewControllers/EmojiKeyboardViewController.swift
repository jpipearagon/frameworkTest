//
//  EmojiKeyboardViewController.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/28/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit
import Foundation

enum DeviceOrientation {
    case Portrait
    case Landscape
}

open class EmojiKeyboardViewController: UIInputViewController, KeyBoardAlphabeticDelegate,KeyBoardnumericDelegate, UIPopoverPresentationControllerDelegate, MenuBottomDelegate, EmojisContainerDelegate, EmojiPageDelegate, OtherActionsDelegate, AccessGrantedDelegate, UIWebViewDelegate {
    @IBOutlet weak var nextKeyboard: UIButton!
    @IBOutlet weak var backSpace: UIButton!
    @IBOutlet weak var otherAction: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var menuViewBottomcontainer: UIView!
    @IBOutlet weak var emojikeyboarContainer: UIView!
    @IBOutlet weak var shadow: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var emojisContainer: EmojisContainer!
    @IBOutlet weak var menuBottomContainer: MenuBottomContainer!
    @IBOutlet weak var viewContainerNextKeyboardButton: UIView!
    @IBOutlet weak var viewContainerOtherButton: UIView!
    @IBOutlet weak var logTest: UILabel!
    @IBOutlet weak var labelGotoapp: UILabel!
    @IBOutlet weak var labelShare: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var imageshare: UIImageView!

    var keyboardAlphabeticController: KeyboardAlphabeticController!
    var keyboardNumericController: KeyboardNumericViewController!
    var pasteEmojiView: CopyPasteEmojiView!
    var accessGrantedView: AccessGrantedView!
    var otherActionViewController: OtherActionsViewController!
    var heightConstraint: NSLayoutConstraint!
    var backspaceCount: Int!
    var emojiPage: EmojiPage!
    var listOfTabs: [TabMenu]!
    var tagFromOtherActions: Int!
    var timerKeyboardLaunch = Timer()
    var timerKeyboardTab = Timer()
    var counterKeyboardLaunch = 0
    var counterKeyboardTab = 0
    var countLoad = 0
    
    private var deleteButtonTimer: Timer?
    private var keyboardHeight: CGFloat {
        get {
            let interfaceOrientation = getDevicePortaitLandscapeOrientation()
            
            switch interfaceOrientation {
            case .Portrait:
                return 266.0
            case .Landscape:
                return 266.0
            }
        }
    }
    
    //MARK: View Methods
    override open func updateViewConstraints() {
        super.updateViewConstraints()
        if (view.frame.size.width == 0 || view.frame.size.height == 0) {
            return
        }
    }
    
    func setUpHeightConstraint() {
        if heightConstraint != nil {
            self.view.removeConstraint(heightConstraint!)
            heightConstraint!.constant = self.keyboardHeight
            heightConstraint.priority = UILayoutPriority(rawValue: 999)
            self.view.addConstraint(heightConstraint!)
        } else {
            heightConstraint = NSLayoutConstraint(item: self.view ?? UIView(),
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: CGFloat(keyboardHeight))
            heightConstraint.priority = UILayoutPriority(rawValue: 999)
            self.view.addConstraint(heightConstraint!)
        }
    }
    
    init() {
        super.init(nibName: "EmojiKeyboardViewController", bundle: Bundle(for: EmojiKeyboardViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //let nib = UINib(nibName: "EmojiKeyboardViewController", bundle: nil)
        //self.view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        emojisContainer.delegateContainer = self
        self.nextKeyboard.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
        self.backSpace.addTarget(self, action: #selector(self.backSpaceAction), for: .touchUpInside)
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EmojiKeyboardViewController.handleLongPressForDeleteButtonWithGestureRecognizer(gestureRecognizer:)))
        self.backSpace.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
        self.menuBottomContainer.delegateTabs = self
        self.emojikeyboarContainer.backgroundColor = AppContext.instance.getColorBackgroundKeyboard()
        self.view.backgroundColor = AppContext.instance.getColorBackgroundKeyboard()
      
        self.view.addConstraints([NSLayoutConstraint(item: nextKeyboard ?? UIButton(), attribute: .left, relatedBy:.equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nextKeyboard ?? UIButton(), attribute: .bottom, relatedBy:.equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        heightConstraint = NSLayoutConstraint(item: self.view ?? UIView(), attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: self.keyboardHeight)
        self.changeAppColor()
        registerPostNotifications()
    }
    
    func registerPostNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "changeAppColor"), object: nil)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeAppColor), name:NSNotification.Name(rawValue: "changeAppColor"), object: nil)
    }
    
    @objc func changeAppColor() {
        self.menuViewBottomcontainer.backgroundColor = AppContext.instance.getTabButtonColor()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpHeightConstraint()
        //self.updateButtonFrame()
        self.timerKeyboardTab.invalidate()
        self.timerKeyboardLaunch.invalidate()
        
        if !AppContext.instance.isOpenAccessGranted() {
            self.initViewWithoutAccess(tab: nil)
        } else {
            EmojiKeyBoardService().loadTabs(success: { listOfTabs in
                self.countLoad = self.countLoad + 1
                self.initView(listOfTabs: listOfTabs)
            }) { (error) in
                self.initView(listOfTabs: [])
            }
            
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-launch")
            self.timerKeyboardLaunch.invalidate()
            self.timerKeyboardLaunch = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerKeyboardLaunchEvent), userInfo: nil, repeats: true)
        }
    }
    
    func initGoogleAnalytics(){
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-launch")
        self.timerKeyboardLaunch.invalidate()
        self.timerKeyboardLaunch = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerKeyboardLaunchEvent), userInfo: nil, repeats: true)
    }
    
    func logTestPrint(notification:NSNotification) {
        if let value = notification.userInfo!["eventName"] as? String {
            if self.logTest != nil{
                self.logTest.text = value
            }
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listOfTabs = nil
        self.emojisContainer = nil
        self.timerKeyboardLaunch.invalidate()
        self.timerKeyboardTab.invalidate()
        counterKeyboardLaunch = 0
        counterKeyboardTab = 0
        exit(0)
    }
    
    deinit {
        print("Deinit process done.")
    }
    
    //MARK: Private Methods
    func dismissOverlayNotification() {
        if (self.pasteEmojiView != nil) {
            UIView.animate(withDuration: 0.2, animations: {
                self.pasteEmojiView.alpha = 0.0
            }, completion: { (finished: Bool) in
                self.pasteEmojiView.removeFromSuperview()
                self.pasteEmojiView = nil
            })
        }
    }
    
    func updateButtonFrame() {
        let maxTabs = AppContext.instance.getMaxTabs()
        var buttons = maxTabs + 3
        var multiplier = maxTabs
        
        if (self.listOfTabs.count < maxTabs) {
            buttons = self.listOfTabs.count + 3
            multiplier = self.listOfTabs.count
        }
        
        let width = self.view.frame.size.width/CGFloat(buttons)
        var frame = self.viewContainerNextKeyboardButton.frame
        frame.size.width = width
        frame.origin.x = 0
        frame.origin.y = 0
        self.nextKeyboard.frame = frame
        self.viewContainerNextKeyboardButton.frame = frame
        
        frame = self.menuBottomContainer.frame
        frame.origin.y = 0
        frame.origin.x = self.viewContainerNextKeyboardButton.frame.size.width
        frame.size.width = width * CGFloat(multiplier)
        self.menuBottomContainer.frame = frame
        
        frame = self.viewContainerOtherButton.frame
        frame.origin.y = 0
        frame.origin.x = self.viewContainerNextKeyboardButton.frame.size.width + self.menuBottomContainer.frame.size.width
        frame.size.width = width
        self.viewContainerOtherButton.frame = frame
        frame.origin.x = 0
        frame.origin.y = 0
        self.otherAction.frame = frame
        
        frame = self.backSpace.frame
        frame.origin.y = 0
        frame.origin.x = self.viewContainerNextKeyboardButton.frame.size.width + self.menuBottomContainer.frame.size.width
            + self.viewContainerOtherButton.frame.size.width
        frame.size.width = width
        self.backSpace.frame = frame
    }
    
    override open func viewWillLayoutSubviews() {
        let orientation = getDevicePortaitLandscapeOrientation()
        
        switch orientation {
        case .Portrait:
            AppContext.instance.numberOfEmojisPerRow = 5
        case .Landscape:
            AppContext.instance.numberOfEmojisPerRow = 7
        }
    }
    
    func getDevicePortaitLandscapeOrientation() -> DeviceOrientation {
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            return DeviceOrientation.Portrait
        } else {
            return DeviceOrientation.Landscape
        }
    }
    
    func initViewWithoutAccess(tab: TabMenu?) {
        if self.accessGrantedView  == nil {
            self.accessGrantedView = AccessGrantedView.instanceFromNib()
        }

        self.accessGrantedView.removeFromSuperview()
        
        self.accessGrantedView.delegate = self
        self.accessGrantedView.frame = self.emojikeyboarContainer.bounds
        self.accessGrantedView.alpha = 1.0
        self.accessGrantedView.setImageNoAccess(tab: tab)
        self.emojikeyboarContainer.addSubview(self.accessGrantedView)
    }
    
    func initView(listOfTabs: [TabMenu]) {
        
        self.labelGotoapp.text = AppContext.instance.getLabelGotoApp()
        self.labelShare.text = AppContext.instance.getLabelShare()
        
        if(NSLocalizedString("language", comment: "") == "en"){
            imageshare.frame = CGRect(x: imageshare.frame.origin.x+38, y: imageshare.frame.origin.y, width: imageshare.frame.width, height: imageshare.frame.height)
        }

        counterKeyboardLaunch = 0
        counterKeyboardTab = 0
        
        self.listOfTabs = listOfTabs
        if self.listOfTabs.count <= 1 {
            self.pageControl.isHidden = true
        } else {
            self.pageControl.isHidden = false
        }
        
        self.pageControl.numberOfPages = self.listOfTabs.count
        
        let maxTabs = AppContext.instance.getMaxTabs()

        if self.listOfTabs.count > maxTabs {
            self.otherAction.setImage(UIImage(named:"icon.moreaction"), for: .normal)
        } else {
            self.otherAction.setImage(UIImage(named:"icon.alphanumeric"), for: .normal)
        }
        
        AppContext.instance.setNumberOfTabs(numberOfTabs: self.listOfTabs.count)
        
        if self.countLoad == 1{
            self.emojisContainer.initView()
        }
        self.emojisContainer.updateLayout()
        
        var views = [EmojiPage]()
        var index = self.menuBottomContainer.currentTab
        if self.otherActionViewController != nil {
            if self.otherActionViewController.selectedRow != -1 && self.otherActionViewController.seletedTag < self.listOfTabs.count{
                index = self.otherActionViewController.seletedTag
            }
        }
        let tabMenu = self.listOfTabs[index]
        
        if self.countLoad == 1{
            self.pageControl.currentPage = index
            self.emojiPage = EmojiPage(frame: self.applyFrame(indexView: self.menuBottomContainer.currentTab))
            self.emojiPage.delegate = self
            self.emojiPage.parentViewController = self
            self.emojiPage.tabMenu = tabMenu
            self.emojiPage.tabMenuName = tabMenu.tabMenuName
            views.append(self.emojiPage)
            
            self.emojisContainer.insertSubviews(views: views as NSArray)
            views.removeAll()
        } else {
            emojiPage.tabMenu = tabMenu
            emojiPage.reloadData()
            emojiPage.tabMenuName = tabMenu.tabMenuName
        }
        self.updateButtonFrame()
        self.menuBottomContainer.listOfTabs = self.listOfTabs! as NSArray
        self.menuBottomContainer.loadMenu()
        
    }
    
    func applyFrame(indexView: NSInteger) -> CGRect {
        let pageCount = self.listOfTabs.count
        let outOfBounds = indexView >= pageCount || indexView < 0
        var pageFrame = CGRect.zero
        
        if (!outOfBounds) {
            pageFrame = emojisContainer.frame
            pageFrame.origin.y = 0
            pageFrame.origin.x = self.emojisContainer.frame.size.width * CGFloat(indexView)
            pageFrame.size.width = self.emojisContainer.frame.size.width
            pageFrame.size.height = self.emojisContainer.frame.size.height
        } else {
            pageFrame = self.emojisContainer.frame
            pageFrame.origin.y = self.emojisContainer.frame.size.height
        }
        
        return pageFrame
    }
    
    func openAlphabetickey() {
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-alphanumeric")
        self.clearAllButtonBackgrounds()
        self.menuBottomContainer.clearAllButtonBackgrounds()
        self.menuBottomContainer.selectMoreActions()
        self.otherAction.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
        self.otherAction.alpha = 1.0
        self.openAlphabeticKeyboardAction()
        self.line.isHidden = true;
    }
    
    func openAlphabeticKeyboardAction() {
        if self.keyboardAlphabeticController == nil {
            self.keyboardAlphabeticController = KeyboardAlphabeticController()
        }
    
        self.keyboardAlphabeticController.view.removeFromSuperview()
        self.keyboardAlphabeticController.delegate = self
        self.keyboardAlphabeticController.view.frame = self.emojikeyboarContainer.frame
        self.emojikeyboarContainer.addSubview(self.keyboardAlphabeticController.view)
    }
    
    func openNumericKeyboardAction() {
        if self.keyboardAlphabeticController != nil {
            self.keyboardAlphabeticController.view.removeFromSuperview()
        }
        
        if self.keyboardNumericController == nil {
            self.keyboardNumericController = KeyboardNumericViewController()
        }
        
        self.keyboardNumericController.delegate = self
        self.keyboardNumericController.view.frame = self.emojikeyboarContainer.frame
        self.emojikeyboarContainer.addSubview(self.keyboardNumericController.view)
    }
    
    func removeAlphanumericKeyboard() {
        if self.keyboardAlphabeticController != nil {
            self.keyboardAlphabeticController.view.removeFromSuperview()
        }
        
        if self.keyboardNumericController != nil {
            self.keyboardNumericController.view.removeFromSuperview()
        }
    }
    
    func clearAllButtonBackgrounds() {
        self.backSpace.backgroundColor = UIColor.clear
        self.otherAction.backgroundColor = UIColor.clear
        self.otherAction.alpha = 1
        self.line.isHidden = false;
    }
    
    @objc func handleLongPressForDeleteButtonWithGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if deleteButtonTimer == nil {
                deleteButtonTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(EmojiKeyboardViewController.handleDeleteButtonTimerTick(timer:)), userInfo: nil, repeats: true)
                deleteButtonTimer!.tolerance = 0.01
                RunLoop.main.add(deleteButtonTimer!, forMode: RunLoop.Mode.default)
            }
        default:
            deleteButtonTimer?.invalidate()
            deleteButtonTimer = nil
        }
    }
    
    @objc func handleDeleteButtonTimerTick(timer: Timer) {
        textDocumentProxy.deleteBackward()
    }
    
    //MARK: @IBAction
    @IBAction func openAlphabetic(sender: UIButton) {
        AppContext.instance.selectedOthersActions = true
        let maxTabs = AppContext.instance.getMaxTabs()
        
        if  self.listOfTabs == nil || self.listOfTabs.count <= maxTabs {
            self.otherAction.setImage(UIImage(named:"icon.alphanumeric"), for: .normal)
            self.openAlphabetickey()
        } else {
            self.otherAction.setImage(UIImage(named:"icon.moreaction"), for: .normal)
            self.clearAllButtonBackgrounds()
            self.menuBottomContainer.clearAllButtonBackgrounds()
            self.menuBottomContainer.selectMoreActions()
            self.otherAction.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
            self.otherAction.alpha = 1.0
            if self.otherActionViewController == nil {
                self.otherActionViewController = OtherActionsViewController()
            } else {
                if self.otherActionViewController.seletedTag <  self.listOfTabs.count{
                    self.otherActionViewController.seletedTag = self.emojisContainer.currentPage
                }
            }
            
            self.otherActionViewController.modalPresentationStyle = .popover
            let width =  self.view.frame.size.width * 0.653333333333
            let height =  self.view.frame.size.height * 0.586466165414
            self.otherActionViewController.preferredContentSize = CGSize(width: width, height: height)
            self.otherActionViewController.delegate = self
            
            if self.listOfTabs.count > maxTabs {
                var listOfTabsToMoreMenu = [TabMenu]()
                
                for i in maxTabs...self.listOfTabs.count-1 {
                    let tab = self.listOfTabs[i]
                    listOfTabsToMoreMenu.append(tab)
                }
                self.otherActionViewController.listOfTabs = listOfTabsToMoreMenu
            }
            
            let popoverMenuViewController = otherActionViewController.popoverPresentationController
            popoverMenuViewController?.permittedArrowDirections = .down
            popoverMenuViewController?.backgroundColor = AppContext.instance.getTabButtonColor()
            popoverMenuViewController?.delegate = self
            popoverMenuViewController?.sourceView = self.otherAction
            popoverMenuViewController?.sourceRect = CGRect(
                x: 0,//self.otherAction.frame.size.width / 2,
                y: 0,
                width: 50,
                height: 100)
            
            present(self.otherActionViewController, animated: true, completion: {
                self.otherActionViewController.tableView.reloadData()
                GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-more")
            })
        }
        self.line.isHidden = true;
    }
    
    @IBAction func onShareKeyboard(sender: AnyObject) {
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-share-keyboard")
        self.textDocumentProxy.insertText(AppContext.instance.getTextToShare())
    }
    
    @IBAction func onAddemojis(sender: AnyObject) {
        var eventName = labelGotoapp.text?.lowercased()
        eventName = eventName?.replacingOccurrences(of: " ", with: "-")
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-"+eventName!)
        UIApplication.🚀sharedApplication().🚀openURL(url: NSURL(string: Config.instance.URL_HOSTAPP)!)
    }
    
    @IBAction func backSpaceAction() {
        textDocumentProxy.deleteBackward()
    }
    
    //MARK: KeyBoardAlphabeticDelegate
    func insertText(text :String) {
        self.textDocumentProxy.insertText(text)
    }
    
    func openNumericKeyboard() {
        self.openNumericKeyboardAction()
    }
    
    //MARK: KeyBoardnumericDelegate
    func openAlphabeticKeyboard() {
        self.openAlphabeticKeyboardAction()
    }
    
    func insertTextNumeric(text :String) {
        self.textDocumentProxy.insertText(text)
    }
    
    //MARK: OtherActionsDelegate {
    func selectOption(row :Int, tag :Int) {
        if tag < self.listOfTabs.count {
            self.startTimerKeyboardTab()
            self.menuBottomContainer.clearAllButtonBackgrounds()
            self.menuBottomContainer.selectMoreActions()
            removeAlphanumericKeyboard()
            let tabMenu = self.listOfTabs[tag]
            self.menuBottomContainer.tabMenuName = tabMenu.tabMenuName
            self.emojiPage.tabMenu = tabMenu
            self.emojiPage.frame = self.applyFrame(indexView: tag)
            self.emojiPage.reloadData()
            self.emojiPage.tabMenuName = tabMenu.tabMenuName
            self.emojisContainer.scrollToPage(page: tag)
            self.pageControl.currentPage = tag
            self.timerKeyboardLaunch.invalidate()
            self.counterKeyboardLaunch = 0
            GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-"+tabMenu.tabMenuName)
        } else {
            self.timerKeyboardTab.invalidate()
            self.openAlphabetickey()
        }
    }
    
    //MARK: MenuBottomDelegate
    func selectTab(tag: Int) {
        self.startTimerKeyboardTab()
        AppContext.instance.selectedOthersActions = false
        clearAllButtonBackgrounds()
        removeAlphanumericKeyboard()
        
        if self.otherActionViewController != nil {
            self.otherActionViewController.selectedRow = -1
            self.otherActionViewController.seletedTag = -1
        }
        
        let tabMenu = self.listOfTabs[tag]
        self.emojiPage.frame = self.applyFrame(indexView: tag)
        emojiPage.tabMenu = nil
        emojiPage.reloadData()
        emojiPage.tabMenu = tabMenu
        emojiPage.reloadData()
        emojiPage.tabMenuName = tabMenu.tabMenuName
        self.emojisContainer.scrollToPage(page: tag)
        self.pageControl.currentPage = tag
        self.timerKeyboardLaunch.invalidate()
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-"+tabMenu.tabMenuName)
    }
    
    //MARK: EmojisContainerDelegate
    func changePage(page :Int) {
        print("Scrolling")
    }
    
    func finishedChangePage(page :Int) {
        self.clearAllButtonBackgrounds()
        self.timerKeyboardLaunch.invalidate()
        self.counterKeyboardLaunch = 0
        self.startTimerKeyboardTab()
        let maxTabs = AppContext.instance.getMaxTabs()

        if page < maxTabs {
            if self.otherActionViewController != nil {
                self.otherActionViewController.selectedRow = -1
                self.otherActionViewController.seletedTag = -1
            }
            
            AppContext.instance.selectedOthersActions = false
            menuBottomContainer.selectTabFromPage(page: page)
            self.line.isHidden = false;
        } else {
            AppContext.instance.selectedOthersActions = true
            self.menuBottomContainer.clearAllButtonBackgrounds()
            self.otherAction.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
            self.otherAction.alpha = 1.0
            self.line.isHidden = true;
            menuBottomContainer.selectMoreActions()
        }
        
        self.menuBottomContainer.currentTab = page
        self.emojiPage.frame = self.applyFrame(indexView: page)
        let tabMenu = self.listOfTabs[page]
        self.emojiPage.tabMenu = tabMenu
        emojiPage.reloadData()
        self.emojiPage.tabMenuName = tabMenu.tabMenuName
        self.pageControl.currentPage = page
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-swipe-"+tabMenu.tabMenuName)
    }
    
    //MARK: EmojiPageDelegate
    func startScroll() {
        self.timerKeyboardLaunch.invalidate()
        self.timerKeyboardTab.invalidate()
    }
    
    func startSeconViewEvent() {
        self.startTimerKeyboardTab()
    }
    
    func copyImageToClipboard(url: NSURL, emoji: Emoji, tabMenu: TabMenu, success: @escaping (Bool) -> Void) {
        // if emoji.emojiStatus {
        GoogleAnalitycs.instance.sendViewTrack(screenName: "keyboard-\(self.menuBottomContainer.tabMenuName)-\(emoji.emojiName)-copy")
        let headers : [String : String] = [
            "api_key": Config.instance.API_KEY]
        
        
        switch(emoji.imagetype) {
        case .GIF :
            EmojiDao().loadEmojiFullScreen(url: url as URL, success: { response in
                UIPasteboard.general.setData(response, forPasteboardType: "com.compuserve.gif")
                self.openViewPaste(tabMenu: tabMenu, success: { (finish) in
                    success(true)
                })
                }, failure: { (error) in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let fileManager = FileManager.default
                        let path = emoji.emojiLocalPath.path
                        if fileManager.fileExists(atPath: path!) {
                            if let data = FileManager.default.contents(atPath: path!){
                                DispatchQueue.main.async {
                                    UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif")
                                    self.openViewPaste(tabMenu: tabMenu, success: { (finish) in
                                        success(true)
                                    })
                                }
                            }
                        } else {
                            success(true)
                        }
                    }
            })
            break
        case .IMAGE:
            Alamofire.request(url.absoluteString!, method: .post, headers: headers)
                .responseImage { response in
                    debugPrint(response)
                    if let image = response.result.value {
                        UIPasteboard.general.image = image
                        self.openViewPaste(tabMenu: tabMenu, success: { (finish) in
                            success(true)
                        })
                    } else if (response.result.error != nil)  {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let fileManager = FileManager.default
                            let path = emoji.emojiLocalPath.path
                            if fileManager.fileExists(atPath: path!) {
                                let data = FileManager.default.contents(atPath: path!)
                                DispatchQueue.main.async {
                                    let image = UIImage(data: data!)
                                    UIPasteboard.general.image = image
                                    self.openViewPaste(tabMenu: tabMenu, success: { (finish) in
                                        success(true)
                                    })
                                }
                            } else {
                                success(true)
                            }
                        }
                    } else  {
                        success(true)
                    }
            }
            break
        default :
            break
        }
        
        /*} else {

         }*/
    }
    
    func openSponsorBanner(url :NSURL) {
        UIApplication.🚀sharedApplication().🚀openURL(url: url)
    }
    
    func hideShadow(value :Bool) {
        self.shadow.isHidden = value
    }
    
    func openViewPaste(tabMenu :TabMenu, success: @escaping (_ finish: Bool) -> Void) {
        if (self.pasteEmojiView == nil) {
            self.pasteEmojiView = CopyPasteEmojiView.instanceFromNib()
        }

        if tabMenu.sponsor.sponsorMessagePortrait.absoluteString!.isEmpty &&
            tabMenu.sponsor.sponsorMessageLandscape.absoluteString!.isEmpty{
            self.pasteEmojiView.open(view: self.view, success: { (finish) in
                success(true)
            })
        } else {
            var url = tabMenu.tabMenuName + "SponsorPortrait.image"//tabMenu.sponsor.sponsorMessagePortrait.absoluteString
            let interfaceOrientation = getDevicePortaitLandscapeOrientation()
            
            if interfaceOrientation == .Landscape {
                url = tabMenu.tabMenuName + "Sponsorlandscape.image"//tabMenu.sponsor.sponsorMessageLandscape.absoluteString
            }
            
            self.pasteEmojiView.openWithSponsor(view: self.view, urlBanner:url, success: { (finish) in
                success(true)
            })
        }
    }
    
    //MARK: AccessGrantedDelegate
    func openSettings(url :NSURL) {
        UIApplication.🚀sharedApplication().🚀openURL(url: url)
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /*func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }*/
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if self.otherActionViewController.selectedRow == -1 {
            AppContext.instance.selectedOthersActions = false
            if emojisContainer.currentPage < 5 {
                clearAllButtonBackgrounds()
                menuBottomContainer.selectCurrentTab()
            }
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        setUpHeightConstraint()
        self.updateButtonFrame()
        
        if self.menuBottomContainer != nil {
            self.menuBottomContainer.updateLayout()
        }
        
        self.emojisContainer.updateLayout()
        
        if self.emojiPage != nil {
            self.emojiPage.frame = self.applyFrame(indexView: self.emojisContainer.currentPage)
            self.emojiPage.updateLayout()
        }
    }
    
    //MARK: Timers
    @objc func timerKeyboardLaunchEvent() {
        counterKeyboardLaunch = counterKeyboardLaunch + 5
        GoogleAnalitycs.instance.sendEventTrack(category: "keyboard", eventName: "keyboard-launch - \(counterKeyboardLaunch) second view", label: "")
    }
    
    func startTimerKeyboardTab() {
        self.counterKeyboardTab = 0
        self.timerKeyboardTab.invalidate()
        self.timerKeyboardTab = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerKeyboardTabEvent), userInfo: nil, repeats: true)
    }
    
    @objc func timerKeyboardTabEvent() {
        self.counterKeyboardTab = self.counterKeyboardTab + 5
        GoogleAnalitycs.instance.sendEventTrack(category: "keyboard", eventName: "keyboard-\(self.emojiPage.tabMenuName!)- \(counterKeyboardTab) second view", label: "")
    }
}

extension UIApplication {
    public static func 🚀sharedApplication() -> UIApplication {
        guard UIApplication.responds(to: "sharedApplication") else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication` does not respond to selector `sharedApplication`.")
        }
        
        guard let unmanagedSharedApplication = UIApplication.perform("sharedApplication") else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned `nil`.")
        }
        
        guard let sharedApplication = unmanagedSharedApplication.takeUnretainedValue() as? UIApplication else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned not `UIApplication` instance.")
        }
        
        return sharedApplication
    }
    
    public func 🚀openURL(url: NSURL) -> Bool {
        return self.performSelector(inBackground: "openURL:", with: url) != nil
    }
}
