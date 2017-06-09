//
//  ChargePaymentSelectViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ChargePaymentSelectViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var agreementSelected: Bool = true
    
    var paymentType: PaymentType!
    var selectionCompletion: ((PaymentType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择支付方式"
        
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "BankAccountInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BankAccountInfoTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: - Private
    
    func resignTF() {
        self.view.endEditing(true)
    }
    
    // MARK: - Button Action
    
    @IBAction func confirmAction() {
        if paymentType == .bankCard {
            if !agreementSelected {
                Utility.showAlert(self, message: "未同意用户协议")
                return
            }
            if let selectionCompletion = selectionCompletion {
                    selectionCompletion(paymentType)
                _ = navigationController?.popViewController(animated: true)
            }
        } else if paymentType == .undefined {
            Utility.showAlert(self, message: "请选择支付方式")
        }
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: "https://www.windward.com.cn")
    }
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        agreementSelected = btn.isSelected
    }
}

extension ChargePaymentSelectViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankAccountInfoTableViewCell", for: indexPath)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let _cell = cell as? BankAccountInfoTableViewCell else {return}
            _cell.config("PlaceHolderMianyangBankLogo", bankName: "绵阳商业银行")
            _cell.cardNumber = "尾号"
            if let cardNumber = UserManager.sharedInstance.userInfo?.verificationInfo?.cardList.first?.cardNumber {
                if cardNumber.characters.count > 4 {
                    _cell.cardNumber = "尾号" + cardNumber.substring(from: cardNumber.characters.index(cardNumber.endIndex, offsetBy: -4))
                }
            }
            _cell.bankCardSelected = (paymentType == .bankCard)
            
        case (1, 0):
            cell.imageView?.image = UIImage(named: "PaymentIconAlipay")
            cell.textLabel?.text = "支付宝"
            if paymentType == .alipay {
                cell.accessoryView = UIImageView(image: UIImage(named: "CellItemCheckmarkOn"))
            } else {
                cell.accessoryView = nil
            }
        case (1, 1):
            cell.imageView?.image = UIImage(named: "PaymentIconWechat")
            cell.textLabel?.text = "微信支付"
            if paymentType == .wechat {
                cell.accessoryView = UIImageView(image: UIImage(named: "CellItemCheckmarkOn"))
            } else {
                cell.accessoryView = nil
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 65
        default:
            return 45
        }
    }
}

extension ChargePaymentSelectViewController: UITableViewDelegate {

    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            paymentType = .bankCard
        case (1, 0):
            paymentType = .alipay
        case (1, 1):
            paymentType = .wechat
        default:
            break
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else if section == 1 {
            return 30
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        } else if section == 1 {
            return CGFloat.leastNormalMagnitude
        }
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let titleLbl = UILabel(frame: CGRect(x: 15, y: 7, width: 200, height: 15))
            titleLbl.text = "银行卡支付"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        } else if section == 1 {
            let titleLbl = UILabel(frame: CGRect(x: 15, y: 7, width: 200, height: 15))
            titleLbl.text = "其他支付方式"
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.commonGrayTxtColor()
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
            titleBg.addSubview(titleLbl)
            return titleBg
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let agreementSelectedButton = UIButton(type: .custom)
            agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOff"), for: UIControlState())
            agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOn"), for: .selected)
            agreementSelectedButton.addTarget(self, action: #selector(self.selectAgreementAction(_:)), for: .touchUpInside)
            agreementSelectedButton.frame = CGRect(x: 0, y: 0, width: 44, height: 54)
            agreementSelectedButton.isSelected = agreementSelected
            
            let agreementDetailButton = UIButton(type: .custom)
            agreementDetailButton.frame = CGRect(x: 44, y: 8, width: 120, height: 40)
            agreementDetailButton.addTarget(self, action: #selector(self.showAgreementDetailAction(_:)), for: .touchUpInside)
            
            let text = "同意《用户协议》" as NSString
            
            let attrText = NSMutableAttributedString(string: text as String)
            attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.commonBlueColor(), range: NSRange(location: 0, length: text.length))
            attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#9498A9"), range: NSRange(location: 0, length: "同意".characters.count))
            attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: 0, length: text.length))
            agreementDetailButton.setAttributedTitle(attrText, for: UIControlState())
            
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 54))
            titleBg.addSubview(agreementSelectedButton)
            titleBg.addSubview(agreementDetailButton)
            return titleBg
            
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
}
