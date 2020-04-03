//
//  OtherActionsViewController.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/24/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol OtherActionsDelegate {
    func selectOption(row :Int, tag :Int)
}

class OtherActionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var delegate: OtherActionsDelegate?
    var listOfTabs: [TabMenu]!
    var selectedRow :Int!
    var seletedTag :Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedRow = -1
        self.seletedTag = -1

        self.tableView.register(UINib(nibName: "OtherActionViewCell", bundle:nil), forCellReuseIdentifier: "EmojiViewCellID")
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var indexPath = IndexPath(row: 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        tableView.flashScrollIndicators()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.listOfTabs == nil  {
            return 1
        }
        
        return self.listOfTabs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let maxTabs = AppContext.instance.getMaxTabs()
        let cell = tableView.dequeueReusableCell( withIdentifier: "EmojiViewCellID", for: indexPath)as! OtherActionViewCell
        cell.tag = indexPath.row + maxTabs
        cell.emojiIcon.alpha = 1
        cell.emojiIcon.image = nil
        
        if self.listOfTabs == nil || indexPath.row == self.listOfTabs.count {
            cell.emojiIcon.image = UIImage(named:"icon.alphanumeric")
            cell.textAction.text = "KEYBOARD"
            cell.tag = indexPath.row + maxTabs
        } else {
            let tab = self.listOfTabs[indexPath.row]
            cell.textAction.text = tab.tabMenuName.uppercased()

            let headers : [String : String] = [
                "api_key": Config.instance.API_KEY]
            
            Alamofire.request(URL(string:
                tab.tabMenuImageOffUrl)!, method: .post, headers: headers).responseImage { (response) -> Void in
                guard let image = response.result.value else { return }
                cell.emojiIcon.image = image
            }
            
        }
        
        let prefs = UserDefaults.standard
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0

        if  let widthTemp = prefs.value(forKey: AppContext.keyValueTabButtonWidth) {
            width = widthTemp as! CGFloat
        }
        
        if  let heightTemp = prefs.value(forKey: AppContext.keyValueTabButtonHeight) {
            height = heightTemp as! CGFloat
        }

        cell.emojiIcon.frame = CGRect(x: cell.emojiIcon.frame.origin.x, y: (cell.frame.size.height - height) / 2, width: width, height: height)

        
        let x = cell.emojiIcon.frame.origin.x + width + 17
        let widthField =  cell.frame.size.width - x - 15
        cell.textAction.frame = CGRect(x: x, y: cell.textAction.frame.origin.y, width: widthField, height: cell.textAction.frame.size.height)
        if self.seletedTag == indexPath.row + maxTabs{
            cell.emojiIcon.alpha = 1.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath as IndexPath)
        self.selectedRow = indexPath.row
        self.seletedTag = selectedCell?.tag
        self.delegate?.selectOption(row: indexPath.row, tag: (selectedCell?.tag)!)
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //get refrence of vertical indicator
        let verticalIndicator: UIImageView? = (scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView)
        //set color to vertical indicator
        verticalIndicator?.backgroundColor = UIColor(red: 151/255.0, green: 151/255.0, blue: 151/255.0, alpha: 0.7)

    }

}
