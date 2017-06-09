//
//  MerchantCenterVerificationViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/22/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable empty_count
// swiftlint:disable force_unwrapping

import UIKit
import AVFoundation

class MerchantCenterVerificationViewController: BaseViewController {
    var ispuhed: Bool = false
    @IBOutlet fileprivate weak var tbvLeadingCons: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tbvWidthCont: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableView2: UITableView!
    @IBOutlet fileprivate weak var tableView3: UITableView!
    @IBOutlet fileprivate weak var tableView4: UITableView!
    
    @IBOutlet fileprivate weak var stepViewBg: UIView!
    fileprivate var stepPageCtrl: StepPageControl!
    
    @IBOutlet fileprivate weak var goNextStepView: GoNextStepView!
    var payCodeSetted: Bool = false
    var changHeight: CGFloat = 80
    var omitTextViewString = ""
    var originalTextViewString = ""
    var verificationInfo: VerificationInfo?
    var bankInfo: BankAccountInfo?
    var agreementSelected: Bool = true
    var textField1 = UITextField()
    var textField2 = UITextField()
    
    var payPasswdTF: UITextField?
    
    var star1: UILabel?
    var star2: UILabel?
    var star3: UILabel?
    var star4: UILabel?
    var star5: UILabel?
    var star6: UILabel?
    
    var payPasswd: String = ""
    var timer = Timer()
   fileprivate var captchaAlert: CustomIOSAlertView?
   fileprivate var captchaImgView: UIImageView?
   fileprivate var captchaCodeTF: UITextField?
   fileprivate var captchaCode: String?
    fileprivate var captchaImg: UIImage? {
        didSet {
            captchaImgView?.image = captchaImg
        }
    }
    fileprivate var isSHowMessageCode: Bool = false
    fileprivate var captchaButton: UIButton!
    fileprivate var activateCaptchaCount: Int = 0
    //image Data
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商户认证"
        
