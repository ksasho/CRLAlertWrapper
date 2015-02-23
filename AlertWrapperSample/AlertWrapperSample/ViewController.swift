//
//  ViewController.swift
//  AlertWrapperSample
//
//  Created by sasho kousuke on 2015/02/23.
//  Copyright (c) 2015年 sasho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK : - IBAction
    @IBAction func showAlert(sender :AnyObject) {
        var wrapper = CRLAlertWrapper(title: "show Alert!"
            , message: "this is Message"
            , alertType: .Alert)
        
        wrapper.addAction(CRLAction(name: "default Button"
            , style: .Default
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.addAction(CRLAction(name: "Cancel Button"
            , style: .Cancel
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.addAction(CRLAction(name: "Destructive Button"
            , style: .Destructive
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.show()
    }
    
    @IBAction func showActionSheet(sender :AnyObject) {
        var wrapper = CRLAlertWrapper(title: "show ActionSheet!"
            , message: "this is Message"
            , alertType: .ActionSheet)
        
        wrapper.addAction(CRLAction(name: "default Button"
            , style: .Default
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.addAction(CRLAction(name: "Cancel Button"
            , style: .Cancel
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.addAction(CRLAction(name: "Destructive Button"
            , style: .Destructive
            , handler: { (alertWrapper) -> Void in
                
        }))
        
        wrapper.show()
    }
}

