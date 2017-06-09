//
//  MerchantCenterInfoViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/22/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MerchantCenterInfoViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmBtn: UIButton!

    fileprivate var logoImg: UIImage?

    var merchantInfo: MerchantInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "商户信息"
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        
        confirmBtn.setTitle("保存", for: UIControlState())
        confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)

        if let info = UserManager.sharedInstance.userInfo {
            merchantInfo = info
        } else {
            merchantInfo = MerchantInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action
    
    func refreshAction() {
        if let info = UserManager.sharedInstance.userInfo {
            merchantInfo = info
        }
        tableView.reloadData()
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
        let picker = UIImagePickerController()
        picker.navigationBar.barTintColor = UIColor.white
        picker.delegate = self
        picker.sourceType = type
        self.present(picker, animated: true) { () -> Void in
            
        }
    }

    func confirmAction() {
        requestModifyMerchantInfo()
        
    }
    
    // MARK: - HTTP request
    
    func uploadImage() {
        guard let img = logoImg else {
            return
        }
        
        guard let imageData = UIImageJPEGRepresentation(img, 0.8) else {return}
        
        let parameters = ["logo": imageData, "prefix[logo]": "merchant/logo"] as [String : Any]
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                guard let photoUploadedArray = result["success"] as? [AnyObject] else {return}
                if let photoInfo = photoUploadedArray.first, let imgUrl = photoInfo["url"] as? String {
                    self.merchantInfo.logo = imgUrl
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

    func requestModifyMerchantInfo() {
        let parameters: [String: Any] = [
            "logo": merchantInfo.logo,
            "name": merchantInfo.name,
            "tel": merchantInfo.tel
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.merchantUpdate(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
//                let result = object as! [String: AnyObject]
                Utility.showMBProgressHUDToastWithTxt("信息更新成功")
                
                kApp.requestUserInfoWithCompleteBlock({ _ in
                    self.refreshAction()
                })
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }

}

// MARK: - Image Picker Delegate

extension MerchantCenterInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let oldImg = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        guard let imageData1 = UIImageJPEGRepresentation(oldImg, 0.8) else {return}
        guard let img = UIImage(data: imageData1) else {return}
        logoImg = img
        self.dismiss(animated: true, completion: nil)
    }
}

extension MerchantCenterInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            cell.accessoryType = .none
            return cell
        }
    }
}

extension MerchantCenterInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 55
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard let _cell = cell as? RightImageTableViewCell else {return}
            _cell.leftTxtLabel.text = "商户标识"
            _cell.rightImageView.sd_setImage(with: URL(string: merchantInfo.logo), placeholderImage: UIImage(named: "PlaceHolderHeadportrait"))
        case (0, 1):
            
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "商户昵称"
            _cell.rightTxtField.keyboardType = .default
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = ""
            _cell.rightTxtField.text = merchantInfo.name
            _cell.endEditingBlock = { textField in
                self.merchantInfo.name = textField.text ?? ""
            }
        case (0, 2):
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "联系电话"
            _cell.rightTxtField.keyboardType = .numberPad
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = ""
            _cell.rightTxtField.text = merchantInfo.tel
            _cell.endEditingBlock = { textField in
                self.merchantInfo.tel = textField.text ?? ""
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showAddPhotoAlertController()
        default:
            break
        }
    }
}
