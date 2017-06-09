//
//  SignUpSucceedViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 7/5/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class SignUpSucceedViewController: BaseViewController {
    
    var phone: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "注册成功"
        
        let leftBarItem = UIBarButtonItem(title: "退出登录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.signOutAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShopCreate@MerchantCenter", let desVC = segue.destination as? ShopCreateViewController {
            desVC.phone = phone
        }
    }

    @IBAction func inputShopInfoAction(_ sender: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("ShopCreate@MerchantCenter", source: self, sender: nil)
    }
}

extension SignUpSucceedViewController {
    func signOutAction() {
        Utility.showConfirmAlert(self, message: "确认退出登录？", confirmCompletion: {
            UserManager.sharedInstance.signedIn = false
            UserManager.sharedInstance.userInfo = nil
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
    }
}
