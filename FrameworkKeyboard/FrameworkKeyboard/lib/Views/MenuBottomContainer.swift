//
//  MenuBotton.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/29/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol MenuBottomDelegate {
    func selectTab(tag: Int)
}

class MenuBottomContainer : UIView {
    var listOfTabs : NSArray = []
    var delegateTabs: MenuBottomDelegate?
    var buttonList : [UIButton] = []
    var allViewsList : [UIView] = []

    var currentTab : Int = 0
    var tabMenuName : String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateLayout() {
        self.loadButtonsMenu()
    }
    
    func loadMenu() {
        self.loadButtonsMenu()
    }
    
    func loadButtonsMenu() {
        self.clearAllButtonBackgrounds()
        //self.contentOffset = CGPoint(x:0, y:0)
        self.buttonList.removeAll()
        self.allViewsList.removeAll()
        self.subviews.forEach({ $0.removeFromSuperview() })
        let maxTabs = AppContext.instance.getMaxTabs()

        if (maxTabs < 5 && maxTabs < self.listOfTabs.count) {
            for i in 0...maxTabs - 1{
                let tab = self.listOfTabs[i] as! TabMenu
                let button = self.createButton(index: i, tab: tab)
                self.buttonList.append(button)
                self.addSubview(button)
                
                if (i == 0) {
                    let line = UIView()
                    line.frame = CGRect(x: 0, y: 0, width: 1, height: self.frame.size.height)
                    line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                    self.addSubview(line)
                    self.allViewsList.append(line)
                }
                
                self.allViewsList.append(button)
                
                let line = UIView()
                let x =  CGFloat(i+1) * CGFloat(button.frame.size.width)
                line.frame = CGRect(x: x - 1, y: 0, width: 1, height: self.frame.size.height)
                line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                self.addSubview(line)
                self.allViewsList.append(line)
            }
        } else {
            if self.listOfTabs.count > 5 {
                for i in 0...4 {
                    let tab = self.listOfTabs[i] as! TabMenu
                    let button = self.createButton(index: i, tab: tab)
                    self.buttonList.append(button)
                    self.addSubview(button)
                    
                    if (i == 0) {
                        let line = UIView()
                        line.frame = CGRect(x: 0, y: 0, width: 1, height: self.frame.size.height)
                        line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                        self.addSubview(line)
                        self.allViewsList.append(line)
                    }
                    
                    self.allViewsList.append(button)
                    
                    let line = UIView()
                    let x =  CGFloat(i+1) * CGFloat(button.frame.size.width)
                    line.frame = CGRect(x: x - 1, y: 0, width: 1, height: self.frame.size.height)
                    line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                    self.addSubview(line)
                    self.allViewsList.append(line)
                }
            } else {
                self.listOfTabs.enumerateObjects( { (value , index, stop) in
                    let tab = value as! TabMenu
                    let button = self.createButton(index: index, tab: tab)
                    self.buttonList.append(button)
                    self.addSubview(button)
                    
                    if (index == 0) {
                        let line = UIView()
                        line.frame = CGRect(x: 0, y: 0, width: 1, height: self.frame.size.height)
                        line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                        self.addSubview(line)
                        self.allViewsList.append(line)
                    }
                    
                    self.allViewsList.append(button)

                    let line = UIView()
                    let x =  CGFloat(index+1) * CGFloat(button.frame.size.width)
                    line.frame = CGRect(x: x - 1, y: 0, width: 1, height: self.frame.size.height)
                    line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                    self.addSubview(line)
                    self.allViewsList.append(line)
                })
            }
        }
    }
    
    func createButton(index :Int, tab :TabMenu) -> UIButton {
        let maxTabs = AppContext.instance.getMaxTabs()
        var buttons = maxTabs
        if (self.listOfTabs.count < maxTabs) {
            buttons = self.listOfTabs.count
        }
  
        let width = self.frame.size.width/CGFloat(buttons)
        let origin = CGFloat(index) * CGFloat(width)
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.backgroundColor = UIColor.clear
        button.frame = CGRect(x: origin, y: 0.0, width: width, height: self.frame.size.height)
        button.tag = index
        button.addTarget(self, action: #selector(self.selectTab), for: .touchUpInside)
        button.isHidden = true
        //button.alpha = 0.3
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let  path = documentsDirectory.appendingPathComponent(tab.tabMenuName + "Off").path
            
            if fileManager.fileExists(atPath: path) {
                let data = FileManager.default.contents(atPath: path)
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame = CGRect(x: 0, y: 0, width: button.frame.size.width/1.7, height: button.frame.size.height/1.7)
                    
                    let prefs = UserDefaults.standard
                    prefs.setValue(imageView.frame.size.width, forKey: AppContext.keyValueTabButtonWidth)
                    prefs.setValue(imageView.frame.size.height, forKey: AppContext.keyValueTabButtonHeight)
                    prefs.synchronize()
                    
                    imageView.center = CGPoint(x: button.frame.size.width  / 2, y: button.frame.size.height / 2)
                    imageView.backgroundColor = UIColor.clear
                    button.addSubview(imageView)
                    button.isHidden = false
                    if self.currentTab != -1 {
                        self.selectCurrentTab()
                    }
                }
            }
        
        }