        let leftBarItem = UIBarButtonItem(title:"取消", style: .plain, target: self, action: #selector(self.backAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
        navigationItem.rightBarButtonItem = rightBarItem
        
        goNextStepView.delegate = self
        
        stepPageCtrl = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        stepPageCtrl.stepTitleArray = ["公司信息", "基础资质", "行业资质", "银行卡"]
        stepViewBg.addSubview(stepPageCtrl)
        for table in [tableView, tableView2, tableView3, tableView4] {
            table?.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
            table?.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
            table?.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
            table?.register(UINib(nibName: "VerifiCodeCell", bundle: nil), forCellReuseIdentifier: "VerifiCodeCell")
            
            table?.backgroundColor = UIColor.commonBgColor()
            table?.keyboardDismissMode = .onDrag
        }
        
        if let vInfo = UserManager.sharedInstance.userInfo?.verificationInfo {
            verificationInfo = vInfo
            bankInfo = vInfo.cardList.first
        } else {
            verificationInfo = VerificationInfo(JSON: [:])
        }
        if bankInfo == nil {
            bankInfo = BankAccountInfo()
        }
        
        changePageStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.passwordDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notifi:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notifi:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notifi: NSNotification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        if textField1.isFirstResponder || textField2.isFirstResponder {           
            } else {
            UIView.animate(withDuration: duration) { () -> Void in
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+140, right: 0)
                self.tableView.setContentOffset(CGPoint(x: 0, y:150), animated: true)
                self.view.layoutIfNeeded()
            }
        }

    }
    
    func keyboardWillHide(notifi: NSNotification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration) { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()

        }
    }
    
    func hideMBProgressHUD() {
        Utility.hideMBProgressHUD()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        tbvWidthCont.constant = self.view.frame.size.width
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            if let url = sender as? String {
                destVC.requestURL = url
            }
            destVC.title = "行业资质说明"
        }
    }
    
    // MARK: - Private
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {return}
        helpWebVC.requestURL = WebviewHelpDetailTag.merchantVerificationNav.detailUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func moveToPageIndex(_ pageIndex: Int) {
        let width: CGFloat = self.view.frame.size.width
        
        if pageIndex != self.currentPage {
            if pageIndex > 3 || pageIndex < 0 {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.tbvLeadingCons.constant = -CGFloat(self.currentPage) * width
                    self.view.layoutIfNeeded()
                })
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tbvLeadingCons.constant = -CGFloat(pageIndex) * width
                self.view.layoutIfNeeded()
                self.currentPage = pageIndex
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tbvLeadingCons.constant = -CGFloat(self.currentPage) * width
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func changePageStyle() {
        stepPageCtrl.selectSubVeiwByIndex(currentPage)
        switch currentPage {
        case 0:
            navigationItem.title = "公司信息"
            goNextStepView.nextStepButtonTitle = "下一步"
            goNextStepView.animateOnlyNextStep = true
        case 1:
            navigationItem.title = "基础资质"
            goNextStepView.nextStepButtonTitle = "下一步"
            goNextStepView.animateOnlyNextStep = false
        case 2:
            navigationItem.title = "行业资质"
            goNextStepView.nextStepButtonTitle = "下一步"
            goNextStepView.animateOnlyNextStep = false
        case 3:
            navigationItem.title = "银行卡"
            goNextStepView.nextStepButtonTitle = "确认提交"
            goNextStepView.animateOnlyNextStep = false
        default:
            break
        }
    }
    
    func validateInputValue() -> Bool {
        
        guard let verificationInfo = self.verificationInfo else {return false}
        guard let bankInfo = self.bankInfo else {return false}
        switch currentPage {
        case 0:
            if verificationInfo.companyName.isEmpty {
                Utility.showAlert(self, message: "请输入公司注册名")
                return false
            }
            if verificationInfo.legelPerson.isEmpty {
                Utility.showAlert(self, message: "请输入法人姓名")
                return false
            }
            if !Utility.isValidLegalPersonName(verificationInfo.legelPerson) {
                Utility.showAlert(self, message: "请输入正确的法人姓名")
                return false
            }
            if !Utility.isValidateIDNumber(verificationInfo.idNumber) {
                if verificationInfo.idNumber.characters.count < 18 {
                    Utility.showAlert(self, message: "请输入正确的法人身份证号")
                } else {
                    Utility.showAlert(self, message: "请输入法人身份证号")
                }
                return false
            }
            if verificationInfo.regCode.isEmpty {
                Utility.showAlert(self, message: "请输入工商注册号")
                return false
            }
            if !Utility.isValidLegalCode(verificationInfo.regCode) {
                Utility.showAlert(self, message: "请输入正确的工商注册号")
                return false
            }
            if verificationInfo.regAddress.isEmpty {
                Utility.showAlert(self, message: "请输入工商注册地址")
                return false
            }
        case 1:
            
            if verificationInfo.license.isEmpty {
                Utility.showAlert(self, message: "请上传基础资质")
                return false
            }
        case 2:
            break
        case 3:
            if bankInfo.holderName.isEmpty {
                Utility.showAlert(self, message: "请输入开户名称")
                return false
            }
            if bankInfo.cardNumber.isEmpty {
                Utility.showAlert(self, message: "请输入银行账号")
                return false
            }
            if !Utility.isValidBankCardNumber(bankInfo.cardNumber) {
                Utility.showAlert(self, message: "请输入正确的银行账号")
                return false
            }
            if bankInfo.mobile.isEmpty {
                Utility.showAlert(self, message: "请输入手机号码")
                return false
            }
            if !Utility.isValidateMobile(bankInfo.mobile) {
                Utility.showAlert(self, message: "请输入正确的手机号码")
                return false
            }
            if verificationInfo.verifyCode.isEmpty || verificationInfo.verifyCode.characters.count != 6 {
                Utility.showAlert(self, message: "请输入六位验证码")
                return false
            }
            if !agreementSelected {
                Utility.showAlert(self, message: "请同意绑定银行卡协议")
                return false
            }
        default:
            break
        }
        return true
    }
    
    var currentPage: Int = 0 {
        didSet {
            changePageStyle()
            moveToPageIndex(self.currentPage)
        }
    }
    
    func backAction() {
    
        Utility.showConfirmAlert(self, message: "确认取消商户认证？", confirmCompletion: {
            if self.ispuhed {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.dismiss(animated: true, completion: {})
            }
        })
    }
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        agreementSelected = btn.isSelected
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: WebviewAgreementTag.bankCard.detailUrl)
    }
    
    // MARK: - Http request
    
    func validateIdNumber() {
        guard let number = verificationInfo?.idNumber else {return}
        let parameters: [String: Any] = [
            "id_number": number
            ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCheckIdNumber(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                self.currentPage += 1
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestVerifyLicense() {
        
        guard var cardInfo = bankInfo?.toJSON() else {return}
        guard let verificationInfo = verificationInfo else {return}
        cardInfo.removeValue(forKey: "card_id")
        if let bankName = cardInfo["bank_name"] as? String, bankName.isEmpty {
            cardInfo["bank_name"] = "绵阳商业银行"
        }
        
        var parameters: [String: Any] = [
            "company_name": verificationInfo.companyName,
            "legel_person": verificationInfo.legelPerson,
            "id_number": verificationInfo.idNumber,
            "reg_code": verificationInfo.regCode,
            "reg_address": verificationInfo.regAddress,
            "license": verificationInfo.license,
            "qualification": verificationInfo.credentialImgs,
            "card": cardInfo,
            "verify_code": verificationInfo.verifyCode, 
            "pay_password": payPasswd

        ]
        parameters["step"] = self.currentPage + 1
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantCertify(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                if self.currentPage == 3 {
                    guard let result = object as? [String: Any] else {return}
                    if let tips = result["tips"] as? String {
                        Utility.showAlert(self, message: tips, dismissCompletion: {
                            self.tableView.isHidden = true
                            self.tableView2.isHidden = true
                            self.tableView3.isHidden = true
                            guard let navigationController = self.navigationController else {return}
                            if let _ = navigationController.presentingViewController as? TabBarController, !self.payCodeSetted {
                         AOLinkedStoryboardSegue.performWithIdentifier("VerificationStatus@MerchantCenter", source: self, sender: nil)
                                
                            } else {
                                self.navigationController?.dismiss(animated: true, completion: nil)
                            }
                            
                        })
                    }
                } else {
                    self.currentPage += 1
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
    
    // Mark: - Pay Code View
    
    func showSettingPayCodeDialogView() {
        
        Utility.showConfirmAlert(self, title: "温馨提示", cancelButtonTitle: "取消", confirmButtonTitle: "去设置", message: "提交认证信息，需输入支付密码", cancelCompletion: {
            }, confirmCompletion: {
                self.showPayCodeView()
        })
    }
    
    func showPayCodeView() {
        self.payPasswd = ""
        isSHowMessageCode  = false
        let codeAlertView = CustomIOSAlertView()
        codeAlertView?.containerView = payCodeView()
        codeAlertView?.delegate = self
        codeAlertView?.buttonTitles = ["取消", "确定"]
        codeAlertView?.useMotionEffects = true
        codeAlertView?.show()
        
    }
    
    func payCodeView() -> UIView {
        
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 120))//30+20+60
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 20, width: titilWidth, height: 20))
        titleLabel.text = "设置支付密码"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeView.addSubview(titleLabel)
        
        let codeTfd = UITextField(frame:CGRect(x: 20, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 20, width: viewWidth - 40, height: 40))
        codeTfd.borderStyle = UITextBorderStyle.none
        codeTfd.placeholder = "密码"
        codeTfd.isSecureTextEntry = true
        codeTfd.borderStyle = UITextBorderStyle.roundedRect
        codeTfd.keyboardType = UIKeyboardType.numberPad
        codeView.addSubview(codeTfd)
        payPasswdTF = codeTfd
        guard let payPasswdTF = payPasswdTF else {return UIView()}
        payPasswdTF.becomeFirstResponder()
        
        let starBgView = UIView(frame:codeTfd.frame)
        starBgView.backgroundColor = UIColor.white
        starBgView.layer.cornerRadius = 8.0
        starBgView.layer.masksToBounds = true
        starBgView.layer.borderColor = UIColor.colorWithHex("666666").cgColor
        starBgView.layer.borderWidth = 1.0
        codeView.addSubview(starBgView)
        
        for i in 0 ..< 6 {
            let boxView = UIView(frame:CGRect(x: codeTfd.frame.size.width / 6 * CGFloat(i), y: 0, width: codeTfd.frame.size.width / 6 + 1, height: codeTfd.frame.size.height))
            boxView.layer.borderColor = UIColor.colorWithHex("666666").cgColor
            boxView.layer.borderWidth = 1.0
            starBgView.addSubview(boxView)
            let starLbl = UILabel(frame:boxView.bounds)
            starLbl.textAlignment = NSTextAlignment.center
            starLbl.backgroundColor = UIColor.clear
            starLbl.isHidden = true
            starLbl.text = "*"
            switch i {
            case 0:
                star1 = starLbl
            case 1:
                star2 = starLbl
            case 2:
                star3 = starLbl
            case 3:
                star4 = starLbl
            case 4:
                star5 = starLbl
            case 5:
                star6 = starLbl
            default:
                break
            }
            boxView.addSubview(starLbl)
        }
        
        return codeView
    }
    
    // MARK: - Password methods
    func passwordDidChange(_ noti: Notification ) {
        
        if let _ = payPasswdTF {
            self.changePasswordStar()
            guard let payPasswdTF = payPasswdTF else {return}
            if let pwd = payPasswdTF.text {
                if pwd.characters.count < 6 {
                } else if pwd.characters.count == 6 {
                    payPasswdTF.resignFirstResponder()
                } else {
                    payPasswdTF.text = pwd.substring(to: pwd.characters.index(pwd.startIndex, offsetBy: 6))
                    payPasswdTF.resignFirstResponder()
                }
            }
        }
    }
    
    func changePasswordStar() {
        guard let payPasswdTF = payPasswdTF else {return}
        if let pwd = payPasswdTF.text {
            let textLength = min(pwd.characters.count, 6)
            guard let star1 = star1 else {return}
            guard let star2 = star2 else {return}
            guard let star3 = star3 else {return}
            guard let star4 = star4 else {return}
            guard let star5 = star5 else {return}
            guard let star6 = star6 else {return}
            star1.isHidden = true
            star2.isHidden = true
            star3.isHidden = true
            star4.isHidden = true
            star5.isHidden = true
            star6.isHidden = true
            
            switch textLength {
            case 6:
                star6.isHidden = false
                fallthrough
            case 5:
                star5.isHidden = false
                fallthrough
            case 4:
                star4.isHidden = false
                fallthrough
            case 3:
                star3.isHidden = false
                fallthrough
            case 2:
                star2.isHidden = false
                fallthrough
            case 1:
                star1.isHidden = false
            default:
                break
            }
        }
    }
}

// MARK: - Custom iOS Alert view delegate
extension MerchantCenterVerificationViewController: CustomIOSAlertViewDelegate {
    public func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
        guard let alertView = alertView as? CustomIOSAlertView else {return}
        switch buttonIndex {
        case 0:
            alertView.close()
        case 1:
            if isSHowMessageCode {
                inputImageCode(alertView: alertView)
            } else {
                validPayCode(alertView: alertView)
            }
        default:
            break
        }
    }
    
    private func validPayCode(alertView: CustomIOSAlertView) {
        if let pwd = payPasswdTF?.text {
            payPasswd = pwd
        } else {
            payPasswd = ""
        }
        if payPasswd.characters.count > 6 {
            payPasswdTF?.text = ""
            payPasswd = ""
            changePasswordStar()
        } else if payPasswd.characters.count == 6 {
            alertView.close()
            requestVerifyLicense()
        } else {
            
        }
    }
}

