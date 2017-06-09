//
//  AdAddNewViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable force_unwrapping

import UIKit
import ALCameraViewController
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T: Comparable> (lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func ><T: Comparable> (lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class AdAddNewViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tbvLeadingCons: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tbvWidthCont: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableView2: UITableView!
    @IBOutlet fileprivate weak var tableView3: UITableView!
 
    @IBOutlet fileprivate weak var stepViewBg: UIView!
    fileprivate var stepPageCtrl: StepPageControl!
    
    @IBOutlet fileprivate weak var goNextStepView: GoNextStepView!
    
    var adDetailModel: AdDetailModel = AdDetailModel()
    var adType: AdType = .picture
    var modifyType: ObjectModifyType = .addNew
    var isEditDraftAd: Bool = false
    var adID: String?
    
    //image Data
    var imageData: Data?
    
    var currentPage: Int = 0 {
        didSet {
            changePageStyle()
            moveToPageIndex(self.currentPage)
        }
    }
    
    var currentPoint = 0
    var deductionPoints = 0
    fileprivate var unEditAdDetailModel: AdDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (modifyType, adType) {
        case (.addNew, .picture), (.copy, .picture):
            navigationItem.title = "新建图片广告"
        case (.addNew, .movie), (.copy, .movie):
            navigationItem.title = "新建视频广告"
        case (.addNew, .webpage), (.copy, .webpage):
            navigationItem.title = "新建网页广告"
        case (.edit, .picture):
            navigationItem.title = "编辑图片广告"
        case (.edit, .movie):
            navigationItem.title = "编辑视频广告"
        case (.edit, .webpage):
            navigationItem.title = "编辑网页广告"
        }
        
        let leftBarItem = UIBarButtonItem(title:"取消", style: .plain, target: self, action: #selector(self.backAlertAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        goNextStepView.delegate = self
        
        stepPageCtrl = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        stepPageCtrl.stepTitleArray = ["编辑基本信息", "设置参与方式", "奖品设置"]
        stepViewBg.addSubview(stepPageCtrl)
        
        changePageStyle()
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView2.backgroundColor = UIColor.commonBgColor()
        tableView3.backgroundColor = UIColor.commonBgColor()
        
        tableView3.keyboardDismissMode = .onDrag
        
        for table in [tableView, tableView2, tableView3] {
            table?.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
            table?.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
            table?.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
            table?.register(UINib(nibName: "AdAddAnswerTableViewCell", bundle: nil), forCellReuseIdentifier: "AdAddAnswerTableViewCell")
        }
        reqUserInfo()
        if adID != nil {
            requestAdDetail()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reqUserInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        tbvWidthCont.constant = self.view.frame.size.width
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObjectReleaseSucceed@Product" {
            guard let desVC = segue.destination as? ObjectReleaseSucceedViewController else {return}
            if modifyType == .edit {
                desVC.navTitle = "编辑广告"
                desVC.desc = "广告编辑成功，可直接在广告列表查看"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenAdChangedNotification), object: nil, userInfo: ["AdStatus": AdStatus.waitingForReview.rawValue])
                }
            } else {                
                desVC.navTitle = "发布广告"
                desVC.desc = "广告发布完成，待平台审核"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenAdChangedNotification), object: nil, userInfo: ["AdStatus": AdStatus.waitingForReview.rawValue])
                }
            }
        } else if segue.identifier == "ProductDescInput@Product" {
            guard let desVC = segue.destination as? DetailInputViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            
            switch (currentPage, indexPath.section, indexPath.row) {
            case (0, 1, _):
                desVC.navTitle = "广告标题"
                desVC.placeholder = "请输入广告标题(限30字)"
                desVC.maxCharacterLimit = 30
                if !adDetailModel.title.isEmpty {
                    desVC.txt = self.adDetailModel.title
                }
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.title = str
                    self.tableView.reloadData()
                }
            case (0, 2, _):
                desVC.navTitle = "广告描述"
                desVC.placeholder = "请输入广告描述(限1000字)"
                if !adDetailModel.detail.isEmpty {
                    desVC.txt = self.adDetailModel.detail
                }
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.detail = str
                    self.tableView.reloadData()
                }
            case (1, 1, _):
                desVC.navTitle = "设置问题"
                desVC.placeholder = "请输入问题内容(限35字)"
                if !adDetailModel.question.isEmpty {
                    desVC.txt = self.adDetailModel.question
                }
                desVC.maxCharacterLimit = 35
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.question = str
                    self.tableView2.reloadData()
                }
            case (1, 2, 0):
                desVC.navTitle = "设置答案"
                desVC.placeholder = "设置答案(限14字)"
                if !adDetailModel.answer.answerA.text.isEmpty {
                    desVC.txt = self.adDetailModel.answer.answerA.text
                }
                desVC.maxCharacterLimit = 14
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.answer.answerA.text = str
                    self.tableView2.reloadData()
                }
            case (1, 2, 1):
                desVC.navTitle = "设置答案"
                desVC.placeholder = "设置答案(限14字)"
                if !adDetailModel.answer.answerB.text.isEmpty {
                    desVC.txt = self.adDetailModel.answer.answerB.text
                }
                desVC.maxCharacterLimit = 14
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.answer.answerB.text = str
                    self.tableView2.reloadData()
                }
            case (1, 2, 2):
                desVC.navTitle = "设置答案"
                desVC.placeholder = "设置答案(限14字)"
                if !adDetailModel.answer.answerC.text.isEmpty {
                    desVC.txt = self.adDetailModel.answer.answerC.text
                }
                desVC.maxCharacterLimit = 14
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.answer.answerC.text = str
                    self.tableView2.reloadData()
                }
            case (1, 2, 3):
                desVC.navTitle = "设置答案"
                desVC.placeholder = "设置答案(限14字)"
                if !adDetailModel.answer.answerD.text.isEmpty {
                    desVC.txt = self.adDetailModel.answer.answerD.text
                }
                desVC.maxCharacterLimit = 14
                desVC.completeBlock = {(str) -> Void in
                    self.adDetailModel.answer.answerD.text = str
                    self.tableView2.reloadData()
                }
            default:
                break
            }
        } else if segue.identifier == "AdAddMovie@Ad" {
            guard let desVC = segue.destination as? AdAddMovieViewController else {return}
            desVC.adType = adType
            switch self.adType {
            case .movie:
                if !adDetailModel.videoAdUrl.isEmpty {
                    desVC.videoStr = self.adDetailModel.videoAdUrl
                }
            case .webpage:
                if !adDetailModel.webAdUrl.isEmpty {
//                    print (self.adDetailModel.webAdUrl)
                    desVC.videoStr = self.adDetailModel.webAdUrl
                }
            default:
                break
            }
            desVC.completionBlock = {(str) -> Void in
                switch self.adType {
                case .movie:
                    self.adDetailModel.videoAdUrl = str
                case .webpage:
                    self.adDetailModel.webAdUrl = str
                default:
                    break
                }
                self.tableView.reloadData()
            }
        }
    }
   
}

