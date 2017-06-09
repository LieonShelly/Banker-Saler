//
//  ShopCreateViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper
import ALCameraViewController

class ShopCreateViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    
    fileprivate var coverImg: UIImage?
    fileprivate var logoImg: UIImage?
    
    var phone: String?
    
    var storeInfo: StoreInfo! = StoreInfo()
    
    fileprivate var isUploadCover: Bool = true // If false, will upload Logo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserManager.sharedInstance.incompleteStoreInfo {
            navigationItem.title = "开店"
            bottomButton.setTitle("开店", for: UIControlState())
            
            let leftBarItem = UIBarButtonItem(title: "退出登录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.signOutAction))
            navigationItem.leftBarButtonItem = leftBarItem
            
            let blueBg = UIView(frame: CGRect(x: 0, y: -64, width: screenWidth, height: 64))
            blueBg.backgroundColor = .commonBlueColor()
            view.addSubview(blueBg)
        } else {
            navigationItem.title = "修改店铺信息"
            bottomButton.setTitle("保存", for: UIControlState())
        }
        bottomButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserManager.sharedInstance.incompleteStoreInfo {
            if storeInfo.phone.isEmpty {
                if let mobile = phone {
                    storeInfo.phone = mobile
                }
            }
        }

        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            switch (indexPath.section, indexPath.row) {
            case (3, 0):
                desVC.navTitle = "店铺描述"
                desVC.placeholder = "请输入店铺描述(限1000字)"
                desVC.txt = storeInfo.detail
                desVC.maxCharacterLimit = 1000
                desVC.completeBlock = {text in self.storeInfo.detail = text}
            default:
                break
            }
            
        } else if segue.identifier == "ShopCoverSelect@MerchantCenter" {
            guard let desVC = segue.destination as? ShopCoverSelectViewController else {return}
                desVC.coverImgUrl = storeInfo.cover
            desVC.completeBlock = {cover in if let c = cover { self.storeInfo.cover = c}}
            
        }

    }
    
    // MARK: - Action
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else {return}
        helpWebVC.requestURL = WebviewHelpDetailTag.openShopCover.detailUrl
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func signOutAction() {
        Utility.showConfirmAlert(self, message: "确认退出登录？", confirmCompletion: {
            UserManager.sharedInstance.signedIn = false
            UserManager.sharedInstance.userInfo = nil
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
    }
    
    func confirmAction() {
        if storeInfo.name.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入店铺名称")
            return
        } else if !Utility.isValidateShopName(storeInfo.name) {
            Utility.showMBProgressHUDToastWithTxt("店铺名应为15个字以内汉字、英文字母或数字组成")
            return
        } else if storeInfo.charger.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入负责人姓名")
            return
        } else if !Utility.isValidLegalPersonName(storeInfo.charger) {
            Utility.showMBProgressHUDToastWithTxt("请输入正确的负责人姓名")
            return
        } else if storeInfo.phone.isEmpty {
            Utility.showMBProgressHUDToastWithTxt("请输入店铺联系方式")
            return
        } else if !Utility.isValidateMobile(storeInfo.phone) {
            Utility.showMBProgressHUDToastWithTxt("请输入正确的联系方式")
            return
        }
        requestStoreInfoUpdate()
        
    }
    
    @IBAction func showAddPhotoAlertController() {
        
        let actionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionAlert.addAction(UIAlertAction(title: "选择相册", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.photoLibrary)
        }))
        actionAlert.addAction(UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.camera)
        }))
        actionAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionAlert, animated: true, completion: nil)
    }
    
    func chooseFromType(_ type: UIImagePickerControllerSourceType) {
        let ratio: CGFloat = isUploadCover ? (220.0/750.0) : 1.0
        switch type {
        case .photoLibrary:
            
            let libraryViewController = CameraViewController.imagePickerViewController(croppingRatio: ratio, isCircleOverlayer: true) { image, asset in
                if let image = image {
                    if self.isUploadCover {
                        self.coverImg = image
                    } else {
                        self.logoImg = image
                    }
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(libraryViewController, animated: true, completion: nil)
        case .camera:
            let cameraViewController = CameraViewController(croppingRatio: ratio, isCirclelayer: true) { image, asset in
                if let image = image {
                    if self.isUploadCover {
                        self.coverImg = image
                    } else {
                        self.logoImg = image
                    }
                    
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                    })
                    
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(cameraViewController, animated: true, completion: nil)
        default:
            break
        }
    }

    // MARK: - HTTP request
    
    func uploadImage() {
        if isUploadCover && coverImg == nil {
            return
        }
        
        if !isUploadCover && logoImg == nil {
            return
        }
        
         let coverImage = self.coverImg ?? UIImage()
         let logoImage = self.logoImg ?? UIImage()
        guard let imageData = UIImageJPEGRepresentation(isUploadCover ? coverImage : logoImage, 0.9) else {return}
        
        let parameters = isUploadCover ? ["cover": imageData, "prefix[cover]": "store/cover"] : ["logo": imageData, "prefix[logo]": "store/logo"]
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                guard let photoUploadedArray = result["success"] as? [AnyObject] else {return}
                if let photoInfo = photoUploadedArray.first, let imgUrl = photoInfo["url"] as? String {
                    if self.isUploadCover {
                        self.storeInfo.cover = imgUrl
                    } else {
                        self.storeInfo.logo = imgUrl
                    }
                    Utility.hideMBProgressHUD()
                    self.tableView.reloadData()
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            }
        }
    }
    
    func requestStoreInfoUpdate() {
        
        let parameters: [String: AnyObject] = [
            "store_logo": storeInfo.logo as AnyObject,
            "store_name": storeInfo.name as AnyObject,
            "store_cover": storeInfo.cover as AnyObject,
            "store_detail": storeInfo.detail as AnyObject,
            "store_charger": storeInfo.charger as AnyObject,
            "store_tel": storeInfo.phone as AnyObject
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeSave(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
//                let result = object as! [String: AnyObject]
                if UserManager.sharedInstance.incompleteStoreInfo {
                    Utility.showMBProgressHUDToastWithTxt("创建成功")
                    self.dismiss(animated: true, completion: { () -> Void in
                        
                    })
                } else {
                    Utility.showMBProgressHUDToastWithTxt("更新成功")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utility.hideMBProgressHUD()
                if let msg = message {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
}

extension ShopCreateViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
            
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            return cell
        case (3, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            return cell
        }
    }
}

extension ShopCreateViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            return 35
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            return 55
        case (2, 0):
            return 58
        case (3, 0):
            return 110
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 2 {
                let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
                btn.setAttributedTitle(attrTxt, for: UIControlState())
                btn.addTarget(self, action: #selector(self.showHelpPage), for: .touchUpInside)
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.sourceIsAllowEdit = true
            _cell.leftTxtLabel.text = "店铺名称"
            _cell.rightTxtField.keyboardType = .default
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = "请输入简洁有特色的店铺名称"
            _cell.rightTxtField.text = storeInfo.name
            _cell.maxCharacterCount = 15
            _cell.endEditingBlock = { textField in
                if let text = textField.text {
                    self.storeInfo.name = Utility.getTextByTrim(text)
                }
            }
            
        case (0, 1):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.sourceIsAllowEdit = true
            _cell.leftTxtLabel.text = "负责人"
            _cell.rightTxtField.keyboardType = .default
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = "请输入负责人姓名"
            _cell.rightTxtField.text = storeInfo.charger
            _cell.maxCharacterCount = 13
            _cell.endEditingBlock = { textField in
                if let text = textField.text {
                    self.storeInfo.charger = Utility.getTextByTrim(text)
                }
            }
        case (0, 2):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.sourceIsAllowEdit = true
            _cell.leftTxtLabel.text = "联系方式"
            _cell.rightTxtField.keyboardType = .numberPad
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = "顾客将联系该号码"
            _cell.rightTxtField.text = storeInfo.phone
            _cell.maxCharacterCount = 11
            _cell.endEditingBlock = { textField in
                if let text = textField.text {
                    self.storeInfo.phone = Utility.getTextByTrim(text)
                }
            }
        case (1, 0):
            guard let _cell = cell as? RightImageTableViewCell else {return}
            _cell.leftTxtLabel.text = "店铺标识"
            if !storeInfo.logo.isEmpty {
                if let img = self.logoImg {
                    _cell.rightImageView.image = img
                } else {
                    _cell.rightImageView.sd_setImage(with: URL(string: storeInfo.logo), placeholderImage: UIImage(named: "PlaceHolderHeadportrait"))
                }
            } else {
                _cell.rightImageView.image = UIImage(named: "PlaceHolderHeadportrait")
            }
        case (2, _):
            guard let _cell = cell as? RightImageTableViewCell else {return}
            _cell.leftTxtLabel.text = "店铺封面"
            if !storeInfo.cover.isEmpty {
                if let img = self.coverImg {
                    _cell.rightImageView.image = img
                } else {
                    _cell.rightImageView.sd_setImage(with: URL(string: storeInfo.cover), placeholderImage: nil)
                }
            } else {
                _cell.rightImageView.image = UIImage(named: "ic_defaullogo")
            }
        case (3, 0):
            guard let _cell = cell as? NormalDescTableViewCell else {return}
            _cell.txtLabel.numberOfLines = 4
            if storeInfo.detail.isEmpty {
                _cell.txtLabel.textColor = UIColor.textfieldPlaceholderColor()
                _cell.txtLabel.text = "请输入店铺描述"
            } else {
                _cell.txtLabel.textColor = UIColor.commonTxtColor()
                _cell.txtLabel.text = storeInfo.detail
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            isUploadCover = false
            showAddPhotoAlertController()
        case (2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ShopCoverSelect@MerchantCenter", source: self, sender: nil)
        case (3, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
        default:
            break
        }
    }
}