// MARK: - Go Next Or Previous Step
extension MerchantCenterVerificationViewController: GoNextOrPreviousStep {
    func goNextOrPrevious(next: Bool) {
        if next {
            if currentPage == 0 {
                guard validateInputValue() else {
                    return
                }
//                validateIdNumber()
                requestVerifyLicense()
            } else if currentPage < 3 {
                guard validateInputValue() else {
                    return
                }
//                currentPage += 1
                
                requestVerifyLicense()
            } else {
                guard validateInputValue() else {
                    return
                }
                if payCodeSetted {
                    requestVerifyLicense()
                } else {
                    showSettingPayCodeDialogView()
                }
            }
        } else {
            if currentPage == 0 {
                navigationController?.dismiss(animated: true, completion: {
                })
            } else {
                currentPage -= 1
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MerchantCenterVerificationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case self.tableView:
            return 1
        case self.tableView2:
            return 1
        case self.tableView3:
            return 1
        case self.tableView4:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView, section) {
        case (self.tableView, 0):
            return 6
        case (tableView4, _):
            return 5
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView, indexPath.section, indexPath.row) {
        case (self.tableView, 0, 4):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtViewTableViewCell", for: indexPath) as? RightTxtViewTableViewCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView, 0, 5):
             let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultcell")
             
//            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView, 0, _):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath) as? RightTxtFieldTableViewCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView2, 0, _):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath) as? ProductDetailPhotoTableViewCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView3, 0, _):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath) as? ProductDetailPhotoTableViewCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView4, 0, 0), (self.tableView4, 0, 1), (self.tableView4, 0, 2), (self.tableView4, 0, 4):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath) as? RightTxtFieldTableViewCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        case (self.tableView4, 0, 3):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VerifiCodeCell", for: indexPath) as? VerifiCodeCell else {return UITableViewCell()}
            cell.sourceIsAllowEdit = true
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath) as? DefaultTxtTableViewCell else {return UITableViewCell()}
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension MerchantCenterVerificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            if section == 0 {
                return 35
            }
        } else if tableView == self.tableView2 {
            if section == 0 {
                return 75
            }
        } else if tableView == self.tableView3 {
            if section == 0 {
                return 75
            }
        } else if tableView == self.tableView4 {
            if section == 0 {
                return 200
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (tableView, indexPath.section, indexPath.row) {
        case (self.tableView, 0, 4):
            return changHeight
        case (self.tableView, 0, 5):
            return 0
        case (tableView2, 0, _):
            return 135
        case (tableView3, 0, _):
            return 135
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 0 {
                let label = UILabel()
                label.x = 10
                label.y = 0
                label.height = 35
                label.width = screenWidth - 20
                label.numberOfLines = 0
                let attrTxt = NSAttributedString(string: "认证一旦通过不可修改，请仔细核对信息是否正确", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
                label.attributedText = attrTxt
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(label)
                return titleBg
            }
        } else if tableView == self.tableView2 {
            
            if section == 0 {
                let text = "请上传三证合一的营业执照，若您不是三证合一商户，请上传至少以下三样基础资质：营业执照副本、企业税务登记证扫描件、组织机构代码证" as NSString
                
                let textView = UITextView(frame: CGRect(x: 8, y: 0, width: screenWidth - 8 * 2, height: 75))
                textView.backgroundColor = UIColor.clear
                let attributedText = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
                
                textView.attributedText = attributedText
                
                textView.isEditable = false
                textView.delegate = self
                
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 75))
                titleBg.addSubview(textView)
                return titleBg
            }
        } else if tableView == self.tableView3 {
            
            if section == 0 {
                let text = "说明：\n请根据《行业资质说明》上传您店铺经营所需要的行业资质或其他资质，若无需行业资质，可继续下一步" as NSString
                
                let textView = UITextView(frame: CGRect(x: 8, y: 0, width: screenWidth - 8 * 2, height: 75))
                textView.backgroundColor = UIColor.clear
                let attributedText = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonGrayTxtColor()])
                attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSLinkAttributeName: "https://www.windward.com.cn"], range: text.range(of: "《行业资质说明》"))
                
