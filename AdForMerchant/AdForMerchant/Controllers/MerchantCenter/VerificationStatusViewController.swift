//
//  VerificationStatusViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 4/21/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class VerificationStatusViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!

    @IBOutlet fileprivate weak var bottomButton: UIButton!
    @IBOutlet fileprivate var bottomBtnBottomConstr: NSLayoutConstraint!

    var verifyStatus: LicenseVerifyStatus = .unverified
    var verificationInfo: VerificationInfo?
    var bankInfo: BankAccountInfo?
    
    var hasCredentials: Bool = true
    var payPassword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商户认证"

        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(VerificationStatusViewController.backAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        
        refreshData()
        guard let verificationInfo = verificationInfo else {return}
        if verificationInfo.credentialImgs.isEmpty == true {
            hasCredentials = false
        }
        
//        refreshStatus()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        refreshStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kApp.requestUserInfoWithCompleteBlock({
            self.refreshData()
            self.tableView.reloadData()
            self.refreshStatus()
        }, failedBlock: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    // MARK: - Action

    func backAction() {
        if navigationController?.viewControllers.first is MerchantCenterVerificationViewController {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func refreshData() {
        if let status = UserManager.sharedInstance.userInfo?.status {
            verifyStatus = status
        }
        
        if let vInfo = UserManager.sharedInstance.userInfo?.verificationInfo {
            verificationInfo = vInfo
            if let bInfo = vInfo.cardList.first {
                bankInfo = bInfo
            }
        } else {
            verificationInfo = VerificationInfo(JSON: [:])
        }
        
        if bankInfo == nil {
            bankInfo = BankAccountInfo(JSON: [:])
        }
    }

    func refreshStatus() {
        kApp.requestUserInfoWithCompleteBlock()
        if let status = UserManager.sharedInstance.userInfo?.status {
            self.verifyStatus = status
        }
        switch verifyStatus {
        case .unverified:
            bottomButton.isHidden = true
            bottomBtnBottomConstr.constant = -49
        case .waitingForReview:
            bottomButton.isHidden = true
            bottomButton.addTarget(self, action: #selector(self.showVerificationView), for: .touchUpInside)
            bottomBtnBottomConstr.constant = -49
        case .verifyFailed:
            bottomButton.isEnabled = true
            bottomButton.setTitle("重新认证", for: UIControlState())
            bottomButton.addTarget(self, action: #selector(self.showVerificationView), for: .touchUpInside)
            bottomBtnBottomConstr.constant = 0
        case .verified:
            bottomButton.isHidden = true
            bottomButton.setTitle("重新认证", for: UIControlState())
            bottomButton.addTarget(self, action: #selector(self.showVerificationView), for: .touchUpInside)
            bottomBtnBottomConstr.constant = -49

        }
    }

    func showVerificationView() {                        
        if let merchantCenter = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "MerchantCenterVerification") as? MerchantCenterVerificationViewController {
            merchantCenter.payCodeSetted = true
            merchantCenter.payPasswd = self.payPassword
            let nav: UINavigationController = UINavigationController.init(rootViewController: merchantCenter)
            self.present(nav, animated: true, completion: {
            })
        }
    }
    
    // MARK: - Private
}

extension VerificationStatusViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch verifyStatus {
        case .unverified:
            return 1
        case .waitingForReview, .verifyFailed, .verified:
            if hasCredentials {
                return 5
            } else {
                return 4
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section, hasCredentials) {
        case (1, _):
            return 5
        case (3, false), (4, true):
            return 4
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row, hasCredentials) {
        case (0, 0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "VerificationStatusCell", for: indexPath)
            guard let status = UserManager.sharedInstance.userInfo?.status else {return UITableViewCell() }
            cell.isUserInteractionEnabled = status == .verifyFailed ? true : false
            return cell
        case (1, 4, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtViewTableViewCell", for: indexPath)
            return cell
        case (2, _, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
            return cell
        case (3, _, true):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailPhotoTableViewCell", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        }
    }

}

extension VerificationStatusViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 30
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return CGFloat.leastNormalMagnitude
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        verifyStatus = UserManager.sharedInstance.userInfo?.status ?? .waitingForReview
        switch verifyStatus {
        case .unverified:
            return 135
        case .waitingForReview, .verifyFailed, .verified:
            switch (indexPath.section, indexPath.row, hasCredentials) {
            case (0, 0, _):
                if verifyStatus == .verifyFailed {
                    guard let failedText = (UserManager.sharedInstance.userInfo?.tips) else {return CGFloat.leastNormalMagnitude}
                    let size = (failedText as NSString).boundingRect(with: CGSize(width: screenWidth / 2, height: CGFloat.leastNormalMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)], context: nil)
                    return max(100, ceil(size.height) + 30.0)
                } else {
                    return 100
                }
            case (1, 4, _):
                return 77
            case (2, _, _):
                return 90
            case (3, _, true):
                return 90
            default:
                return 45
            }
            
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        
        let titleLbl = UILabel(frame: CGRect(x: 15, y: 6, width: 300, height: 18))
        titleLbl.font = UIFont.systemFont(ofSize: 14.0)
        titleLbl.textColor = UIColor.commonGrayTxtColor()
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: 215, height: 30))
        titleBg.addSubview(titleLbl)
        switch (section, hasCredentials) {
        case (1, _):
            titleLbl.text = "公司信息"
        case (2, _):
            titleLbl.text = "基础资质"
        case (3, true):
            titleLbl.text = "行业资质"
        case (3, false), (4, _):
            titleLbl.text = "银行卡信息"
        default:
            return nil
        }
        
        return titleBg
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row, hasCredentials) {
        case (0, 0, _):
            guard let _cell = cell as? VerificationStatusCell else {return}
            _cell.status = verifyStatus        
            if _cell.status == .verifyFailed {
                _cell.accessoryType = .disclosureIndicator
            } else {
                _cell.accessoryType = .none
            }
//            if verifyStatus == .verifyFailed {
//                guard let tips = UserManager.sharedInstance.userInfo?.tips else {return}
////                _cell.failedTxt = tips
//            }
        case (1, 0, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "公司注册名"
            _cell.rightTxtField.text = verificationInfo?.companyName
        case (1, 1, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "法人姓名"
            _cell.rightTxtField.text = verificationInfo?.legelPerson
        case (1, 2, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "法人身份证"
            _cell.rightTxtField.text = verificationInfo?.idNumber
        case (1, 3, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "工商注册号"
            _cell.rightTxtField.text = verificationInfo?.regCode
        case (1, 4, _):
            guard let _cell = cell as? RightTxtViewTableViewCell else {return}
            _cell.leftTxtLabel.text = "注册地址"
            _cell.adressRightTxt = verificationInfo?.regAddress ?? ""
            
        case (2, 0, _):
            cellLicenseImgs(cell)
        case (3, 0, true):
            cellCredentialImgs(cell)
        case (3, 0, false), (4, 0, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "开户银行"
            _cell.rightTxtField.text = bankInfo?.bankName
        case (3, 1, false), (4, 1, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "开户名称"
            _cell.rightTxtField.text = bankInfo?.holderName
        case (3, 2, false), (4, 2, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "银行账号"
            _cell.rightTxtField.text = bankInfo?.cardNumber
        case (3, 3, false), (4, 3, _):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "手机号"
            _cell.rightTxtField.text = bankInfo?.mobile
            
        default:
            break
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        guard let verification = self.verificationInfo else {return}
        switch (indexPath.section, indexPath.row, hasCredentials) {
        case (0, 0, _):
            guard let remark = UserManager.sharedInstance.userInfo?.remark else {return}
            let failureDetailsVC = FailureDetailsViewController()
            failureDetailsVC.errorMessage = remark
            navigationController?.pushViewController(failureDetailsVC, animated: true)
        case (2, 0, _):
            
            let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
            var  urlImgArr = [String]()
            guard let verification = self.verificationInfo else {return}
            for item in (verification.license) {
                urlImgArr.append(item)
            }
            detailVC.photosUrlArray = urlImgArr
            
            navigationController?.pushViewController(detailVC, animated: true)
        case (3, 0, true):
            let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
            var  urlImgArr = [String]()
            for item in (verification.credentialImgs) {
                urlImgArr.append(item)
            }
            detailVC.photosUrlArray = urlImgArr
            
            navigationController?.pushViewController(detailVC, animated: true)
        default:
            break
        }
        
    }
    
    // MARK: - Cell config
    
    func cellLicenseImgs(_ cell: UITableViewCell) {
        guard let verificationInfo = self.verificationInfo else {return}
        
        guard let _cell = cell as? ProductDetailPhotoTableViewCell else {return}
        _cell.moreImgBgView.isHidden = true
        _cell.bottomNoteLabel.isHidden = true
        
        for (index, value) in (verificationInfo.license.enumerated()) {
            switch index {
            case 0:
                _cell.imgView1.isHidden = false
                _cell.imgView1.isUserInteractionEnabled = false
                _cell.imgView1.sd_setImage(with: URL(string: value))
            case 1:
                _cell.imgView2.isHidden = false
                _cell.imgView2.isUserInteractionEnabled = false
                _cell.imgView2.sd_setImage(with: URL(string: value))
            case 2:
                _cell.imgView3.isHidden = false
                _cell.imgView3.isUserInteractionEnabled = false
                _cell.imgView3.sd_setImage(with: URL(string: value))
            case 3:
                _cell.imgView4.isHidden = false
                _cell.imgView4.isUserInteractionEnabled = false
                _cell.imgView4.sd_setImage(with: URL(string: value))
            default:
                break
            }
        }
        
        _cell.addCompletionBlock = nil
        _cell.detailCompletionBlock = nil
        
        if (verificationInfo.license.count) > 4 {
            _cell.moreImgBgView.isHidden = false
            _cell.moreImgBgView.isUserInteractionEnabled = false
        }
    }
    
    func cellCredentialImgs(_ cell: UITableViewCell) {
        guard let _cell = cell as? ProductDetailPhotoTableViewCell else {return}
        guard let verificationInfo = self.verificationInfo else {return}
        _cell.moreImgBgView.isHidden = true
        _cell.bottomNoteLabel.isHidden = true
        
        for (index, value) in (verificationInfo.credentialImgs.enumerated()) {
            switch index {
            case 0:
                _cell.imgView1.isHidden = false
                _cell.imgView1.isUserInteractionEnabled = false
                _cell.imgView1.sd_setImage(with: URL(string: value))
            case 1:
                _cell.imgView2.isHidden = false
                _cell.imgView2.isUserInteractionEnabled = false
                _cell.imgView2.sd_setImage(with: URL(string: value))
            case 2:
                _cell.imgView3.isHidden = false
                _cell.imgView3.isUserInteractionEnabled = false
                _cell.imgView3.sd_setImage(with: URL(string: value))
            case 3:
                _cell.imgView4.isHidden = false
                _cell.imgView4.isUserInteractionEnabled = false
                _cell.imgView4.sd_setImage(with: URL(string: value))
            default:
                break
            }
        }
        
        _cell.addCompletionBlock = nil
        _cell.detailCompletionBlock = nil
        
        if (verificationInfo.credentialImgs.count) > 4 {
            _cell.moreImgBgView.isHidden = false
            _cell.moreImgBgView.isUserInteractionEnabled = false
        }
    }
}
