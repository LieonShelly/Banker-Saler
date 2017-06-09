//
//  VerificationUploadExampleViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 4/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class VerificationUploadExampleViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var uploadPhotoBgView: UIView!
    
    var licenseImg: UIImage?
    
    var completeBlock: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "添加图片"
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(VerificationStatusViewController.backAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
//        uploadPhotoBgView.hidden = true
        //        verifyStatus =
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        NSNotificationCenter.defaultCenter().addObserverForName(RefreshMerchantInfoNotification, object: nil, queue: nil) { (notification: NSNotification?) in
        //            self.refreshStatus()
        //            return
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        NSNotificationCenter.defaultCenter().removeObserver(nil, name: RefreshMerchantInfoNotification, object: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            
            switch (indexPath.section, indexPath.row) {
            case (3, _):
                desVC.navTitle = "输入商品名称"
            case (4, _):
                desVC.navTitle = "输入商品描述"
            default:
                break
            }
            
        }
    }
    
    // MARK: - Action
    
    func backAction() {
        backActionWithImg()
    }
    
    func backActionWithImg(_ img: String? = nil) {
        if let img = img, let block = completeBlock {
            block(img)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func showVerificationView() {
        guard let superView = uploadPhotoBgView.superview else {return}
        superView.bringSubview(toFront: self.uploadPhotoBgView)
        uploadPhotoBgView.isHidden = false
    }
    
    @IBAction func addImageFromPhotoLibrary() {
        chooseFromType(.photoLibrary)
    }
    
    @IBAction func takePicture() {
        chooseFromType(.camera)
        
    }
    
    func chooseFromType(_ type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.navigationBar.barTintColor = UIColor.white
        picker.delegate = self
        picker.sourceType = type
        self.present(picker, animated: true) { () -> Void in
            
        }
    }
    
    // MARK: - HTTP request
    
    func uploadImage() {
        guard let img = licenseImg else {
            return
        }
        guard let imageData = UIImageJPEGRepresentation(img, 0.9) else {return}
        let parameters: [String: AnyObject] = [
            "license": imageData as AnyObject,
            "prefix[license]": "merchant/license" as AnyObject
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                guard let photoUploadedArray = result["success"] as? [AnyObject] else {return}
                if let photoInfo = photoUploadedArray.first, let licenseImgUrl = photoInfo["url"] as? String {
                    Utility.hideMBProgressHUD()
                    self.backActionWithImg(licenseImgUrl)
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
    
}

// MARK: - Image Picker Delegate

extension VerificationUploadExampleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let oldImg = (info as NSDictionary).value(forKey: UIImagePickerControllerOriginalImage) as? UIImage else {return}
        guard let imageData1 = UIImageJPEGRepresentation(oldImg, 0.9) else {return}
        guard let img = UIImage(data: imageData1) else {return}
        
        licenseImg = img
        
        self.dismiss(animated: true, completion: { () -> Void in
            self.uploadImage()
        })
    }
    
}