        let headers : [String : String] = [
            "api_key": Config.instance.API_KEY]
        
        Alamofire.request(tab.tabMenuImageOffUrl, method: .post,  headers: headers).responseImage { (response) in
            guard let image = response.result.value else { return }
            
            for subview in button.subviews {
                if (subview is UIImageView) {
                    subview.removeFromSuperview()
                }
            }
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: button.frame.size.width/1.7, height: button.frame.size.height/1.7)
            
            imageView.center = CGPoint(x: button.frame.size.width  / 2,
                                       y: button.frame.size.height / 2)
            imageView.alpha = 1
            button.addSubview(imageView)
            button.isHidden = false
            if self.currentTab != -1 {
                self.selectCurrentTab()
            }
            
            if let data = image.pngData() {
                let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let  path = documentsDirectory.appendingPathComponent(tab.tabMenuName + "Off")
                //data.writeToFile(path!.path!, atomically: true)
                do {
                    try data.write(to: URL(fileURLWithPath: path.path), options: .atomic)
                } catch {
                    print(error)
                }
            }
        }
 
        button.TabMenuName = tab.tabMenuName
        self.getOnIconTab(tab: tab)
        
        /*if (index < self.listOfTabs.count) {
            let line = UIView()
            line.frame = CGRect(x: width - 1, y: 0, width: 1, height: self.frame.size.height)
            line.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            button.addSubview(line)
        }*/
        
        return button
    }

    func getOnIconTab(tab :TabMenu) {
        let headers : [String : String] = [
            "api_key": Config.instance.API_KEY]
        
        Alamofire.request(tab.tabMenuImageOnUrl, method: .post,  headers: headers).responseImage { (response) in
            guard let image = response.result.value else { return }
            
            if let data = image.pngData() {
                let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let  path = documentsDirectory.appendingPathComponent(tab.tabMenuName + "On")
                do {
                    try data.write(to: URL(fileURLWithPath: path.path), options: .atomic)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func selectTab(sender: AnyObject) {
        self.clearAllButtonBackgrounds()
        let currentButton = sender as! UIButton
        currentButton.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
        self.setAlphaButton(button: currentButton, alpha: 1.0)
        self.setImageButton(button: currentButton, nameImage: "On")
        self.currentTab = currentButton.tag
        self.delegateTabs?.selectTab(tag: currentButton.tag)
        self.tabMenuName = currentButton.TabMenuName!
        self.showLines()
        self.hiddeLines(button: currentButton)
    }
    
    func selectTabFromPage(page :Int) {
        self.clearAllButtonBackgrounds()
        
        if AppContext.instance.selectedOthersActions == false {
            if page <= buttonList.count && buttonList.count > 0  {
                let button = buttonList[page]
                self.currentTab = page
                self.tabMenuName = button.TabMenuName!
                button.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
                
                button.backgroundColor = AppContext.instance.getColorButtonTabsSelected()
                self.setAlphaButton(button: button, alpha: 1.0)
                self.setImageButton(button: button, nameImage: "On")
            }
        }
        let button = buttonList[page]
        self.showLines()
        self.hiddeLines(button: button)
    }
    
    func hiddeLines(button:UIButton) {
        if AppContext.instance.selectedOthersActions == false {
            var indexSelected = 0
            for i in 0...allViewsList.count {
                let v = allViewsList[i]
                if v is UIButton {
                    if v.tag == button.tag {
                        indexSelected = i
                        break
                    }
                }
            }
            
            let line1 = allViewsList[indexSelected - 1]
            let line2 = allViewsList[indexSelected + 1]
            line1.isHidden = true
            line2.isHidden = true
        } else {
            allViewsList.last?.isHidden = true
        }
    }
    
    func showLines() {
        for v in allViewsList {
            v.isHidden = false
        }
    }
    
    func clearAllButtonBackgrounds() {
        for i in 0 ..< self.buttonList.count {
            let button = buttonList[i]
            button.backgroundColor =  UIColor.clear
            self.setAlphaButton(button: button, alpha: 1)
            self.setImageButton(button: button, nameImage: "Off")
        }
        self.showLines()
    }
    
    func selectMoreActions() {
        allViewsList.last?.isHidden = true
    }

    func selectCurrentTab() {
        if !AppContext.instance.selectedOthersActions {
            selectTabFromPage(page: self.currentTab)
        }
    }
    
    func setAlphaButton(button:UIButton, alpha:CGFloat) {
        for view in button.subviews {
            if view.isKind(of: UIImageView.self)  {
                let imageView = view as! UIImageView
                imageView.alpha = alpha
            }
        }
    }
    
    func setImageButton(button:UIButton, nameImage:String) {
        for view in button.subviews {
            if view.isKind(of: UIImageView.self)  {
                let imageView = view as! UIImageView
                let fileManager = FileManager.default
                let documentsDirectory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let  path = documentsDirectory.appendingPathComponent(button.TabMenuName! + nameImage).path
                
                if fileManager.fileExists(atPath: path) {
                    let data = FileManager.default.contents(atPath: path)
                    let image = UIImage(data: data!)
                    imageView.image = image
                }
                
            }
        }
    }
    
}