extension AdAddNewViewController {
    func chargeAction() {
        guard let verificationStatus = UserManager.sharedInstance.userInfo?.status else {
            return
        }
        
        if verificationStatus != .verified {
            Utility.showAlert(self, message: "未绑定银行卡，请先认证")
            return
        }
        
        AOLinkedStoryboardSegue.performWithIdentifier("ChargePoints@MerchantCenter", source: self, sender: nil)
    }
    
    func moveToPageIndex(_ pageIndex: Int) {
        
        let width: CGFloat = self.view.frame.size.width
        
        if pageIndex != self.currentPage {
            if pageIndex > 2 || pageIndex < 0 {
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
            tableView.isHidden = false
            goNextStepView.nextStepButtonTitle = "下一步"
            goNextStepView.animateOnlyNextStep = true
        case 1:
            tableView.isHidden = false
            goNextStepView.nextStepButtonTitle = "下一步"
            goNextStepView.animateOnlyNextStep = false
        case 2:
            tableView.isHidden = true
            if modifyType == .addNew || modifyType == .copy {
                goNextStepView.nextStepButtonTitle = "提交审核"
            } else {
                goNextStepView.nextStepButtonTitle = "提交审核"
            }
            goNextStepView.animateOnlyNextStep = false
        default:
            break
        }
    }
  
    func showDraftAlert() {
        let alert = UIAlertController(title: "温馨提示", message: "是否保存为草稿", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            self.saveAdvertiseAsDraft()
        }
        let unsaveAction = UIAlertAction(title: "不保存", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in }
        alert.addAction(saveAction)
        alert.addAction(unsaveAction)
        alert.addAction(cancleAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func backAlertAction() {
        if modifyType == .addNew || modifyType == .copy {
            handleSaveNewAdvertiseAsDraft()
        }
        if  modifyType == .edit {
            handleSaveEditAdvertiseAsDraft()
        }
    }
    
    func handleSaveNewAdvertiseAsDraft() {
        if isNeedSaveNewAdvertise() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func handleSaveEditAdvertiseAsDraft() {
        if isNeedSaveEditAdvertise() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveAdvertiseAsDraft() {
        var param = createRequstParams()
        param["is_approved"] = 3
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()

        RequestManager.request(AFMRequest.adSave(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if error != nil {
                 Utility.showAlert(self, message: msg ?? "")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenAdChangedNotification), object: nil, userInfo: ["AdStatus": AdStatus.draft.rawValue])
            }
        }
    }
    
    func createRequstParams() -> [String: Any] {
        
        var params: [String: Any] = [:]
        var type = ""

        switch adType {
        case .picture:
            type = "1"
            params["img_ad_url"] = adDetailModel.imgAdUrl
        case .movie:
            type = "2"
            params["video_ad_url"] = adDetailModel.videoAdUrl
        case .webpage:
            type = "3"
            params["web_ad_url"] = adDetailModel.webAdUrl
        }
        
        if modifyType != .copy {
            if !adDetailModel.adID.isEmpty {
                params["ad_id"] = adDetailModel.adID
            }
        }
        params["type"] = type
        params["title"] = adDetailModel.title
        params["cover"] = adDetailModel.cover
        params["detail"] = adDetailModel.detail
        params["start_time"] =  adDetailModel.startTime == "" ? String.getCurrentTime() : adDetailModel.startTime
        params["end_time"] = adDetailModel.endTime
        params["question"] = adDetailModel.question
        params["point"] = adDetailModel.point
        params["point_limit_perday"] = adDetailModel.pointLimitPerday
        
        //拼answer
        var dicArr: [String: Any] = [:]
        //答案A
        if let answerA = combinationAnswer(self.adDetailModel.answer.answerA) {
            dicArr["a"] = answerA
        }
        if let answerB = combinationAnswer(self.adDetailModel.answer.answerB) {
            dicArr["b"] = answerB
        }
        if let answerC = combinationAnswer(self.adDetailModel.answer.answerC) {
            dicArr["c"] = answerC
        }
        if let answerD = combinationAnswer(self.adDetailModel.answer.answerD) {
            dicArr["d"] = answerD
        }
        
        params["answer"] = dicArr
        return params
    }
    
    func isNeedSaveNewAdvertise() -> Bool {
        return adDetailModel.canBeDraft
    }
    
    func isNeedSaveEditAdvertise() -> Bool {
        if unEditAdDetailModel == adDetailModel {
            return false
        } else {
            return true
        }
        
    }

    func calculate(_ answer: AnswerModel) {
        if answer.isCorrect == "1" {
            answer.isCorrect = "0"
        } else {
            answer.isCorrect = "1"
        }
        
        self.tableView2.reloadData()
    }
    
    func validateDetail() -> Bool {
        if (adDetailModel.cover.isEmpty) && (imageData == nil) {
            Utility.showAlert(self, message: "请上传广告封面")
            return false
        }
        if adDetailModel.title.isEmpty {
            Utility.showAlert(self, message: "请填写广告标题")
            return false
        }
        if adDetailModel.title.characters.count > 30 {
            Utility.showAlert(self, message: "广告标题应该是30个字以内汉字、英文字母或数字组成")
            return false
        }
        if adDetailModel.detail.isEmpty {
            Utility.showAlert(self, message: "请填写广告描述")
            return false
        }
        switch adType {
        case .picture:
            if adDetailModel.imgAdUrl.isEmpty {
                Utility.showAlert(self, message: "请添加广告图片")
                return false
            }
        case .movie:
            if adDetailModel.videoAdUrl.isEmpty {
                Utility.showAlert(self, message: "请添加广告视频")
                return false
            }
        case .webpage:
            if adDetailModel.webAdUrl.isEmpty {
                Utility.showAlert(self, message: "请添加广告网页")
                return false
            }
        }
        if adDetailModel.endTime.isEmpty {
            Utility.showAlert(self, message: "请添加结束时间")
            return false
        }
        return true
    }
    
    /// 判断问题设置情况
    func validateQuestion() -> Bool {
        if adDetailModel.question.isEmpty {
            Utility.showAlert(self, message: "请设置问题内容")
            return false
        }
        if adDetailModel.answer.answerA.text.isEmpty {
            Utility.showAlert(self, message: "请设置答案A")
            return false
        }
        if adDetailModel.answer.answerB.text.isEmpty {
            Utility.showAlert(self, message: "请设置答案B")
            return false
        }
        if adDetailModel.answer.answerA.isCorrect == "0" && adDetailModel.answer.answerB.isCorrect == "0" && adDetailModel.answer.answerC.isCorrect == "0" && adDetailModel.answer.answerD.isCorrect == "0" {
            Utility.showAlert(self, message: "请至少设置一个正确答案")
            return false
        }
        
        if !validateAnswerNull(self.adDetailModel.answer.answerA, type: "A") ||
            !validateAnswerNull(self.adDetailModel.answer.answerB, type: "B") ||
            !validateAnswerNull(self.adDetailModel.answer.answerC, type: "C") ||
            !validateAnswerNull(self.adDetailModel.answer.answerD, type: "D") {
            return false
        }
        if self.adDetailModel.answer.answerD.text.isEmpty == false {
            if self.adDetailModel.answer.answerC.text.isEmpty {
                Utility.showAlert(self, message: "请设置答案C")
                return false
            }
        }
        return true
    }
    
    func validateAnswerNull(_ answer: AnswerModel, type: String) -> Bool {
        if answer.isCorrect == "1" {
            if answer.text.isEmpty {
                Utility.showAlert(self, message: "请设置答案" + type)
                return false
            }
        }
        return true
    }
    
    /// 判断积分条件情况
    func validatePoint() -> Bool {
        let point = Int(adDetailModel.point)
        let pointLimit = Int(adDetailModel.pointLimitPerday)
        
        //1.判断积分不能为空
        if adDetailModel.point.isEmpty || adDetailModel.pointLimitPerday.isEmpty {
            Utility.showAlert(self, message: "积分不能为空")
            return false
        } else if point > pointLimit {//2.判断奖励积分不能大于每日上限
            Utility.showAlert(self, message: "单个奖励积分不能大于每日上限积分")
            return false
        }
        return true
    }
    
    /// 执行确认支付积分方法
    func payPoint() -> Bool {
        guard let point = UserManager.sharedInstance.userInfo?.point else {return false }
        guard let currentPoint = Int(point) else {return false}
        if currentPoint < Int(adDetailModel.pointLimitPerday) {
            Utility.showAlert(self, message: "您当前的积分不够支付本广告所需预扣积分，请您前去充值")
            return false
        } else {
            return true
        }
    }
    
    ///  拼接answer请求字典
    func combinationAnswer(_ answer: AnswerModel) -> [String: AnyObject]? {
        if !answer.text.isEmpty {
            let answerDic = ["text": answer.text,
                             "is_correct": answer.isCorrect]
            return answerDic as [String : AnyObject]?
        }
        return nil
    }
    
    ///   Photo Cover Alert
    func showAddPhotoAlertController() {
        
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
        switch type {
        case .photoLibrary:
            let libraryViewController = CameraViewController.imagePickerViewController(croppingRatio: 1.0/1.34) { image, asset in
                if let image = image {
                    self.imageData = UIImageJPEGRepresentation(image, 0.8)
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(libraryViewController, animated: true, completion: nil)
        case .camera:
            let cameraViewController = CameraViewController(croppingRatio: 1.0/1.34) { image, asset in
                if let image = image {
                    self.imageData = UIImageJPEGRepresentation(image, 0.8)
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
    
    func keyboardWillShow(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView2.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView2.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView2.contentInset = UIEdgeInsets.zero
            self.tableView2.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        })
    }
    
    func uploadImage() {
        guard let imageData = imageData else {return}
        let parameters: [String: Any] = [
            "cover": imageData,
            "prefix[cover]": "goods/cover"
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                guard let photoUploadedArray = result["success"] as? [AnyObject] else {return}
                if let photoInfo = photoUploadedArray.first, let coverImgUrl = photoInfo["url"] as? String {
                    self.adDetailModel.cover = coverImgUrl
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
    
    func requestAdDetail() {
        guard let adID = adID else {return}
        let params: [String: Any] = ["ad_id": adID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.adDetail(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                Utility.showAlert(self, message: msg ?? "")
            } else {
                guard let result = object as? [String: AnyObject] else {return}
                guard let model = AdDetailModel(JSON: result) else {return}
                if self.modifyType == .edit {
                    self.unEditAdDetailModel = AdDetailModel(JSON: result) ?? AdDetailModel()
                }
                self.adDetailModel = model
                self.tableView.reloadData()
                self.tableView2.reloadData()
                self.tableView3.reloadData()
            }
        }
    }

    /// 发布广告
    func requestSendAD(_ confirm: Bool = false) {
        
        var params: [String: Any] = [:]
        var type = ""
        
        if confirm {
            params["step"] = 4
        } else {
            params["step"] = currentPage + 1
        }
        switch adType {
        case .picture:
            type = "1"
            params["img_ad_url"] = adDetailModel.imgAdUrl
        case .movie:
            type = "2"
            params["video_ad_url"] = adDetailModel.videoAdUrl
        case .webpage:
            type = "3"
            params["web_ad_url"] = adDetailModel.webAdUrl
        }
        
        if modifyType != .copy {
            if !adDetailModel.adID.isEmpty {
                params["ad_id"] = adDetailModel.adID
            }
        }
        params["type"] = type
        params["title"] = adDetailModel.title
        params["cover"] = adDetailModel.cover
        params["detail"] = adDetailModel.detail
        //        params["start_time"] = adDetailModel.startTime
        params["start_time"] =  adDetailModel.startTime == "" ? String.getCurrentTime() : adDetailModel.startTime
        params["end_time"] = adDetailModel.endTime
        params["question"] = adDetailModel.question
        params["point"] = adDetailModel.point
        params["point_limit_perday"] = adDetailModel.pointLimitPerday
        
        //拼answer
        var dicArr: [String: Any] = [:]
        //答案A
        if let answerA = combinationAnswer(self.adDetailModel.answer.answerA) {
            dicArr["a"] = answerA
        }
        if let answerB = combinationAnswer(self.adDetailModel.answer.answerB) {
            dicArr["b"] = answerB
        }
        if let answerC = combinationAnswer(self.adDetailModel.answer.answerC) {
            dicArr["c"] = answerC
        }
        if let answerD = combinationAnswer(self.adDetailModel.answer.answerD) {
            dicArr["d"] = answerD
        }
        
        params["answer"] = dicArr
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
                print(params)
        Utility.showMBProgressHUDWithTxt()
        let day = self.getTwoDatePoor(starTime: String.getCurrentTime(), endTime: adDetailModel.endTime)
        let point = Int(adDetailModel.pointLimitPerday) ?? 0
        deductionPoints = day * point
        RequestManager.request(AFMRequest.adSave(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    if error?.code == WebSeverErrorCode.needCharge.rawValue {
                        Utility.showConfirmAlert(self,
                                                 title: "提示",
                                                 cancelButtonTitle: "取消",
                                                 confirmButtonTitle: "去充值",
                                                 message: msg,
                                                 confirmCompletion: {
                                                    self.chargeAction()
                        })
                    } else {
                        
                        if self.currentPage == 2 {
                            // 。。。走到这一步 积分 不足够
                            let msg = "此次发布将扣除"+"\(self.deductionPoints)"+"积分，确定发布？"
                            Utility.showConfirmAlert(self, message: msg, confirmCompletion: { _ in
                                Utility.showConfirmAlert(self, title: "提示", cancelButtonTitle: "取消", confirmButtonTitle: "充值", message: "当前积分不足，请充值", confirmCompletion: { _ in
                                    guard let vc = AOLinkedStoryboardSegue.sceneNamed("ChargePoints@MerchantCenter") as? ChargePointsViewController else {return}
                                    self.navigationController?.pushViewController(vc, animated: true)                                    
                                })
                            })
                        } else if self.currentPage == 0 {
                            Utility.showAlert(self, message: msg)
                        }
                    }
                }
                return
            } else {
                if self.currentPage < 2 {
                    self.currentPage += 1
                } else if self.currentPage == 2 {
                    if confirm {
                        AOLinkedStoryboardSegue.performWithIdentifier("ObjectReleaseSucceed@Product", source: self, sender: nil)
                    } else {
                        if self.modifyType == .edit {
                            self.requestSendAD(true)
                            return
                        }
                        if let dic = object as? [String: Any], let point = dic["point_cost"] as? String {
                            let msg = String(format: "此次发布将扣除%@积分，确定发布？", point)
                            Utility.showConfirmAlert(self, message: msg, confirmCompletion: {
                                // 。。。走到这一步 积分 足够了
                                    self.requestSendAD(true)
                            })
                        }
                    }
                }
            }
        }
    }

}

extension AdAddNewViewController {
    /// 广告封面
    func cellCover(_ cell: UITableViewCell) {
        if (!adDetailModel.cover.isEmpty) || imageData != nil {
            guard let _cell = cell as? RightImageTableViewCell else {return}
            _cell.leftTxtLabel.text = "广告封面"
            if let imageData = imageData {
                _cell.rightImageView.image = UIImage(data: imageData)
            } else {
                if !adDetailModel.cover.isEmpty {
                    _cell.rightImageView.sd_setImage(with: URL(string: adDetailModel.cover))
                }
            }
        } else {
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "广告封面"
            _cell.rightTxtField.placeholder = ""
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            _cell.accessoryType = .disclosureIndicator
        }
    }
    
    ///广告标题
    func cellTitle(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
        _cell.leftTxtLabel.text = "广告标题"
        if !adDetailModel.title.isEmpty {
            _cell.rightTxtField.textColor = UIColor.black
            _cell.rightTxtField.text = self.adDetailModel.title
        } else {
            _cell.rightTxtField.placeholder = "请输入广告标题"
        }
        _cell.accessoryType = .disclosureIndicator
        
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.isUserInteractionEnabled = false
                _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.isUserInteractionEnabled = true
                _cell.rightTxtField.textColor = UIColor.black
            }
        }
    }
    
    /// 广告描述
    func cellDetail(_ cell: UITableViewCell) {
        guard let _cell = cell as? NormalDescTableViewCell else {return}
        _cell.txtLabel.textColor = UIColor.gray
        if !adDetailModel.detail.isEmpty {
            _cell.txtLabel?.text = self.adDetailModel.detail
            _cell.txtLabel?.textColor = UIColor.black
        } else {
            _cell.txtLabel.text = "请输入广告描述"
            _cell.txtLabel.textColor = UIColor.textfieldPlaceholderColor()
        }
        _cell.accessoryType = .disclosureIndicator
    }
    
    /// 广告类型
    func cellType(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else {return}
        _cell.accessoryType = .disclosureIndicator
        switch adType {
        case .picture:
            _cell.leftTxtLabel.text = "广告图片"
            _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
            if !adDetailModel.imgAdUrl.isEmpty {
                _cell.rightTxtLabel.text = "\(self.adDetailModel.imgAdUrl.count)"
                _cell.rightTxtLabel.textColor = UIColor.black
            } else {
                _cell.rightTxtLabel.text = "点击添加图片"
                _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
            }
        case .movie:
            _cell.leftTxtLabel.text = "广告视频"
            _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            if !adDetailModel.videoAdUrl.isEmpty {
                _cell.rightTxtLabel.text = "已添加"
                _cell.rightTxtLabel.textColor = UIColor.black
            } else {
                _cell.rightTxtLabel.text = "点击添加地址"
                _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
            }
        case .webpage:
            _cell.leftTxtLabel.text = "广告网页"
            if !adDetailModel.webAdUrl.isEmpty {
                _cell.rightTxtLabel.text = "已添加"
                _cell.rightTxtLabel.textColor = UIColor.black
            } else {
                _cell.rightTxtLabel.text = "点击添加地址"
                _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
            }
        }
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.rightTxtLabel.textColor = UIColor.black
            }
        }
    }
    
    /// 广告结束时间
    func cellCloseTime(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else {return}
        _cell.leftTxtLabel.text = "结束时间"
        _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
        _cell.isEditableColor = !(modifyType == .edit)
        _cell.isUserInteractionEnabled = !(modifyType == .edit)
        if isEditDraftAd  && modifyType == .edit {
            _cell.isUserInteractionEnabled = true
        }
        if !adDetailModel.endTime.isEmpty {
            _cell.rightTxtLabel.text = self.adDetailModel.endTime
        } else {
            _cell.rightTxtLabel.text = "请选择"
            _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
        }
        _cell.accessoryType = .disclosureIndicator
        
    }
    
    /// 用户参与方式
    func cellWay(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else {return}
        _cell.leftTxtLabel.text = "用户参与方式"
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.text = "问答"
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    /// 提示
    func cellPrompt(_ cell: UITableViewCell) {
        guard let _cell = cell as? NormalDescTableViewCell else {return}
        _cell.accessoryType = .disclosureIndicator
        _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.txtLabel.text = "请输入问题内容"
        if !adDetailModel.question.isEmpty {
            _cell.txtLabel.text = self.adDetailModel.question
        }
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.txtLabel.textColor = UIColor.black
            }
        } else {
            if !adDetailModel.question.isEmpty {
                _cell.txtLabel?.textColor = UIColor.black
            }
        }
    }
    
    /// 答案A
    func cellAnswerA(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案A(必填)"
        _cell.selectionChangeBlock = calculate
        _cell.maxCharacterCount = 14
        _cell.config(self.adDetailModel.answer.answerA)
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        } else {
            if adDetailModel.answer.answerA.text.isEmpty {
                _cell.detailTxtView.text = "设置答案"
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        }
    }
    
    /// 答案B
    func cellAnswerB(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案B(必填)"
        _cell.selectionChangeBlock = calculate
        _cell.maxCharacterCount = 14
        _cell.config(self.adDetailModel.answer.answerB)
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        } else {
            if adDetailModel.answer.answerB.text.isEmpty {
                _cell.detailTxtView.text = "设置答案"
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        }
    }
    
    /// 答案C
    func cellAnswerC(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案C"
        _cell.selectionChangeBlock = calculate
        _cell.maxCharacterCount = 14
        _cell.config(self.adDetailModel.answer.answerC)
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        } else {
            if adDetailModel.answer.answerC.text.isEmpty {
                _cell.detailTxtView.text = "设置答案"
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        }
    }
    
    /// 答案D
    func cellAnswerD(_ cell: UITableViewCell) {
        guard let _cell = cell as? AdAddAnswerTableViewCell else {return}
        _cell.selectionStyle = UITableViewCellSelectionStyle.none
        _cell.isRight = false
        _cell.leftTxtLabel.text = "答案D"
        _cell.selectionChangeBlock = calculate
        _cell.maxCharacterCount = 14
        _cell.config(self.adDetailModel.answer.answerD)
        if modifyType == .edit {
            if self.adDetailModel.status == .inProgress {
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        } else {
            if adDetailModel.answer.answerD.text.isEmpty {
                _cell.detailTxtView.text = "设置答案"
                _cell.detailTxtView.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.detailTxtView.textColor = UIColor.black
            }
        }
    }
    
    /// 奖励积分
    func cellPoint(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
        _cell.txtFieldEnabled = true
        _cell.rightTxtField.placeholder = "请输入正确奖励积分"
        _cell.rightTxtField.textColor = UIColor.commonTxtColor()
        _cell.leftTxtLabel.text = "回答正确奖励积分"
        _cell.rightTxtField.text = self.adDetailModel.point
        _cell.rightTxtField.keyboardType = .numberPad
        _cell.endEditingBlock = {(textFiled) -> Void in
            guard let text = textFiled.text else {return}
            self.adDetailModel.point = text
        }
    }
    
    /// 积分上限
    func cellPointLimitPerday(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
        _cell.txtFieldEnabled = true
        _cell.rightTxtField.placeholder = "请输入每日积分使用上限"
        _cell.rightTxtField.textColor = UIColor.commonTxtColor()
        _cell.leftTxtLabel.text = "每日积分使用上限"
        _cell.rightTxtField.text = self.adDetailModel.pointLimitPerday
//        _cell.isEditableColor = !(modifyType == .edit)
//        _cell.rightTxtField.isUserInteractionEnabled = !(modifyType == .edit)
        _cell.rightTxtField.keyboardType = .numberPad
        _cell.endEditingBlock = {(textFiled) -> Void in
            guard let text = textFiled.text else {return}
            self.adDetailModel.pointLimitPerday = text
        }
    }
}
extension AdAddNewViewController: GoNextOrPreviousStep {
    func goNextOrPrevious(next: Bool) {
        if next {
            if currentPage == 0 {
                if !validateDetail() {
                    return
                }
                requestSendAD()
            } else if currentPage == 1 {
                if !validateQuestion() {
                    return
                }
                requestSendAD()
            } else {
                if !validatePoint() {
                    return
                }
                requestSendAD()
            }
        } else {
            if currentPage == 0 {
                _ = navigationController?.popViewController(animated: true)
            } else {
                currentPage -= 1
            }
        }
    }
}

extension AdAddNewViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case self.tableView:
            return 5
        case self.tableView2:
            return 3
        case self.tableView3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView, section) {
        case (tableView2, 2):
            return 4
        case (tableView3, _):
            return 2
        default:
            return 1
        
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView, indexPath.section, indexPath.row) {
        case (self.tableView, 0, _):
            if (!adDetailModel.cover.isEmpty) || imageData != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        case (self.tableView, 1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case (self.tableView, 2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case (self.tableView2, 1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case (self.tableView2, 2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdAddAnswerTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        case (self.tableView3, 0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AdAddNewViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tableView2 {
            if section == 1 {
                return 35
            }
            if section == 2 {
                return 35
            }
        }
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            if section == 0 {
                return 35
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (tableView, indexPath.section) {
        case (self.tableView, 2):
            return 85
        case (tableView2, 1):
            return 68
        case (tableView2, 2):
            return 70
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView2 {
            if section == 1 {
                let attrLabel = UILabel(frame: CGRect(x: 10, y: 15, width: screenWidth, height: 15))
                attrLabel.text = "设置问题"
                attrLabel.font = UIFont.systemFont(ofSize: 13)
                attrLabel.textColor = UIColor.commonGrayTxtColor()
                let attrBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                attrBg.addSubview(attrLabel)
                return attrBg
            }
            if section == 2 {
                let attrLabel = UILabel(frame: CGRect(x: 10, y: 15, width: screenWidth, height: 15))
                attrLabel.text = "设置问题答案, 标准答案请打勾"
                attrLabel.font = UIFont.systemFont(ofSize: 13)
                attrLabel.textColor = UIColor.commonGrayTxtColor()
                let attrBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                attrBg.addSubview(attrLabel)
                return attrBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            if section == 0 {
                let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
                btn.setAttributedTitle(attrTxt, for: UIControlState())
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            switch (indexPath.section, indexPath.row) {
            case (0, _): cellCover(cell)
            case (1, _): cellTitle(cell)
            case (2, _): cellDetail(cell)
            case (3, 0): cellType(cell)
            case (4, 0): cellCloseTime(cell)
            default: break
            }
        } else if tableView == tableView2 {
            
            switch (indexPath.section, indexPath.row) {
            case (0, _):
                cellWay(cell)
            case (1, _):
               cellPrompt(cell)
            case (2, _):
                switch indexPath.row {
                case 0:
                    cellAnswerA(cell)
                case 1:
                    cellAnswerB(cell)
                case 2:
                    cellAnswerC(cell)
                case 3:
                    cellAnswerD(cell)
                default:
                    break
                }
            default:
                break
            }
        } else {
            
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                cellPoint(cell)
            case (0, 1):
                cellPointLimitPerday(cell)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !kApp.pleaseAttestationAction(showAlert: true, type: .publish) {
            return
        }
        switch (currentPage, indexPath.section, indexPath.row) {
        case (0, 0, 0):
            showAddPhotoAlertController()
        case (0, 1, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
        case (0, 2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath)
        case (0, 3, 0):
        
            switch adType {
            case .picture:
                let photoVC = AddPhotoViewController(nibName: "AddPhotoViewController", bundle: nil)
                photoVC.photosUrlArray = self.adDetailModel.imgAdUrl
                photoVC.completeBlock = { imgUrls in
                    self.adDetailModel.imgAdUrl = imgUrls
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(photoVC, animated: true)
            case .movie:
                AOLinkedStoryboardSegue.performWithIdentifier("AdAddMovie@Ad", source: self, sender: indexPath)
            case .webpage:
                AOLinkedStoryboardSegue.performWithIdentifier("AdAddMovie@Ad", source: self, sender: indexPath)
            }
            
        case (0, 4, 0):
            let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
            navigationController?.pushViewController(timeVC, animated: true)
            timeVC.navTitle = "结束时间"
            Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: adDetailModel.endTime)
            timeVC.completeBlock = {(date) -> Void in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                self.adDetailModel.endTime = formatter.string(from: date as Date)
                self.tableView.reloadData()
            }
        case (1, 1, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (1, 2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (1, 2, 1):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (1, 2, 2):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (1, 2, 3):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        default:
            break
        }
        
    }
}

extension AdAddNewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView2 {
            let sectionHeaderHeight: CGFloat = 35 //header高度
            if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            } else if scrollView.contentOffset.y >= sectionHeaderHeight {
                scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
            }
        }
    }
}

extension AdAddNewViewController {
    func reqUserInfo() {
       let info = Int(UserManager.sharedInstance.userInfo?.point ?? "0")
        self.currentPoint = info ?? 0
    }
    // 获取时间差
    func getTwoDatePoor(starTime: String, endTime: String) -> Int {
        let time1 = (starTime as NSString).substring(to: 10)
        let time2 = (endTime as NSString).substring(to: 10)
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let seconds = 86400
        let firstDate = fmt.date(from: time1)
        let cecondDate = fmt.date(from: time2)
        let interval = cecondDate?.timeIntervalSince(firstDate!)
        guard let inter = interval else {
            return 0
        }
        let time = Int(inter)
        return (time/seconds)+1
    }
}
