//
//  CRLAlertWrapper.swift
//
//  Created by sasho on 1/19/15.
//  Copyright (c) 2015 sasho. All rights reserved.
//

import Foundation
import UIKit

/**
アラートタイプです

- Alert:       AlertView
- ActionSheet: ActionSheet
*/
enum CRLAlertType {
    case ActionSheet
    case Alert
}

/**
アクションスタイル

- Default:     デフォルト
- Cancel:      キャンセル
- Destructive: 破棄
*/
enum CRLActionStyle {
    case Default
    case Cancel
    case Destructive
    
    func getActionStyle() -> UIAlertActionStyle {
        switch self {
        case .Default:
            return UIAlertActionStyle.Default
        case .Cancel:
            return UIAlertActionStyle.Cancel
        case .Destructive:
            return UIAlertActionStyle.Destructive
        }
    }
}

struct CRLAction {
    
    var name :String!
    
    var style :CRLActionStyle
    
    var handler :((alertWrapper :CRLAlertWrapper) -> Void)?
    
    var buttonIndex :Int! = -1
    
    init(name :String!, style :CRLActionStyle, handler :((alertWrapper :CRLAlertWrapper) -> Void)) {
        self.name = name
        self.style = style
        self.handler = handler
    }
}

class CRLAlertWrapper: NSObject, UIAlertViewDelegate, UIActionSheetDelegate {
    /// タイトル
    var title :String?
    /// メッセージ
    var message :String?
    /// アラートタイプ
    var alertType :CRLAlertType
    /// アクションの一覧
    private var actions = [CRLAction]()
    /// 自身の強参照
    private var strongSelf :CRLAlertWrapper?
    
    // MARK: - Init
    init(title :String?, message:String?, alertType :CRLAlertType!) {
        self.title = title
        self.message = message
        self.alertType = alertType
    }
    
    deinit {
        
    }
    
    // MARK: - Public Methods
    func addAction(action :CRLAction) {
        self.actions.append(action)
    }
    
    func addActions(actions :[CRLAction]) {
        for action in actions {
            self.addAction(action)
        }
    }
    
    func show() {
        // 自身を保持
        strongSelf = self
        
        if isIos8AndLater() {
            println("iOS 8 And Later")
            createAlertViewController()
        }
        else {
            println("iOS 7 And earlier")
            switch alertType {
            case .ActionSheet:
                createActionSheet()
                break
            case .Alert:
                createAlertView()
                break
            }
        }
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var filterArray = actions.filter { (action) -> Bool in
            return action.buttonIndex! == buttonIndex
        }
        
        if filterArray.count > 0 {
            var action = filterArray.first!
            if let handler = action.handler {
                handler(alertWrapper: self)
            }
            
            // delay Release
            self.releaseStrongSelf()
        }
    }
    
    func alertViewCancel(alertView: UIAlertView) {
        self.alertView(alertView, clickedButtonAtIndex: alertView.cancelButtonIndex)
    }
    
    // MARK: UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var filterArray = actions.filter { (action) -> Bool in
            return action.buttonIndex! == buttonIndex
        }
        
        if filterArray.count > 0 {
            var action = filterArray.first!
            if let handler = action.handler {
                handler(alertWrapper: self)
            }
            
            // delay Release
            self.releaseStrongSelf()
        }
    }
    
    func actionSheetCancel(actionSheet: UIActionSheet) {
        self.actionSheet(actionSheet, clickedButtonAtIndex: actionSheet.cancelButtonIndex)
    }
    
    // MARK: - Private Methods
    private func createAlertViewController() {
        
        var controller = UIAlertController(title: title
            , message: message
            , preferredStyle: alertType == CRLAlertType.ActionSheet ? .ActionSheet : .Alert)
        
        for action in actions {
            controller.addAction(UIAlertAction(title: action.name
                , style: action.style.getActionStyle()
                , handler: {[unowned self] (alertAction) -> Void in
                    if let handler = action.handler {
                        handler(alertWrapper: self)
                    }
                    
                    // delay Release
                    self.releaseStrongSelf()
            }))
        }
        getViewController().presentViewController(controller, animated: true, completion: nil)
    }
    
    private func createAlertView() {
        var alert = UIAlertView(title: title
            , message: message
            , delegate: self
            , cancelButtonTitle: nil)
        
        for i in 0..<self.actions.count {
            var action = self.actions[i]
            
            switch self.actions[i].style {
            case .Default:
                self.actions[i].buttonIndex = alert.addButtonWithTitle(self.actions[i].name!)
                break
            case .Cancel:
                self.actions[i].buttonIndex = alert.addButtonWithTitle(self.actions[i].name!)
                alert.cancelButtonIndex = self.actions[i].buttonIndex!
                break
            case .Destructive:
                println("UIAlertView does not hold the destructive type button")
                self.actions[i].buttonIndex = alert.addButtonWithTitle(self.actions[i].name!)
                break
            }
        }
        
        alert.show()
    }
    
    private func createActionSheet() {
        
        var strings = [String]()
        if let titleStr = self.title {
            strings.append(titleStr)
        }
        if let messageStr = self.message {
            strings.append(messageStr)
        }
        
        var actionSheet = UIActionSheet(title: "\n".join(strings)
            , delegate: self
            , cancelButtonTitle: nil
            , destructiveButtonTitle: nil)
        
        for i in 0..<self.actions.count {
            var action = self.actions[i]
            
            switch self.actions[i].style {
            case .Default:
                self.actions[i].buttonIndex = actionSheet.addButtonWithTitle(self.actions[i].name!)
                break
            case .Cancel:
                self.actions[i].buttonIndex = actionSheet.addButtonWithTitle(self.actions[i].name!)
                actionSheet.cancelButtonIndex = self.actions[i].buttonIndex!
                break
            case .Destructive:
                self.actions[i].buttonIndex = actionSheet.addButtonWithTitle(self.actions[i].name!)
                actionSheet.destructiveButtonIndex = self.actions[i].buttonIndex!
                break
            }
        }
        
        actionSheet.showInView(getViewController().view)
    }
    
    private func getViewController(rootViewController :UIViewController? = nil) -> UIViewController {
        var tmpViewController :UIViewController
        if let rootVC = rootViewController {
            tmpViewController = rootVC
        }
        else {
            tmpViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        }
        
        if tmpViewController is UITabBarController {
            return getViewController(rootViewController: (tmpViewController as UITabBarController).selectedViewController)
        }
        else if tmpViewController is UINavigationController {
            return getViewController(rootViewController: (tmpViewController as UINavigationController).visibleViewController)
        }
        else if let presentedViewController = tmpViewController.presentedViewController {
            return getViewController(rootViewController: presentedViewController)
        }
        
        return tmpViewController
    }
    
    private func releaseStrongSelf() {
        dispatch_after(1, dispatch_get_main_queue(), { () -> Void in
            self.strongSelf = nil
        })
    }
    
    private func isIos8AndLater() -> Bool {
        return floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
    }
}

