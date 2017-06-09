//
//  WantCollectViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/13.
//  Copyright © 2016年 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
import ObjectMapper

class WantCollectViewController: BaseTableViewController {
    var isQRDismiss: Bool = false
    fileprivate var dataArray: [PrivilegeRuleInfo] = []
    fileprivate var ruleChooseView = RuleChooseView()
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var chooseActiveButton: UIButton!
    @IBOutlet weak var totlaMoneyTextField: UITextField!
    @IBOutlet weak var noPrivilegeMoneyTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var disocountLabel: UILabel!
    @IBOutlet weak var topPrivileteLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var privilegeMoneyLabel: UILabel!
    @IBOutlet weak var actualPayMoneyLabel: UILabel!
    @IBOutlet weak var privileteLabel: UILabel!
    @IBOutlet weak var topPrivilegeLabelRightConstraint: NSLayoutConstraint!
    fileprivate lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.frame = UIScreen.main.bounds
        coverView.backgroundColor = UIColor.black
        coverView.alpha = 0.6
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dissmissRuleChooseView))
        coverView.addGestureRecognizer(tap)
        return coverView
    }()
    
    var privileteRuleInfo: PrivilegeRuleInfo?
    var isUsePrivilete: PrivileteType = .notChoose
    var qrCodeCoverView = QrCodeCoverView()
    var isExpand = false
    var seletedId = 0
    var qrCodeInfo: PrivilegeCreateInfo?
    var cellHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setImageViewTap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utility.showMBProgressHUDWithTxt()
        isQRDismiss = false
        requestData(0)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        dissmissRuleChooseView()
        qrCodeCoverView.dissmiss()
    }
    @IBAction func chooseRuleHandle(_ sender: AnyObject) {
        chooseActiveHandle(UIButton())
        view.endEditing(true)
    }
    @IBAction func preferentialChoiceHandle(_ sender: AnyObject) {
        chooseActiveHandle(UIButton())
        view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension WantCollectViewController {
    func setupUI() {
        title = "我要收单"
        
        totlaMoneyTextField.addTarget(self, action: #selector(self.updateTextFiedlText), for: .editingChanged)
         noPrivilegeMoneyTextField.addTarget(self, action: #selector(self.updateTextFiedlText), for: .editingChanged)
        tableView.tableFooterView = UIView()
        if iphone6P {
              expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: screenWidth-80, bottom: 0, right: 0)
        } else if iphone6 {
            expandButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: screenWidth-40, bottom: 0, right: 0)
        }
    }
    
    func setImageViewTap() {
        iconImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.chooseActiveHandle(_:)))
        iconImageView.addGestureRecognizer(tap)
    }
    
    func setPrivilegeUI(_ privileteRuleInfo: PrivilegeRuleInfo) {
        self.nameLabel.text = privileteRuleInfo.privilegeName
        self.ruleLabel.text = privileteRuleInfo.rule
        if privileteRuleInfo.topPrivilege.isEmpty {
            self.topPrivileteLabel.text = ""
        } else {
            self.topPrivileteLabel.text = "优惠限额: 最高减"+"\(String.cutDecimalCharater(privileteRuleInfo.topPrivilege))" + "元"
        }
        if privileteRuleInfo.type == "2" {
            let text = "满"+"\(String.cutDecimalCharater(privileteRuleInfo.fullSum))"+"减"+"\(String.cutDecimalCharater(privileteRuleInfo.minusSum))"
            self.disocountLabel.attributedText = returnAttbutedText(text)
            self.markButton.setTitle("满减", for: .normal)
        } else {
            self.disocountLabel.attributedText = String.getAttString(privileteRuleInfo.discount)
            self.markButton.setTitle("折扣", for: .normal)
        }
    }
    
    func returnAttbutedText(_ str: String) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: str)
        let rangeMan = (str as NSString).range(of: "满")
        let rangeJian = (str as NSString).range(of: "减")
        let rangeAll = (str as NSString).range(of: str)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 25), range: rangeAll)
        attString.addAttribute(NSBaselineOffsetAttributeName, value: 1, range: rangeJian)
        attString.addAttribute(NSBaselineOffsetAttributeName, value: 1, range: rangeMan)
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: 1))
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 17), range: rangeJian)
        return attString
    }
}

