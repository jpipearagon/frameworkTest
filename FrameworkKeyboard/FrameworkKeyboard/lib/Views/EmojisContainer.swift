//
//  EmojisConstainer.swift
//  EmojiKeyboard
//
//  Created by branger-briz on 4/29/16.
//  Copyright © 2016 com.antediem.keyboard. All rights reserved.
//

import UIKit

protocol EmojisContainerDelegate {
    func changePage(page :Int)
    func finishedChangePage(page :Int)
}

class EmojisContainer: UIScrollView, UIScrollViewDelegate {
    var countPages : Int = 0
    var delegateContainer: EmojisContainerDelegate?
    var currentPage : Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        contentOffset = CGPoint(x: 0, y: 0)
        delegate = self
        countPages = AppContext.instance.getNumberOfTabs()
        self.backgroundColor = UIColor.clear
        updateLayout()
    }
    
    func updateLayout() {
        self.layoutIfNeeded()
        self.layoutSubviews()
        countPages = AppContext.instance.getNumberOfTabs()
        contentSize = CGSize(width: frame.size.width * CGFloat(countPages), height: frame.size.height)
        self.scrollToCurrentPage()
    }
    
    func insertSubviews(views : NSArray) {
        for i in 0 ..< views.count {
            let view = views.object(at: i) as! UIView
            self.addSubview(view)
        }
    }
    
    func scrollViewDidScroll(_ scrollView :UIScrollView) {
      /*  if scrollView is EmojisContainer {
            let pageWidth = scrollView.frame.size.width
            let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
            if page >= 0 && self.currentPage != page && page <  countPages{
               // currentPage = page
                //delegateContainer?.changePage(page)
            }
        }*/
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView is EmojisContainer {
            let pageWidth = scrollView.frame.size.width
            let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
            if page >= 0 && currentPage != page && page <  countPages{
                currentPage = page
                delegateContainer?.finishedChangePage(page: currentPage)
            }
        }
    }
    
    func scrollToPage(page :Int) {
        currentPage = page
        var frame =  self.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: true)
    }
    
    func scrollToCurrentPage() {
        var frame =  self.frame
        frame.origin.x = frame.size.width * CGFloat(currentPage)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: true)
    }
    
    deinit {
        print("Deinit process done.")
    }
}
