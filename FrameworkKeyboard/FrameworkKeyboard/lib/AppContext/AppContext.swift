 //
//  AppContext.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/10/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

public class AppContext: NSObject {
    private var objectDictionary : NSMutableDictionary
    var numberOfEmojisPerRow: Int = 5
    var selectedOthersActions : Bool = false
    static let keyValueTabButtonHeight : String = "kValueTabButtonHeight"
    static let keyValueTabButtonWidth : String = "kValueTabButtonWidtht"

    public static let instance = AppContext()
  
    private override init() {
        self.objectDictionary = [:]
        //self.dataIsCache = false
        super.init()
    }
    
    func isOpenAccessGranted() -> Bool {
        
        var hasFullAccess = false
        if #available(iOSApplicationExtension 10.0, *) {
            let originalString = UIPasteboard.general.string
            UIPasteboard.general.string = ""
            if UIPasteboard.general.hasStrings {
                if originalString != nil {
                    UIPasteboard.general.string = originalString
                } else {
                    UIPasteboard.general.string = ""
                }
                
                hasFullAccess = true
            }
            else
            {
                hasFullAccess = false
            }
        } else {
            let pbWrapped: UIPasteboard? =  UIPasteboard.general
            
            if pbWrapped != nil {
                hasFullAccess = true
            } else {
                hasFullAccess = false
            }
            
        }
        return hasFullAccess
    }
    
    func setNumberOfTabs(numberOfTabs: Int) {
        self.objectDictionary["NumbewOfTabs"] = numberOfTabs
    }
    
    func getNumberOfTabs() ->  Int{
        let value = self.objectDictionary.object(forKey: "NumbewOfTabs") != nil
        if value {
           return self.objectDictionary["NumbewOfTabs"] as! Int
        }
        
        return 0
    }
    
    public func setColorButtonTabsSelected(colorHex :String) {
        self.objectDictionary["ColorButtonTabsSelected"] = colorHex
    }
    
    func getColorButtonTabsSelected() ->  UIColor{
        if let value = self.objectDictionary.object(forKey: "ColorButtonTabsSelected") {
            return UIColor(hex: value as! String)
        }
        
        return UIColor(red: 66.0/255.0, green: 167.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    }
    
    public func setAppColor(colorHex :String) {
        self.objectDictionary["AppColor"] = colorHex
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeAppColor"), object: nil, userInfo: nil)
    }
    
    public func setTabButtonColor(colorHex :String) {
        self.objectDictionary["TabButtonColor"] = colorHex
    }
    
    func getTabButtonColor() ->  UIColor{
        
        if let value = self.objectDictionary.object(forKey: "TabButtonColor") {
            return UIColor(hex: value as! String)
        }
        
        return UIColor(red: 44.0/255.0, green: 48.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    }
    
    func getAppColor() ->  UIColor{
        
        if let value = self.objectDictionary.object(forKey: "AppColor") {
            return UIColor(hex: value as! String)
        }
        
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    func setColorBackgroundKeyboard(colorHex :String) {
      //  self.objectDictionary["ColorButtonTabsSelected"] = numberOfTabs
    }
    
    func getColorBackgroundKeyboard() ->  UIColor{
        let value = self.objectDictionary.object(forKey: "ColorBackgroundKeyboard") != nil
        
        if value {
            return self.objectDictionary["ColorBackgroundKeyboard"] as! UIColor
        }
        
        return UIColor.white
    }
    
    func setTextToShare(text :String) {
        self.objectDictionary["TextToShare"] = text
    }
    
    func getTextToShare() ->  String{
        let value = self.objectDictionary.object(forKey: "TextToShare") != nil
        
        if value {
            return self.objectDictionary["TextToShare"] as! String
        }
        
        return Config.instance.KEYBOARD_SHARE_TEXT
    }
    
    func processDataGeneralSettings(generalSettings: Dictionary<String, AnyObject>) {
        self.setTextToShare(text: generalSettings[NSLocalizedString("share_message_ios", comment: "")] as! String)
        self.setLabelGotoApp(text: generalSettings[NSLocalizedString("label_back_option", comment: "")] as? String)
        self.setLabelShare(text: generalSettings[NSLocalizedString("label_share_option", comment: "")] as? String)
    }
    
    func setLabelGotoApp(text:String?){
        self.objectDictionary["LabelGotoApp"] = text
    }
    
    func getLabelGotoApp() -> String{
        if self.objectDictionary["LabelGotoApp"] != nil{
            return self.objectDictionary["LabelGotoApp"] as! String
        }
        return Config.instance.TOP_BUTTON_RIGHT_TITLE
    }
    
    func setLabelShare(text:String?){
        self.objectDictionary["LabelShare"] = text
    }
    
    func getLabelShare() -> String{
        if self.objectDictionary["LabelShare"] != nil{
            return self.objectDictionary["LabelShare"] as! String
        }
        return Config.instance.TOP_BUTTON_LEFT_TITLE
    }
    
    func processDataCacheSettings(cacheSettings: Dictionary<String, AnyObject>) {
        let tokenUpdate = cacheSettings["token_update"] as! String
        let defaults = UserDefaults.standard
        defaults.set(tokenUpdate, forKey: "tokenUpdate")
        defaults.synchronize()
    }
    
    public func setMaxTabs(tabs :Int) {
          self.objectDictionary["numOfTabs"] = tabs
    }
    
    func getMaxTabs() -> Int {
        return self.objectDictionary["numOfTabs"] as! Int
    }
}