                textView.attributedText = attributedText
                textView.dataDetectorTypes = .link
                
                textView.isEditable = false
                textView.delegate = self
                
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 75))
                titleBg.addSubview(textView)
                return titleBg
            }
        } else if tableView == self.tableView4 {
            if section == 0 {
                let agreementSelectedButton = UIButton(type: .custom)
                agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOff"), for: UIControlState())
                agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOn"), for: .selected)
                agreementSelectedButton.addTarget(self, action: #selector(self.selectAgreementAction(_:)), for: .touchUpInside)
                agreementSelectedButton.frame = CGRect(x: 0, y: 0, width: 44, height: 54)
                agreementSelectedButton.isSelected = agreementSelected
                
                let agreementDetailButton = UIButton(type: .custom)
                agreementDetailButton.frame = CGRect(x: 44, y: 8, width: 170, height: 40)
                agreementDetailButton.addTarget(self, action: #selector(self.showAgreementDetailAction(_:)), for: .touchUpInside)
                
                let text = "同意《绑定银行卡协议》" as NSString
                
                let attrText = NSMutableAttributedString(string: text as String)
                attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.commonBlueColor(), range: NSRange(location: 0, length: text.length))
                attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#9498A9"), range: NSRange(location: 0, length: "同意".characters.count))
                attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: 0, length: text.length))
                agreementDetailButton.setAttributedTitle(attrText, for: UIControlState())
                
                let label = UILabel()
                label.numberOfLines = 0
                let infoTxt = "说明：\n1.结算银行卡必须为绵阳市商业银行的银行卡，暂时不支持其他银行卡。\n2.如选择对公账户，则开户名称必须与营业执照上的企业名称一致；如选择个人账户，则开户名称必须与营业执照上的经营者/法人姓名一致"
                label.text = infoTxt
                label.font = UIFont.systemFont(ofSize: 14.0)
                label.textColor = UIColor.commonGrayTxtColor()
                
                let rect = (infoTxt as NSString).boundingRect(with: CGSize(width: screenWidth - 40, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
                
                label.frame = CGRect(x: 12, y: 50, width: rect.width, height: rect.height)
                
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50 + rect.height))
                
                titleBg.addSubview(agreementSelectedButton)
                titleBg.addSubview(agreementDetailButton)
                titleBg.addSubview(label)
                return titleBg
            }
        
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if tableView == self.tableView {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "公司注册名"
                _cell.rightTxtField.keyboardType = .default
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "请输入公司注册名"
                _cell.rightTxtField.text = verificationInfo!.companyName
                _cell.endEditingBlock = { textField in
                    self.verificationInfo!.companyName = textField.text ?? ""
                }
                self.textField1 = _cell.rightTxtField
            case (0, 1):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "法人姓名"
                _cell.rightTxtField.keyboardType = .default
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "请输入法人姓名"
                _cell.rightTxtField.text = verificationInfo!.legelPerson
                _cell.maxCharacterCount = 13
                _cell.endEditingBlock = { textField in
                    self.verificationInfo!.legelPerson = textField.text ?? ""
                }
                self.textField2 = _cell.rightTxtField
            case (0, 2):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "法人身份证"
                _cell.rightTxtField.keyboardType = .numbersAndPunctuation
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "请输入法人身份证"
                _cell.rightTxtField.text = verificationInfo!.idNumber
                _cell.maxCharacterCount = 18
                _cell.endEditingBlock = { textField in
                    self.verificationInfo!.idNumber = textField.text ?? ""
                }
            case (0, 3):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "工商注册号"
                _cell.rightTxtField.keyboardType = .asciiCapable
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "工商注册号或统一社会信用代码"
                _cell.rightTxtField.text = verificationInfo!.regCode
                _cell.maxCharacterCount = 18
                _cell.endEditingBlock = { textField in
                    self.verificationInfo!.regCode = textField.text ?? ""
                }
            case (0, 4):
                guard let _cell = cell as? RightTxtViewTableViewCell else {return}
                _cell.leftTxtLabel.text = "注册地址"
                _cell.rightPlaceholder = "请输入注册地址"
                _cell.maxCharacterCount = 100
                _cell.rightTxt = self.verificationInfo!.omittedAddress
                // 开始编辑
                _cell.beginEditingBlock = { rows in
                    _cell.rightTxt = self.verificationInfo!.regAddress
                    print("开始编辑="+"\(self.verificationInfo!.regAddress)")
                    self.changHeight = CGFloat(85+rows*18)
                    let index = IndexPath(row: 5, section: 0)
                    self.tableView.reloadRows(at: [index], with: .fade)
                }
                
                // 结束编辑
                _cell.endEditingBlock = { (height, string, string2) in
                    self.changHeight = 85
                    self.verificationInfo!.regAddress = string
                    self.verificationInfo!.omittedAddress = string2
                    
                    let index = IndexPath(row: 5, section: 0)
                    self.tableView.reloadRows(at: [index], with: .fade)
                }
                // 正在编辑
                _cell.blockChangeHeight = { (height, string, rows, charactersCount) in
                    self.changHeight = CGFloat(85+rows*18)
                    self.verificationInfo!.regAddress = string
                    let index = IndexPath(row: 5, section: 0)
                    self.tableView.reloadRows(at: [index], with: .fade)
                }
      
            default:
                break
            }
        } else if tableView == self.tableView2 {
            
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cellLicenseImgs(cell)
            default:
                break
            }
        } else if tableView == self.tableView3 {
            
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cellCredentialImgs(cell)
            default:
                break
            }
        } else if tableView == self.tableView4 {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "开户银行"
                _cell.rightTxtField.text = "绵阳商业银行"
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
            case (0, 1):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "开户名称"
                _cell.rightTxtField.keyboardType = .default
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "请输入户名"
                _cell.rightTxtField.text = bankInfo!.holderName
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
                _cell.endEditingBlock = { textField in
                    self.bankInfo!.holderName = textField.text ?? ""
                }
            case (0, 2):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "银行账号"
                _cell.rightTxtField.keyboardType = .numberPad
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "必填"
                _cell.rightTxtField.text = bankInfo!.cardNumber
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
                _cell.maxCharacterCount = 19
                _cell.endEditingBlock = { textField in
                    self.bankInfo!.cardNumber = textField.text ?? ""
                }
            case (0, 3):
                guard let _cell = cell as? VerifiCodeCell else {return}
                _cell.leftTxtLabel.text = "手机号"
                _cell.rightTxtField.keyboardType = .numberPad
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "必填"
                _cell.rightTxtField.text = bankInfo!.mobile
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
                _cell.maxCharacterCount = 11
                _cell.endEditingBlock = { textField in
                    self.bankInfo!.mobile = textField.text ?? ""
                }
                captchaButton = _cell.codeButton
                _cell.tapAction = {
                    _cell.rightTxtField.endEditing(true)
                    if self.bankInfo!.mobile.characters.count != 11 {
                        Utility.showAlert(self, message: "请输入正确的手机号")
                    } else {
                        self.tapCaptchaImg()
                    }
                }
            case (0, 4):
                guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
                _cell.leftTxtLabel.text = "验证码"
                _cell.rightTxtField.keyboardType = .numberPad
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.placeholder = "请输入验证码"
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
                _cell.maxCharacterCount = 6
                _cell.endEditingBlock = { textField in
                    self.verificationInfo!.verifyCode = textField.text ?? ""
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView2 {
            if let imgURL = verificationInfo?.license, !imgURL.isEmpty {
                AOLinkedStoryboardSegue.performWithIdentifier("VerificationUploadExample@MerchantCenter", source: self, sender: nil)
            }
        }
    }
    
    // MARK: - Cell config
    
    func cellLicenseImgs(_ cell: UITableViewCell) {
        guard let _cell = cell as? ProductDetailPhotoTableViewCell else {return}
        guard let verificationInfo = self.verificationInfo else {return}
        
        _cell.imgView1.image = UIImage(named: "CommonIconAddImage")
        _cell.moreImgBgView.isHidden = true
        
        _cell.imgView2.isHidden = true
        _cell.imgView3.isHidden = true
        _cell.imgView4.isHidden = true
        
        for (index, value) in (verificationInfo.license.enumerated()) {
            switch index {
            case 0:
                _cell.imgView2.isHidden = false
                _cell.imgView2.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 1:
                _cell.imgView3.isHidden = false
                _cell.imgView3.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 2:
                _cell.imgView4.isHidden = false
                _cell.imgView4.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            default:
                break
            }
        }
        _cell.addCompletionBlock = {
            self.pushToAddPhotoVC(maxNum: 3, items: verificationInfo.license, uploadPath: "merchant/license", completeBlock: { imageURls in
                self.verificationInfo?.license = imageURls
                self.tableView2.reloadData()
            })
        }
        _cell.detailCompletionBlock = {
            self.pushToAddPhotoVC(maxNum: 3, items: verificationInfo.license, uploadPath: "merchant/license", completeBlock: { imageURls in
                self.verificationInfo?.license = imageURls
                self.tableView2.reloadData()
            })
        }
    }
    
    func cellCredentialImgs(_ cell: UITableViewCell) {
        
        guard let _cell = cell as? ProductDetailPhotoTableViewCell else {return}
        guard let verificationInfo = verificationInfo else {return}
        _cell.imgView1.image = UIImage(named: "CommonIconAddImage")
        _cell.moreImgBgView.isHidden = true
        
        _cell.imgView2.isHidden = true
        _cell.imgView3.isHidden = true
        _cell.imgView4.isHidden = true
        for (index, value) in (verificationInfo.credentialImgs.enumerated()) {
            switch index {
            case 0:
                _cell.imgView2.isHidden = false
                _cell.imgView2.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 1:
                _cell.imgView3.isHidden = false
                _cell.imgView3.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 2:
                _cell.imgView4.isHidden = false
                _cell.imgView4.sd_setImage(with: URL(string: value), placeholderImage: UIImage(named: "CommonGrayBg"))
            default:
                break
            }
        }
        _cell.addCompletionBlock = {
            self.pushToAddPhotoVC(maxNum: 5, items: verificationInfo.credentialImgs, uploadPath: "merchant/qualification", completeBlock: { imgUrls in
                self.verificationInfo?.credentialImgs = imgUrls
                self.tableView3.reloadData()
            })
        }
        _cell.detailCompletionBlock = {
            self.pushToAddPhotoVC(maxNum: 5, items: verificationInfo.credentialImgs, uploadPath: "merchant/qualification", completeBlock: { imgUrls in
                self.verificationInfo?.credentialImgs = imgUrls
                self.tableView3.reloadData()
            })
        }
        
        if (verificationInfo.credentialImgs.count) > 3 {
            _cell.moreImgBgView.isHidden = false
        }
    }
    
    private func pushToAddPhotoVC(maxNum: Int, items: [String], uploadPath: String, completeBlock: @escaping ([String]) -> Void) {
        let photoVC = AddPhotoViewController(nibName: "AddPhotoViewController", bundle: nil)
        var urlImgArr = [String]()
        for item in items {
            urlImgArr.append(item)
        }
        photoVC.maxNumb = maxNum
        photoVC.uploadImgPath = uploadPath
        photoVC.photosUrlArray = urlImgArr
        photoVC.completeBlock = completeBlock
        _ = self.navigationController?.pushViewController(photoVC, animated: true)
    }
}

