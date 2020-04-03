//
//  KeyboardNumericViewController.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 5/23/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol KeyBoardnumericDelegate {
    func insertTextNumeric(text :String)
    func openAlphabeticKeyboard()
}

class KeyboardNumericViewController: UIViewController {
    var delegate: KeyBoardnumericDelegate?
    @IBOutlet weak var alphabeticKey: UIButton!
    @IBOutlet weak var spaceKey: UIButton!
    @IBOutlet weak var returnKey: UIButton!
    @IBOutlet var buttonKeyCollection: [UIButton]!
    private var spaceButtonTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "KeyboardNumericViewController", bundle: nil)
        self.view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView

        for button in buttonKeyCollection {
            button.titleLabel!.font =  UIFont(name: "ProximaNovaA-Light", size: 24)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitleColor(UIColor(red: 58.0/255.0, green: 66.0/255.0, blue: 78.0/255.0, alpha: 1.0), for: .normal)
            self.roundedBorder(button: button, ratio: 5.0)
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(self.keyboardButtonTapped), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 5, bottom: 7,right: 5)
        }
        
        self.roundedBorder(button: self.alphabeticKey, ratio: 5.0)
        self.alphabeticKey.setTitleColor(UIColor(red: 134.0/255.0, green: 135.0/255.0, blue: 134.0/255.0, alpha: 1.0), for: .normal)
        self.alphabeticKey.titleLabel!.font =  UIFont(name: "ProximaNovaA-Light", size: 18)
        
        self.roundedBorder(button: self.spaceKey, ratio: 5.0)
        self.spaceKey.setTitleColor(UIColor(red: 58.0/255.0, green: 66.0/255.0, blue: 78.0/255.0, alpha: 1.0), for: .normal)
        self.spaceKey.backgroundColor = UIColor.white
        self.spaceKey.titleLabel!.font =  UIFont(name: "ProximaNovaA-Light", size: 18)
        
        self.roundedBorder(button: self.returnKey, ratio: 5.0)
        self.returnKey.setTitleColor(UIColor(red: 134.0/255.0, green: 135.0/255.0, blue: 134.0/255.0, alpha: 1.0), for: .normal)
        self.returnKey.titleLabel!.font =  UIFont(name: "ProximaNovaA-Light", size: 18)
        
        let spaceButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardNumericViewController.handleLongPressForSpaceButtonWithGestureRecognizer(gestureRecognizer:)))
        self.spaceKey.addGestureRecognizer(spaceButtonLongPressGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    func roundedBorder(button: UIButton, ratio: CGFloat) {
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.cornerRadius = ratio
        let borderColor = UIColor(red: 181.0/255.0, green: 181.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = borderColor.cgColor
    }
    
    @objc func handleLongPressForSpaceButtonWithGestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if spaceButtonTimer == nil {
                spaceButtonTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(KeyboardAlphabeticController.handleSpaceButtonTimerTick(timer:)), userInfo: nil, repeats: true)
                spaceButtonTimer!.tolerance = 0.01
                RunLoop.main.add(spaceButtonTimer!, forMode: RunLoop.Mode.default)
            }
        default:
            spaceButtonTimer?.invalidate()
            spaceButtonTimer = nil
        }
    }
    
    func handleSpaceButtonTimerTick(timer: Timer) {
        self.delegate?.insertTextNumeric(text: " ")
    }
    
    //MARK: @IBAction
    @IBAction func keyboardButtonTapped(sender: AnyObject) {
        let button = sender as! UIButton
        self.delegate?.insertTextNumeric(text: (button.titleLabel?.text)!)
    }
    
    @IBAction func alphabeticButtonTapped(sender: AnyObject) {
        self.delegate?.openAlphabeticKeyboard()
    }

    @IBAction func spacebarButtonTapped(sender: AnyObject) {
        self.delegate?.insertTextNumeric(text: " ")
    }
    
    @IBAction func returnButtonTapped(sender: AnyObject) {
        self.delegate?.insertTextNumeric(text: "\n")
    }
}
