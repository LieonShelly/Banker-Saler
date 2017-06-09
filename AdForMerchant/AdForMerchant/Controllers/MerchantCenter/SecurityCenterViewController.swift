//
//  SecurityCenterViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/22/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class SecurityCenterViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "安全中心"
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
    
    @IBAction func modifyMerchantInfoAction(_ btn: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("MerchantCenterInfo@MerchantCenter", source: self, sender: nil)
        
    }
    
    // MARK: - Methods
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension SecurityCenterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            if UserManager.sharedInstance.userInfo?.settedPayPassward == "1" {
                return 2
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension SecurityCenterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "修改登录密码"
        case (0, 1):
            cell.textLabel?.text = "修改支付密码"
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let text = "如忘记以上两种密码，请联系客服028-8569-5623" as NSString
            
            let textView = UITextView(frame: CGRect(x: 0, y: 30, width: screenWidth, height: 50))
            textView.backgroundColor = UIColor.clear
            let attributedText = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
            guard let url = URL(string: "tel://028-85695623") else {return UIView()}
            attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSLinkAttributeName: url], range: text.range(of: "028-8569-5623"))
            
            textView.attributedText = attributedText
            textView.textAlignment = .center
            textView.dataDetectorTypes = .link
            
            textView.isEditable = false
            
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
            titleBg.addSubview(textView)
            return titleBg
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ResetPassword@CenterSettings", source: self, sender: nil)
        case (0, 1):
            AOLinkedStoryboardSegue.performWithIdentifier("PayCodeSetting@CenterSettings", source: self, sender: nil)
            
        default:
            break
        }
    }
    
}
