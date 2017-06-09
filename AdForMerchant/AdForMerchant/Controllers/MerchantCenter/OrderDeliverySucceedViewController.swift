//
//  OrderDeliverySucceedViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/11/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderDeliverySucceedViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "发货"
        navigationItem.backBarButtonItem = nil
        
        navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Action
    
    @IBAction func completeAction() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: sendSuccessfulNotification), object: nil, userInfo: nil)
        guard let ncArray = navigationController?.viewControllers else {return}
        _ = navigationController?.popToViewController(ncArray[ncArray.count - 3], animated: true)
    }
    
}
