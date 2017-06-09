//
//  ChargeDetailViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/3/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ChargeDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var resultImageView: UIImageView!
    @IBOutlet fileprivate weak var resultLbl: UILabel!
    
    @IBOutlet fileprivate weak var bankLbl: UILabel!
    @IBOutlet fileprivate weak var bankDetailLbl: UILabel!
    @IBOutlet fileprivate weak var pointsLbl: UILabel!
    @IBOutlet fileprivate weak var pointsDetailLbl: UILabel!
    @IBOutlet fileprivate weak var amountLbl: UILabel!
    @IBOutlet fileprivate weak var amountDetailLbl: UILabel!
    
    @IBOutlet fileprivate weak var topButton: UIButton!
    @IBOutlet fileprivate weak var bottonButton: UIButton!
    
    var isSucceed: Bool = true
    var tips: String = "积分充值成功，即充即可使用"
    var bankCardInfo: String = "绵阳商业银行"
    var point: String = ""
    var amount: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "充值详情"
        navigationItem.backBarButtonItem = nil
        
        navigationItem.hidesBackButton = true
        
        resultLbl.text = tips
        
        bankDetailLbl.text = bankCardInfo
        pointsLbl.text = "充值数量"
        pointsDetailLbl.text = point
        amountLbl.text = "支付金额"
        amountDetailLbl.text = amount
        
        if isSucceed {
            bottonButton.isHidden = true
        } else {
            resultImageView.image = UIImage(named: "MerchantCenterStatusFailed")
            topButton.removeTarget(self, action: #selector(self.completeAction), for: .touchUpInside)
            topButton.addTarget(self, action: #selector(self.backToPreviousAction), for: .touchUpInside)
            topButton.setTitle("重新充值", for: UIControlState())
            bottonButton.addTarget(self, action: #selector(self.resignAction), for: .touchUpInside)
            bottonButton.setTitle("放弃支付", for: UIControlState())
        }
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshPointsAfterChargeNotification"), object: nil)
        
        guard let ncArray = navigationController?.viewControllers else {return}
        _ = navigationController?.popToViewController(ncArray[ncArray.count - 3], animated: true)
    }
    
    func backToPreviousAction() {
        guard let ncArray = navigationController?.viewControllers else {return}
        _ = navigationController?.popToViewController(ncArray[ncArray.count - 2], animated: true)
    }
    
    func resignAction() {
        Utility.showConfirmAlert(self, message: "是否放弃本次充值", confirmCompletion: {
            guard let ncArray = self.navigationController?.viewControllers else {return}
            _ = self.navigationController?.popToViewController(ncArray[ncArray.count - 3], animated: true)
        })
    }
    
}
