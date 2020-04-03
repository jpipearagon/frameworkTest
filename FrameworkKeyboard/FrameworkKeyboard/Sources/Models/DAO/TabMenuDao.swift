     //
//  TabMenuDao.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/12/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

enum DataError: Error {
    case BadData
    case SameData
    case ServiceError
}

class TabMenuDao: NSObject {
    var update :Bool = false
    
    func loadEmojiTabsJson(success: @escaping (_ listOfTabs: [TabMenu]) -> Void, failure:(_ error: NSError) -> Void)  {
        if Reachability.isConnectedToNetwork() == false {
            let listOfTabs = self.loadCache()
            if listOfTabs.count > 0 {
                success(listOfTabs)
            }
        } else {
            let listOfTabs = self.loadCache()
            if listOfTabs.count > 0 {
                success(listOfTabs)
            }
            let headers : [String : String] = ["api_key": Config.instance.API_KEY]
            let userDefaults = UserDefaults(suiteName: "group.telemundo.sharedata")
            
            if let userId = userDefaults?.object(forKey: "userId") as? String {
                let urlRegister = String(format: "%@%@", Config.instance.URL_REGISTER, userId)

                //register
                Alamofire.request(URL(string : urlRegister)!, method: .get,  headers:headers).validate().responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                                let jsonResult = JSON as? Dictionary<String, AnyObject>
                                let clienId = jsonResult!["client"]?["client_id"] as? String
                                let clienSecret = jsonResult!["client"]?["client_secret"] as? String
                                if clienId != nil && clienSecret != nil {
                                    userDefaults?.setValue(clienId, forKey: "client_id")
                                    userDefaults?.setValue(clienSecret, forKey: "client_secret")
                                    userDefaults?.synchronize()
                                    
                                    let urlLogin = String(format: "%@%@", Config.instance.URL_LOGIN, userId)
                                    //LOGIN
                                    Alamofire.request(URL(string : urlLogin)!, method: .get,  headers:headers).validate().responseJSON { response in
                                        switch response.result {
                                        case .success(let JSON):
                                            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                                                if let clientCode = jsonResult["client"]?["code"] as? String {
                                                    let clienId = userDefaults?.object(forKey: "client_id") as? String
                                                    let clienSecret = userDefaults?.object(forKey: "client_secret") as? String
                                                    let urlToken = String(format: "%@&code=%@&client_id=%@&client_secret=%@", Config.instance.URL_TOKEN, clientCode, clienId!, clienSecret!)
                                                    //GET TOKEN
                                                    Alamofire.request(URL(string : urlToken)!, method: .get,  headers:headers).validate().responseJSON { response in
                                                        switch response.result {
                                                        case .success(let JSON):
                                                            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                                                                if let accessToken = jsonResult["access_token"] as? String {
                                                                    let urlGetEmojis = String(format: "%@?user_id=%@&access_token=%@", Config.instance.URL_SERVICE, userId, accessToken)
                                                                    //GET EMOJIS
                                                                    self.getEmojis(success: success, urlGetEmojis: urlGetEmojis)
                                                                } else {
                                                                    self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                                                }
                                                            } else {
                                                                self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                                            }
                                                        case .failure( _):
                                                            self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                                        }
                                                    }
                                                } else {
                                                    self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                                }
                                            } else {
                                                self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                            }
                                            
                                        case .failure(let error):
                                            self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                        }
                                    }
                                } else {
                                    self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                                }
                    case .failure(let error):
                        self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
                    }
                }
            } else {
                self.getEmojis(success: success, urlGetEmojis: Config.instance.URL_SERVICE_DUMMY)
            }
        }
    }
    
    func getEmojis(success: @escaping (_ listOfTabs: [TabMenu]) -> Void, urlGetEmojis: String) {
        let headers : [String : String] = ["api_key": Config.instance.API_KEY]

        Alamofire.request(URL(string : urlGetEmojis)!, method: .get,  headers:headers).validate().responseJSON { response in
            switch response.result {
            case .success(let JSON):
                if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                    do {
                        let listOfTabs =   try self.processData(responseObject: jsonResult)
                        
                        if listOfTabs.count > 0 {
                            if self.update {
                                success(listOfTabs)
                            }
                            self.clearData()
                            self.createCacheFileJson(json: jsonResult)
                        }
                        
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                } else {
                    let listOfTabs = self.loadCache()
                    if listOfTabs.count > 0 {
                        success(listOfTabs)
                    }
                }
                
            case .failure( _):
                let listOfTabs = self.loadCache()
                if listOfTabs.count > 0 {
                    success(listOfTabs)
                }
            }
        }
    }
    
    func loadCache() -> [TabMenu] {
        do {
            if let jsonResult: Dictionary = self.loadCacheFileJson() {
                return try self.processData(responseObject: jsonResult)
            } 
       } catch {
            return []
        }
        
        return []
    }
    
    func clearData() {
        do {
            let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let  filePath = documentsDirectory.appendingPathComponent("assets.json")
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: filePath.path)
        } catch _ as NSError {
           // print(error.localizedDescription)
        }
    }
    
    func createCacheFileJson(json: Dictionary<String, AnyObject>) {
        let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let  writePath = documentsDirectory.appendingPathComponent("assets.json")
        let data: NSData = NSKeyedArchiver.archivedData(withRootObject: json) as NSData
        data.write(toFile: writePath.path, atomically: true)
    }
    
    func loadCacheFileJson() -> Dictionary<String, AnyObject>! {
        let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let  filePathURL = documentsDirectory.appendingPathComponent("assets.json")
        if FileManager.default.fileExists(atPath: filePathURL.path) {
            let data: NSData = NSData(contentsOfFile: filePathURL.path)!
            
            if let jsonObject: Dictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Dictionary<String, AnyObject> {
                return jsonObject
            }
        }
        
        return nil
    }
    
    func processData(responseObject :Dictionary<String, AnyObject>)  throws -> [TabMenu] {
        var listOfTabs = [TabMenu]()
        
        if let results = responseObject["result"] as? Dictionary<String, AnyObject> {
            //Cache Ssettings
            if let cacheSettings = results["cache_settings"] as? Dictionary<String, AnyObject> {
                let newTokenUpdate = cacheSettings["token_update"] as! String
                let defaults = UserDefaults.standard
                
                if let currentTokenUpdate = defaults.string(forKey: "tokenUpdate") {
                    if newTokenUpdate == currentTokenUpdate{
                        self.update = false
                    } else {
                        self.update = true
                    }
                } else {
                    self.update = true
                }
                
                AppContext.instance.processDataCacheSettings(cacheSettings: cacheSettings)
            }
            
            //General Settings
            if let generalSettings = results["general_settings"] as? Dictionary<String, AnyObject> {
                AppContext.instance.processDataGeneralSettings(generalSettings: generalSettings)
            }
            
            //Tabs
            if let tabs = results["tabs"] as? Array<Dictionary<String, AnyObject>>  {
                for tab in  tabs {
                    let tabMenu = TabMenu()
                    
                    //Data
                    let sponsor = Sponsor()
                    
                    if let value = tab["tab_name"] as? String {
                        tabMenu.tabMenuName = value
                    } else {
                        throw DataError.BadData
                    }
                    
                    if let value = tab["tab_icon"] as? String {
                        tabMenu.tabMenuImageOffUrl = value
                    } else {
                        throw DataError.BadData
                    }
                    
                    if let value = tab["tab_active_icon"] as? String {
                        if value != "" {
                            tabMenu.tabMenuImageOnUrl = value
                        } else {
                            tabMenu.tabMenuImageOnUrl = tabMenu.tabMenuImageOffUrl
                        }
                    } else {
                        tabMenu.tabMenuImageOnUrl = tabMenu.tabMenuImageOffUrl
                    }
                    
                    if let value = tab[NSLocalizedString("keyboard_image_noaccess_ios", comment: "")] as? String {
                        if value != "" {
                            tabMenu.tabMenuImageNoAccess = value
                        }
                    }
                    
                    if let value = tab[NSLocalizedString("sponsor_banner", comment: "")] as? String{
                        if value != "" {
                            sponsor.sponsorBanner =   URL(string:value)!
                        }
                    }
                    
                    if let value = tab["sponsor_spacing"] as? String {
                        let sponsorSpacingString = value
                        if sponsorSpacingString != "" {
                            sponsor.sponsorSpacing =  Int(sponsorSpacingString)!
                        }
                    }
                    
                    if let value = tab["sponsor_banner_start"] as? String {
                        let sponsorStartString = value
                        if sponsorStartString != "" {
                            sponsor.sponsorBannerStart =  Int(sponsorStartString)!
                        }
                    }
                    
                    if let value = tab[NSLocalizedString("sponsor_message_portrait", comment: "")] as? String  {
                        if value != "" {
                            sponsor.sponsorMessagePortrait =   NSURL(string:value)!
                            EmojiDao().loadImageBy(name: tabMenu.tabMenuName+"SponsorPortrait.image", url: value)
                        }
                    }
                    
                    if let value = tab[NSLocalizedString("sponsor_message_landscape", comment: "")] as? String {
                        if value != "" {
                            sponsor.sponsorMessageLandscape =   NSURL(string:value)!
                            EmojiDao().loadImageBy(name: tabMenu.tabMenuName+"Sponsorlandscape.image", url: value)
                        }
                    }
                    
                    tabMenu.sponsor = sponsor
                    
                    //Emoji List
                    if let objectEmojiList : Array<Any> =  tab["emoji_list"] as? Array<Any> {
                        for objectEmoji in objectEmojiList as! [Dictionary<String, AnyObject>]{
                            let emoji = Emoji()
                            
                            //Emoji Name
                            if let value = objectEmoji["name"] as? String {
                                emoji.emojiName = value
                            } else {
                                throw DataError.BadData
                            }
                            
                            //Resource Name
                            if let value = objectEmoji["id"] as? String {
                                emoji.emojiResourceName = String(describing: value) + ".emoji"
                            } else {
                                throw DataError.BadData
                            }
                            
                            //Emoji Asset
                            if let value = objectEmoji["emoji_asset_1"] as? String {
                                emoji.emojiUrlFullScreen =  value
                                emoji.emojiUrlThumbnails = value
                            } else {
                                throw DataError.BadData
                            }
                            
                            //Emoji Preview
                            if objectEmoji["emoji_preview_1"] != nil {
                                if let valueString = objectEmoji["emoji_preview_1"] as? String {
                                    if valueString != "" {
                                        emoji.emojiUrlThumbnails = valueString
                                        if let value = objectEmoji["id"] as? String {
                                            emoji.emojiResourceName = String(describing: value) + ".emoji"
                                        } else {
                                            throw DataError.BadData
                                        }
                                    }
                                } else {
                                    throw DataError.BadData
                                }
                            }
                            
                            //Emoji Status
                           /* if let value = objectEmoji["active"] as? String {
                                let active = (value == "1")
                                emoji.emojiStatus = active
                            } else {
                                throw DataError.BadData
                            }*/
                            
                            //Apple Produc ID
                            if let value = objectEmoji["apple_product_id"] as? String {
                                if  value != "" && !value.isEmpty {
                                    emoji.appleProductId = value
                                }
                            } else {
                                throw DataError.BadData
                            }
                            
                            if let value = objectEmoji["lock"] as? Bool {
                                emoji.lock = value
                            } else {
                                throw DataError.BadData
                            }
                           
                            emoji.isPack = false
                            if let value = objectEmoji["is_pack"] as? Bool {
                                emoji.isPack = value
                            } else {
                                throw DataError.BadData
                            }
                            
                            if let value = objectEmoji["emoji_type"] as? String {
                                switch value {
                                case "free":
                                    emoji.emojiType = .FREE
                                case "purchase":
                                    emoji.emojiType = .PURCHASE
                                case "reward":
                                    emoji.emojiType = .REWARD
                                case "sponsor":
                                    emoji.emojiType = .SPONSOR
                                default:
                                    emoji.emojiType = .FREE
                                }
                            } else {
                                throw DataError.BadData
                            }
                            
                            do {
                                let documentsDirectoryURL: NSURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
                                emoji.emojiLocalPath = documentsDirectoryURL.appendingPathComponent(emoji.emojiResourceName)! as NSURL
                            } catch {
                                throw DataError.BadData
                            }
                            
                            tabMenu.tabMenuEmojis.append(emoji)
                        }
                    }
                    
                    listOfTabs.append(tabMenu)
                }
            }
        }
        
        return sectionList(listOfTabs: listOfTabs)
    }
    
    //obtiene la lista de emojis de cada tab para luego seccionarla
    func sectionList(listOfTabs: [TabMenu]) -> [TabMenu]{
        for i in 0 ..< listOfTabs.count {
            let tabMenu = listOfTabs[i]
            tabMenu.tabMenuEmojis = self.loadEmojiList(listOfEmojis: tabMenu.tabMenuEmojis)
        }
        
        return addSponsor(listOfTabs: listOfTabs)
    }
    
    //secciona la lista de emojis dependiendo del numero de emojis por fila
    func loadEmojiList(listOfEmojis: [AnyObject]) -> [AnyObject]{
        var listTemp = [AnyObject]()
        var indexedListTemp = [AnyObject]()
        
        for i in 0 ..< listOfEmojis.count {
            if indexedListTemp.count ==  AppContext.instance.numberOfEmojisPerRow {
                listTemp.append(indexedListTemp as AnyObject)
                indexedListTemp.removeAll()
            }
            
            indexedListTemp.append(listOfEmojis[i])
            
            if i == listOfEmojis.count - 1{
                listTemp.append(indexedListTemp as AnyObject)
            }
        }

        return listTemp
    }

    //convierte una lista de emojis seccionada en una lista plana
    func restructureEmojiList(listOfEmojis: [AnyObject]) -> [AnyObject] {
        var listTemp = [AnyObject]()

        for i in 0 ..< listOfEmojis.count {
            let list = listOfEmojis[i]
            
            for j in 0 ..< list.count {
                let obj = list.object(at: j) as AnyObject
               listTemp.append(obj)
            }
        }

        return listTemp
    }
    
    //obtiene la lista de emojis de cada tab para luego adicionar los sponsors
    func addSponsor(listOfTabs: [TabMenu]) -> [TabMenu] {
        for i in 0 ..< listOfTabs.count {
            let tabMenu = listOfTabs[i]
            if tabMenu.sponsor.sponsorBanner != nil {

                var starIndex = tabMenu.sponsor.sponsorBannerStart
                if starIndex > 0 {
                    if starIndex > 0 {
                        starIndex = starIndex - 1
                    }
                    tabMenu.tabMenuEmojis = self.addSponsorToList(spacing: Int(tabMenu.sponsor.sponsorSpacing), starIndex:starIndex, sponsor:tabMenu.sponsor,
                                                             listOfEmojis: tabMenu.tabMenuEmojis, listOfEmojisOriginal: tabMenu.tabMenuEmojis)
                }
            }
        }
        
        return listOfTabs
    }
    
    //añade los sponsors a cada los tabs
    func addSponsorToTab(tab: TabMenu) -> TabMenu {
        let tabMenu = tab
        if tabMenu.sponsor.sponsorBanner != nil {

            var starIndex = tabMenu.sponsor.sponsorBannerStart
            
            if starIndex > 0 {
                if starIndex > 0 {
                    starIndex = starIndex - 1
                }
                tabMenu.tabMenuEmojis = self.addSponsorToList(spacing: Int(tabMenu.sponsor.sponsorSpacing), starIndex:starIndex, sponsor:tabMenu.sponsor,
                                                                listOfEmojis: tabMenu.tabMenuEmojis, listOfEmojisOriginal: tabMenu.tabMenuEmojis)
            }

        }
        
        return tabMenu
    }
    
    //añade los sponsors banners a una lista seccionada
    func addSponsorToList(spacing:Int, starIndex:Int, sponsor:Sponsor, listOfEmojis: [AnyObject], listOfEmojisOriginal: [AnyObject]) -> [AnyObject] {
        //let numberOfItems = AppContext.instance.numberOfEmojisPerRow
        var listOfEmojisTemp = listOfEmojis

        if spacing == 0 && starIndex <= listOfEmojisTemp.count {
            listOfEmojisTemp.insert([sponsor] as AnyObject, at: starIndex)
            return listOfEmojisTemp
        }
        
        if (starIndex == listOfEmojisTemp.count) {
            listOfEmojisTemp.insert([sponsor] as AnyObject, at: listOfEmojis.count)
            return listOfEmojisTemp
        }
        
        if starIndex > listOfEmojisTemp.count {
            listOfEmojisTemp.insert([sponsor] as AnyObject, at: listOfEmojisTemp.count)
            return listOfEmojisTemp
        }
        
        listOfEmojisTemp.insert([sponsor] as AnyObject, at: starIndex)
        return addSponsorToList(spacing: spacing, starIndex:starIndex+spacing+1, sponsor:sponsor, listOfEmojis:listOfEmojisTemp, listOfEmojisOriginal: listOfEmojisOriginal)
    }
    
    //elimina los sponsors de una lista seccionada
    func deleteSponsor(listOfTabs: [AnyObject], atIndex: Int) -> [AnyObject] {
        var listTemp = listOfTabs

        if atIndex >= listOfTabs.count {
            return listOfTabs
        }
        
        let value = listOfTabs[atIndex] 
        let item = value.object(at: 0)
        
        if item  is Sponsor {
            listTemp.remove(at: atIndex)
        }

        return deleteSponsor(listOfTabs: listTemp, atIndex: atIndex + 1)
    }
}
