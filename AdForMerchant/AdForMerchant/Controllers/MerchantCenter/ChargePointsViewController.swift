//
//  ChargePointsViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/23/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit

class ChargePointsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    var securityPasswdTF: UITextField?
    
    fileprivate var agreementSelected: Bool = true
    
    var securityPasswd: String = ""
    var amount: Int = 0
    var money = 0.0
    var paymentSelection: PaymentType = .undefined
    var point = ""
    var payResult: (status: Bool, cardInfo: String, point: String, amount: String, tips: String) = (false, "", "", "", "")
    var pointResultInfo: RedeemPointInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "充值积分"
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "PayTextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "PayTextFieldTableViewCell")
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.resignTF))
        tableView.addGestureRecognizer(touch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        tableView.reloadData()
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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ChargePaymentSelect@MerchantCenter" {
//            guard let vc = segue.destination as? ChargePaymentSelectViewController else {return}
//            vc.selectionCompletion = { payment in
//                self.paymentSelection = payment
//            }
//            vc.paymentType = self.paymentSelection
//        } else if segue.identifier == "ChargeDetail@MerchantCenter" {
//            guard let vc = segue.destination as? ChargeDetailViewController else {return}
//            vc.tips = payResult.tips
//            vc.bankCardInfo = payResult.cardInfo
//            vc.point = payResult.point
//            vc.amount = "￥" + payResult.amount
//            vc.isSucceed = payResult.status
//        }
//    }
    
    // MARK: - Private
    func resignTF() {
        self.view.endEditing(true)
    }

    // MARK : - Http request
    
    func requestChargeByBankCard() {
        let parameters: [String: AnyObject] = [
            "point": amount as AnyObject,
            "pay_password": securityPasswd as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.pointRechargeByCard(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: String] else {return}
                if let status = result["recharge_status"] {
                    let tips = result["tips"] ?? ""
                    let bankName = result["bank_name"] ?? ""
                    let cardNumber = result["card_no_tail"] ?? ""
                    let point = result["point"] ?? ""
                    let amount = result["money"] ?? ""
                    
                    self.payResult.cardInfo = String(format: "%@(%@)", bankName, cardNumber)
                    self.payResult.point = point
                    self.payResult.amount = amount
                    self.payResult.tips = tips
                    if status == "1" {
                        self.payResult.status = true
                    }
                    AOLinkedStoryboardSegue.performWithIdentifier("ChargeDetail@MerchantCenter", source: self, sender: nil)
                }
            } else {
                
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    // MARK: - Button Action
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        agreementSelected = btn.isSelected
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {return}
        helpWebVC.requestURL = WebviewAgreementTag.pointRecharge.detailUrl
        helpWebVC.title = "积分充值协议"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }

    func validateChargePoints() -> Bool {
        if amount <= 0 {
            Utility.showAlert(self, message: "请输入充值积分数")
            return false
        }
        return true
    }
    
    // 立即支付
    @IBAction func commitAction() {
        if !validateChargePoints() {
            return
        }
        
        if !agreementSelected {
            Utility.showAlert(self, message: "请同意积分充值协议")
            return
        }
        guard let vc = UIStoryboard(name: "VerifyPayPass", bundle: nil).instantiateInitialViewController() as? VerifypasswordViewController else {return}
        vc.point = point
        vc.type = .rechargePoint
        vc.resultHandle = { [weak self] (result, data) in
            switch result {
            case .passed:
                self?.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
                self?.showPaySuccess()
                kApp.requestUserInfoWithCompleteBlock({ _ in
                    self?.tableView.reloadData()
                }, failedBlock: nil)
            case .canceled:
                self?.dim(.out, coverNavigationBar: true)
                vc.dismiss(animated: true, completion: nil)
            default: break
            }
        }
        vc.resultBlock = { info in
            self.pointResultInfo = info
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    /// 支付成功弹框
    fileprivate func showPaySuccess() {
        guard let vc = UIStoryboard(name: "VerifyPayPass", bundle: nil).instantiateViewController(withIdentifier: "PaySuccessViewController") as? PaySuccessViewController else {return}
        vc.dismissHandleBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            return
        }
        vc.timeEndBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            guard let detailVc = AOLinkedStoryboardSegue.sceneNamed("ChargeDetail@MerchantCenter") as? ChargeDetailViewController else {return}
            guard let info = self.pointResultInfo else {return}
            detailVc.tips = info.tips 
            detailVc.bankCardInfo = "\(info.bankName)"+"("+"\(info.cardNoTail)"+")"
            detailVc.point = info.point 
            detailVc.amount = "￥" + info.money
//            detailVc.isSucceed = payResult.status
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ChargePointsViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        case (0, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayTextFieldTableViewCell", for: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let userPoint = Int(UserManager.sharedInstance.userInfo?.point ?? "0") else {return}
            guard let _cell = cell as? DefaultTxtTableViewCell else {return}
            _cell.leftTxtLabel.text = "当前积分"
            _cell.rightTxtLabel.text = "\(userPoint)"
            _cell.accessoryType = .none
        case (0, 1):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "积分"
            _cell.txtFieldEnabled = true
            _cell.rightTxtField.placeholder = "请输入充值数量"
            _cell.maxCharacterCount = 10
            if amount == 0 {
                _cell.rightTxtField.text = ""
            } else {
                _cell.rightTxtField.text = "\(amount)"
            }
            _cell.rightTxtField.keyboardType = .numberPad
            
            _cell.endEditingBlock = { textField in
                if let text = textField.text {
                    self.amount = Int(text) ?? 0
                } else {
                    self.amount = 0
                }
            }
            _cell.changeEditingBlock = { text in
                self.point = text
                self.money = (Double(text) ?? 0.0) / 100.0
                let index = NSIndexPath(row: 2, section: 0)
                self.tableView.reloadRows(at: [index as IndexPath], with: .none)
            }
        case (0, 2):
            guard let _cell = cell as? PayTextFieldTableViewCell else {return}
            _cell.moneyLabel.text = "\(money)"
            _cell.accessoryType = .none
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        default:
            return 45
        }
    }
    
}

extension ChargePointsViewController: UITableViewDelegate {
    
    // MARK: - Table view delegate    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 84
        }
        return 1
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
            agreementDetailButton.frame = CGRect(x: 44, y: 8, width: 150, height: 40)
            agreementDetailButton.addTarget(self, action: #selector(self.showAgreementDetailAction(_:)), for: .touchUpInside)
            
            let text = "同意《积分充值协议》" as NSString
            
            let attrText = NSMutableAttributedString(string: text as String)
            attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.commonBlueColor(), range: NSRange(location: 0, length: text.length))
            attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#9498A9"), range: NSRange(location: 0, length: "同意".characters.count))
            attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: 0, length: text.length))
            agreementDetailButton.setAttributedTitle(attrText, for: UIControlState())
            
            let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 84))
            titleBg.addSubview(agreementSelectedButton)
            titleBg.addSubview(agreementDetailButton)
            return titleBg
        }
        
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
}