extension WantCollectViewController {
    // 请求数据
    func requestData(_ type: Int) {
        let params: [String: AnyObject] = ["type": type as AnyObject]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.privilegeRuleList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                Utility.hideMBProgressHUD()
                guard let tempArray = result["rule_list"] as? [AnyObject] else {return}
                self.dataArray = tempArray.flatMap({PrivilegeRuleInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
}

extension WantCollectViewController {
    
    @IBAction func expandButtonHandle(_ sender: AnyObject) {
        if isExpand == false {
            UIView.animate(withDuration: 0.5, animations: {
                self.expandButton.setImage(UIImage(named: "btn_activity2"), for: UIControlState())
            })
            guard let text = self.ruleLabel.text else {return}
            self.cellHeight = String.getLabHeigh(text, font: UIFont.systemFont(ofSize: 15), width: 190)
            ruleLabel.numberOfLines = 0
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.expandButton.setImage(UIImage(named: "btn_activity"), for: .normal)
            })
            ruleLabel.numberOfLines = 1
        }
        tableView.reloadData()
        isExpand = !isExpand
    }
    
    // 折扣
    func updateTextFiedlText(_ textField: UITextField) {
        let totlaText = totlaMoneyTextField.text ?? ""
        let total = Double(totlaText) ?? 0.0
        let noPriText = noPrivilegeMoneyTextField.text ?? ""
        let noPrivilete = Double(noPriText) ?? 0.0
        
        if textField == totlaMoneyTextField {
            textField.text = (textField.text ?? "").keepTwoPlacesDecimal()
        }
        if textField == noPrivilegeMoneyTextField {
            textField.text = (textField.text ?? "").keepTwoPlacesDecimal()
        }
        
        guard let disountText = privileteRuleInfo?.discount else {
            privilegeMoneyLabel.text = String(format: "%.2f", total - total)
            actualPayMoneyLabel.text = String(format: "%.2f", total)
            return
        }
        guard let fullText = privileteRuleInfo?.fullSum else {
            privilegeMoneyLabel.text = String(format: "%.2f", total - total)
            actualPayMoneyLabel.text = String(format: "%.2f", total)
            return
        }
        guard let minusText = privileteRuleInfo?.minusSum else {return}
        guard let topPriText = privileteRuleInfo?.topPrivilege else {return}
        guard let discount = Double(disountText) else {return}
        guard let full = Double(fullText) else {return}
        guard let minus = Double(minusText) else {return}
        guard let topPri = Double(topPriText) else {return}
        
        if privileteRuleInfo?.type == "2" {
            let calculationPrivilete = (floor((total - noPrivilete)/full))*minus

            if calculationPrivilete >= topPri {
                
                privilegeMoneyLabel.text = String(format: "%.2f", topPri)
                actualPayMoneyLabel.text = String(format: "%.2f", total - topPri)
            } else {
                privilegeMoneyLabel.text = String(format: "%.2f", calculationPrivilete)
                actualPayMoneyLabel.text = String(format: "%.2f", total - calculationPrivilete)
            }
        } else {
            let calculationPrivilete = (total - noPrivilete)*(1-discount*0.1)
            if calculationPrivilete >= topPri {
                privilegeMoneyLabel.text = String(format: "%.2f", topPri)
                actualPayMoneyLabel.text = String(format: "%.2f", total - topPri)
            } else {
                privilegeMoneyLabel.text = String(format: "%.2f", calculationPrivilete)
                actualPayMoneyLabel.text = String(format: "%.2f", total - calculationPrivilete)

            }
        }
    }
    
    @IBAction func createQRCodeHandle(_ sender: AnyObject) {
        view.endEditing(true)
        guard let total = self.totlaMoneyTextField.text else {
            Utility.showAlert(self, message: "消费总额不能为空")
            return
        }
        guard let _ = Float(total) else {
            Utility.showAlert(self, message: "请填写正确的消费总额")
            return
        }
        if isUsePrivilete == .notChoose {
            Utility.showAlert(self, message: "请选择优惠方式")
            return
        }
        
        if var outSum = noPrivilegeMoneyTextField.text {

            if outSum.characters.isEmpty {
                outSum = "0"
            }
            var params: [String: AnyObject] = [:]
            if let privileteRuleInfo = self.privileteRuleInfo {
                params["total"] = total as AnyObject?
                params["privilege_id"] = privileteRuleInfo.privilegeId as AnyObject?
                params["out_sum"] = outSum as AnyObject?
            } else {
                params["total"] = total as AnyObject?
                params["out_sum"] = outSum as AnyObject?
            }
            
            let aesKey = AFMRequest.randomStringWithLength16()
            let aesIV = AFMRequest.randomStringWithLength16()
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(AFMRequest.privilegeCreate(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
                if let result = object as? [String: AnyObject] {
                    guard let codeInfo = Mapper<PrivilegeCreateInfo>().map(JSON: result) else {return}
                    Utility.hideMBProgressHUD()
                    guard let qrCoverView = Bundle.main.loadNibNamed("QrCodeCoverView", owner: nil, options: nil)?.first as? QrCodeCoverView else {return}
                    qrCoverView.frame = UIScreen.main.bounds
                    qrCoverView.createQrCode(codeInfo.code)
                    qrCoverView.closeBlock = {
                        self.isQRDismiss = true
                    }
                    self.qrCodeCoverView = qrCoverView
                    self.navigationController?.view.addSubview(qrCoverView)
                } else {
                    Utility.hideMBProgressHUD()
                    if let msg = error?.userInfo["message"] as? String {
                        Utility.showAlert(self, message: msg)
                    }
                }
            }
        }
    }
    
    @IBAction func chooseActiveHandle(_ sender: AnyObject) {
        guard let ruleChooseView = Bundle.main.loadNibNamed("RuleChooseView", owner: nil, options: nil)?.first as? RuleChooseView else {return}
        ruleChooseView.selectedPriveilegeRuleInfo = self.privileteRuleInfo
        if dataArray.count <= 2 {
            ruleChooseView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: CGFloat(dataArray.count*120+103))
        } else {
            ruleChooseView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 420)
        }
        
        self.navigationController?.view.addSubview(coverView)
        self.navigationController?.view.addSubview(ruleChooseView)
        UIView.animate(withDuration: 0.25, animations: {
            ruleChooseView.y = screenHeight - ruleChooseView.height
        }) 
        // 取消
        ruleChooseView.cancelBlock = {
            self.dissmissRuleChooseView()
        }
        
        // 确定
        ruleChooseView.confirmBlock = { (privileteRuleInfo, usePrivilete) in
//            self.noPrivilegeMoneyTextField.becomeFirstResponder()
            if self.noPrivilegeMoneyTextField.text == "" {
                self.noPrivilegeMoneyTextField.text = "0"
            }
            if usePrivilete == false {
            self.privileteRuleInfo = privileteRuleInfo
            guard let info = privileteRuleInfo else {
                    Utility.showAlert(self, message: "请选择优惠方式")
                    return
                }
                self.setPrivilegeUI(info)
                self.isUsePrivilete = .usePrivilete
                } else {
                self.privileteRuleInfo = nil
                self.isUsePrivilete = .notPrivilete
                self.privileteLabel.text = "不使用优惠卷"
            }
            self.dissmissRuleChooseView()
            self.updateTextFiedlText(UITextField())
            self.tableView.reloadData()
        }
        
        ruleChooseView.dataArray = self.dataArray
        self.ruleChooseView = ruleChooseView
    }
    
    func dissmissRuleChooseView() {
        self.coverView.removeFromSuperview()
        UIView.animate(withDuration: 0.25, animations: {
            self.ruleChooseView.y = screenHeight
        })
    }

}

extension WantCollectViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 || indexPath.section == 1 {
           view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 && indexPath.section == 1 && isUsePrivilete == .notChoose {
            return 0
        }
        if indexPath.row == 1 && indexPath.section == 1 && isUsePrivilete == .notPrivilete {
            return 0
        }
        
        if indexPath.row == 0 && indexPath.section == 1 && isUsePrivilete == .notPrivilete {
            return 44
        }
        if indexPath.row == 0 && indexPath.section == 1 && isUsePrivilete == .usePrivilete {
            return 0
        }
        if indexPath.row == 1 && indexPath.section == 1 && isUsePrivilete == .usePrivilete {
            if isExpand == true {
                if cellHeight > 18 {
                    return 85 + cellHeight + 15.5
                } else {
                    return 120
                }
            } else {
                return 120
            }
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 1
        } else {
            return 10
        }
        
    }
}
