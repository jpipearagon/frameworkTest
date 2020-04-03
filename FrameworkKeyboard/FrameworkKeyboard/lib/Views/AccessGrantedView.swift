//
//  AccessGrantedView.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 7/20/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol AccessGrantedDelegate {
    func openSettings(url :NSURL)
}

class AccessGrantedView: UIView {
    var delegate : AccessGrantedDelegate?
    
    @IBOutlet weak var imageview_noaccess: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //self.loadView()
    }
    
    func loadView(){
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.backgroundColor = AppContext.instance.getAppColor()
        var rect = self.frame
        rect.size.width =  rect.size.width-24;
        rect.origin.x = 12
        let imageView = YLImageView(frame: rect)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        //.flexibleWidth, .flexibleHeight
        self.addSubview(imageView)

            let path = Bundle.main.path(forResource: Config.instance.IMAGE_NO_ACCESS, ofType: nil)
            if path != nil {
                let data = NSData(contentsOf: URL(fileURLWithPath: path!))
                
                let type = Util.getTypeOfFile(data: data!)
                
                if type == .GIF {
                    let image = YLGIFImage(data: data! as Data)
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                    
                } else if (type == .IMAGE) {
                    let image = UIImage(data: data! as Data)
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
    }
    
    class func instanceFromNib() -> AccessGrantedView {
        return UINib(nibName: "AccessGrantedView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AccessGrantedView
    }

    @IBAction func goToSettings(sender: UIButton) {
        delegate?.openSettings(url: NSURL(string: Config.instance.URL_HOSTAPP + Config.instance.URL_VIEW_KEYBOARD_SETTINGS)!)
    }
    
    func setImageNoAccess(tab:TabMenu?) {
        
        if let tab = tab{
            let headers : [String : String] = [
                "api_key": Config.instance.API_KEY]
            
            if let url = URL(string:tab.tabMenuImageNoAccess!){
                Alamofire.request(url, method: .post , headers: headers).responseImage(completionHandler: { (DataResponse) in
                    guard let image = DataResponse.result.value else { return }
                    self.imageview_noaccess.image = image
                })
            }else{
                imageview_noaccess.image = UIImage(named: NSLocalizedString("ImageNoAccess", comment: ""))
            }
            
        }else{
            imageview_noaccess.image = UIImage(named: NSLocalizedString("ImageNoAccess", comment: ""))
        }
        
    }
}