extension MerchantCenterVerificationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: URL.absoluteString)
        return false
    }

}

extension MerchantCenterVerificationViewController {
    fileprivate func requstImageCode(param: ImageCodeParam) {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.captchaImgCode(param.toJSON(), aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) -> Void in
            if let message = msg, message.isEmpty == false {
                Utility.showAlert(self, message: message)
            }
            if let result = object as? [String: Any], let imageDtaStr = result["img_data"] as? String, let imgData = Data(base64Encoded: imageDtaStr, options: .ignoreUnknownCharacters) {
                 self.captchaImg = UIImage(data: imgData)
            }
        })
    }
    
    fileprivate func checkImageCode() {
        guard let captext = captchaCode else { return }
        let param = CheckImageCodeParam()
        param.mobile = bankInfo!.mobile
        param.type = .merchantVerify
        param.imgCode = captext
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.captchaCheckImgCode(param.toJSON(), aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, _, msg) -> Void in
            Utility.hideMBProgressHUD()
            if let msg = msg, !msg.isEmpty {
                Utility.showAlert(self, message: msg)
                return
            }
            if object != nil {
                self.captchaAlert?.close()
                self.captchaAlert = nil
                self.captchaImg = nil
                self.captchaImgView = nil
                
                Utility.showMBProgressHUDToastWithTxt("验证码发送成功")
                self.perform(#selector(self.hideMBProgressHUD), with: self, afterDelay: 2)
                self.captchaButton.isEnabled = false
                self.activateCaptchaCount = 0
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SignUpViewController.activeCaptchaButton(_:)), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes)
            }
        })
    }

   fileprivate func showMessageCodeView() {
        let codeAlertView = CustomIOSAlertView()
        codeAlertView?.containerView = messageCodeView()
        codeAlertView?.delegate = self
        codeAlertView?.buttonTitles = ["取消", "确定"]
        codeAlertView?.useMotionEffects = true
        codeAlertView?.show()
    }
    
    func messageCodeView() -> UIView {
        
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 174))
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 0, width: titilWidth, height: 36))
        titleLabel.text = "图形验证"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeView.addSubview(titleLabel)
        let starBgView = UIImageView(frame:CGRect(x: 0, y: 36, width: viewWidth, height: 85))
        starBgView.clipsToBounds = true
        starBgView.backgroundColor = UIColor.black
        starBgView.contentMode = .scaleAspectFit
        starBgView.image = captchaImg
        starBgView.isUserInteractionEnabled = true
        starBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapCaptchaImg)))
        codeView.addSubview(starBgView)
        captchaImgView = starBgView
        
        let codeTfd = UITextField(frame:CGRect(x: 20, y: starBgView.frame.maxY + 8, width: viewWidth - 40, height: 40))
        codeTfd.backgroundColor = UIColor.commonBgColor()
        codeTfd.borderStyle = UITextBorderStyle.none
        codeTfd.placeholder = "请输入上图答案"
        codeTfd.keyboardType = UIKeyboardType.asciiCapable
        codeTfd.autocapitalizationType = .none
        codeTfd.autocorrectionType = .no
        codeView.addSubview(codeTfd)
        captchaCodeTF = codeTfd
        captchaCodeTF?.becomeFirstResponder()
        return codeView
    }
    
    @objc fileprivate func tapCaptchaImg() {
        isSHowMessageCode = true
        showMessageCodeView()
        let param = ImageCodeParam()
        param.mobile = self.bankInfo!.mobile
        param.type = .merchantVerify
        requstImageCode(param: param)
    }
    
    @objc fileprivate func activeCaptchaButton(_ timer: Timer) {
        activateCaptchaCount += 1
        if activateCaptchaCount >= 60 {
            captchaButton.setTitle("获取验证码", for: UIControlState())
            captchaButton.isEnabled = true
            self.timer.invalidate()
            return
        }
        captchaButton.isEnabled = false
        captchaButton.setTitle("\(60 - activateCaptchaCount)秒后重发", for: UIControlState())
    }
    
    fileprivate func inputImageCode(alertView: CustomIOSAlertView) {
        if let pwd = captchaCodeTF?.text {
            captchaCode = Utility.getTextByTrim(pwd)
        } else {
            captchaCode = ""
        }
        captchaCodeTF?.text = captchaCode
        guard let captext = captchaCode else { return }
        if captext.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入图形验证码")
            return
        }
         alertView.close()
        checkImageCode()
    }
}
