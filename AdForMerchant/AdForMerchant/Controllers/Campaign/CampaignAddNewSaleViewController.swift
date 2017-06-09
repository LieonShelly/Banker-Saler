//
//  CampaignAddNewSaleViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
import ObjectMapper
import ALCameraViewController

class CampaignAddNewSaleViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableView2: UITableView!
    
    @IBOutlet fileprivate weak var tbvLeadingCons: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tbvWidthCont: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var stepViewBg: UIView!
    fileprivate var stepPageCtrl: StepPageControl!
    
    @IBOutlet fileprivate weak var goNextStepView: GoNextStepView!
    
    internal var modifyType: ObjectModifyType = .addNew
    var copyCampInfoID: Int = 0
    internal var campInfo: CampaignInfo!
    internal var status: CampaignStatus?
    fileprivate var releasedStatus: CampaignStatus?
    fileprivate var unEditCamInfo: CampaignInfo?
    fileprivate var campaignCoverImg: UIImage?

    var currentPage: Int = 0 {
        didSet {
            changePageStyle()
            moveToPageIndex(self.currentPage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goNextStepView.delegate = self
        
        stepPageCtrl = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        stepPageCtrl.stepTitleArray = ["编辑基本信息", "设置活动规则"]
        stepViewBg.addSubview(stepPageCtrl)
        switch modifyType {
        case .addNew, .copy:
            navigationItem.title = "新建促销活动"
            campInfo = CampaignInfo()
            stepPageCtrl.showDashLine()
            
        case (.edit):
            navigationItem.title = "编辑促销活动"
            requestCampaignInfo()
        }
        if modifyType == .copy {
            requestCampaignInfo()
        }
        let leftBarItem = UIBarButtonItem(title:"取消", style: .plain, target: self, action: #selector(self.backAlertAction))
        navigationItem.leftBarButtonItem = leftBarItem
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView2.backgroundColor = UIColor.commonBgColor()
        
        changePageStyle()
        
        for table in [tableView, tableView2] {
            table?.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
            table?.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
            table?.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
            table?.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
            table?.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if modifyType != .copy {
            tableView.reloadData()
            tableView2.reloadData()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tbvWidthCont.constant = self.view.frame.size.width
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObjectReleaseSucceed@Product" {
            guard let desVC = segue.destination as? ObjectReleaseSucceedViewController else {return}
            if modifyType == .edit {
                desVC.navTitle = "编辑活动"
                desVC.desc = "活动编辑成功，可直接在活动列表查看"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.sale.rawValue, "CampaignStatus": self.releasedStatus?.rawValue ?? CampaignStatus.notBegin.rawValue])
                }
            } else {
            
                desVC.navTitle = "发布活动"
                desVC.desc = "活动发布完成，待平台审核"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.sale.rawValue, "CampaignStatus": self.releasedStatus?.rawValue ?? CampaignStatus.inReview.rawValue])
                }
            }
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController {
           
            if currentPage == 0 {
                desVC.type = .campaignNote
                desVC.dataArray = campInfo.notes.map { return ($0.name, $0.content)}
                desVC.completeBlock = { noteArray in
                    self.campInfo.notes = noteArray.map {
                        CampaignNote(name: $0, content: $1)
                    }
                    self.tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
                }
                if status == .inProgress {
                    desVC.canEdit = false
                }
            } else if currentPage == 1 {
                desVC.maxNumber = 5
                desVC.maxNumberAlert = "最多只能创建5条规则"
                desVC.type = .coupon
                desVC.dataArray = campInfo.couponRule.map { return ($0.totalAmount, $0.discountAmount)}
                desVC.completeBlock = { ruleArray in
                    self.campInfo.couponRule = ruleArray.map {
                        CouponRule(totalAmount: $0, discountAmount: $1)
                    }
                    self.tableView2.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
                if status == .inProgress {
                    desVC.canEdit = false
                }
            }
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController {
            let inputType = DetailInputType(rawValue: (sender as? Int) ?? 0) ?? .undefined
            switch inputType {
            case .title:
                desVC.navTitle = "输入活动名称"
                desVC.placeholder = "请输入简洁有特色的活动名称(限30字)"
                desVC.txt = campInfo.title
                desVC.maxCharacterLimit = 30
                desVC.completeBlock = {text in
                    self.campInfo.title = text
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                if status == .inProgress {
                    desVC.canEdit = false
                }
            case .description:
                desVC.navTitle = "输入活动描述"
                desVC.maxCharacterLimit = 1000
                desVC.placeholder = "活动说明、特色…详细的描述能使您的活动更撩人哦~（1000字以内）"
                desVC.txt = campInfo.detail
                desVC.completeBlock = {text in
                    self.campInfo.detail = text
                 self.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                }
            default:
                break
            }
        } else if segue.identifier == "CampaignAddRelatedProducts@Campaign", let _ = segue.destination as? CampaignAddRelatedProductsViewController {
        }
    }
}

extension CampaignAddNewSaleViewController {
    func showHelpPage() {
        guard  let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch modifyType {
        case .addNew, .copy:
            helpWebVC.requestURL = WebviewHelpDetailTag.saleCampaignAddNav.detailUrl
        case .edit:
            helpWebVC.requestURL = WebviewHelpDetailTag.saleCampaignEditNav.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func showCoverHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch modifyType {
        case .addNew, .copy:
            helpWebVC.requestURL = WebviewHelpDetailTag.saleCampaignAddCover.detailUrl
        case .edit:
            helpWebVC.requestURL = WebviewHelpDetailTag.saleCampaignEditCover.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
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
            
            navigationItem.rightBarButtonItem = nil
        case 1:
            tableView.isHidden = true
            if modifyType == .addNew || modifyType == .copy {
                goNextStepView.nextStepButtonTitle = "提交审核"
            } else {
                goNextStepView.nextStepButtonTitle = "提交审核"
            }
            goNextStepView.animateOnlyNextStep = false
            
            let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
            navigationItem.rightBarButtonItem = rightBarItem
        default:
            break
        }
    }
    
    func showDraftAlert() {
        let alert = UIAlertController(title: "温馨提示", message: "是否保存为草稿", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            self.saveSaleCampaginAsDraft()
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
            handleSaveNewSaleCampaignAsDraft()
        }
        if  modifyType == .edit {
            handleSaveEditSaleCampaignAsDraft()
        }
    }
    
    func handleSaveNewSaleCampaignAsDraft() {
        if isNeedSaveNewSaleCampaign() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func handleSaveEditSaleCampaignAsDraft() {
        if isNeedSaveEditSaleCampaign() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveSaleCampaginAsDraft() {
        var param = createRequstParams()
        param["is_approved"] = 3
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventSave(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, message) -> Void in
            Utility.hideMBProgressHUD()
            if error != nil {
               Utility.showAlert(self, message: message ?? "")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.sale.rawValue, "CampaignStatus": CampaignStatus.draft.rawValue])
            }

        }
    }
    
    func createRequstParams() -> [String: Any] {
        var parameters: [String: Any] = [
            "cat": 1,
            "type": 1,
            "title": campInfo.title,
            "cover": campInfo.cover,
            "detail": campInfo.detail,
            "start_time": campInfo.startTime,
            "end_time": campInfo.endTime,
            "max_num": campInfo.maxNumb,
            "point": campInfo.point,
            "add_id": campInfo.addressId,
            "notes": campInfo.notes.toJSON()
        ]
        
        parameters["rule"] = ["reach_then_minus": campInfo.couponRule.toJSON()]
//        parameters["event_goods_config_id"] = campInfo.eventGoodsConfigID
        
        if campInfo.id != 0 && modifyType != .copy {
            parameters["event_id"] = campInfo.id
        }
        return parameters
    }
    
    func isNeedSaveNewSaleCampaign() -> Bool {
        return campInfo.canBeDraft
    }
    
    func isNeedSaveEditSaleCampaign() -> Bool {
        if unEditCamInfo == campInfo {
            return false
        } else {
          return true
        }
        
    }
    
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
        
    func firstPageParameterValidate() -> Bool {
        
        guard !campInfo.cover.isEmpty else {
            Utility.showAlert(self, message: "请上传活动封面")
            return false
        }
        guard !campInfo.title.isEmpty else {
            Utility.showAlert(self, message: "请填写活动名称")
            return false
        }
        guard campInfo.title.characters.count <= 30 else {
            Utility.showAlert(self, message: "活动名称应该是30个字以内汉字、英文字母或数字组成")
            return false
        }
        guard !campInfo.detail.isEmpty else {
            Utility.showAlert(self, message: "请填写活动描述")
            return false
        }
        
        Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let startTime = Utility.sharedInstance.dateFormatter.date(from: campInfo.startTime) else {
            Utility.showAlert(self, message: "请设置活动开始时间")
            return false
        }
        guard let endTime = Utility.sharedInstance.dateFormatter.date(from: campInfo.endTime) else {
            Utility.showAlert(self, message: "请设置活动结束时间")
            return false
        }
        
        if startTime.compare(endTime) != .orderedAscending {
            Utility.showAlert(self, message: "开始时间必须早于结束时间")
            return false
        }
        return true
    }
    
    func secondPageParameterValidate() -> Bool {
        
        guard !campInfo.couponRule.isEmpty else {
            Utility.showAlert(self, message: "请设置满减规则")
            return false
        }
        if campInfo.eventGoodsNumb == 0 {
            Utility.showAlert(self, message: "请选择关联商品")
            return false
        }
        return true
    }
    
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
                    self.campaignCoverImg = image
                    self.dismiss(animated: true, completion: {
                        self.uploadImage()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(libraryViewController, animated: true, completion: nil)
        case .camera:
            let cameraViewController = CameraViewController.imagePickerViewController(croppingRatio: 1.0/1.34) { image, asset in
                if let image = image {
                    self.campaignCoverImg = image
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
    
    func commitAction() {
        if firstPageParameterValidate() == false {
            return
        }
        
        requestAddNewSaleCampaign()
        
    }
    
    // MARK: - HTTP request
    
    func uploadImage() {
        guard let img = campaignCoverImg else {
            return
        }
        guard let imageData = UIImageJPEGRepresentation(img, 0.8) else { return }
        let parameters: [String: Any] = [
            "cover": imageData,
            "prefix[cover]": "event/cover"
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else { return }
                guard let photoUploadedArray = result["success"] as? [AnyObject] else { return }
                if let photoInfo = photoUploadedArray.first, let imgUrl = photoInfo["url"] as? String {
                    //                    self.requestVerifyLicense(licenseImgUrl)
                    self.campInfo.cover = imgUrl
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
    
    func requestAddNewSaleCampaign() {
        var parameters: [String: Any] = [
            "cat": 1,
            "type": 1,
            "title": campInfo.title,
            "cover": campInfo.cover,
            "detail": campInfo.detail,
            "start_time": campInfo.startTime,
            "end_time": campInfo.endTime,
            "max_num": campInfo.maxNumb,
            "point": campInfo.point,
            "add_id": campInfo.addressId,
            "notes": campInfo.notes.toJSON()
        ]
        
        parameters["rule"] = ["reach_then_minus": campInfo.couponRule.toJSON()]
        parameters["event_goods_config_id"] = campInfo.eventGoodsConfigID
        
        if currentPage == 0 {
            parameters["step"] = 1
        }
        
        if campInfo.id != 0 && modifyType != .copy {
            parameters["event_id"] = campInfo.id
        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
                print(parameters)
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventSave(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                if self.currentPage == 0 {
                    self.currentPage += 1
                    return
                }
                
                guard let result = object as? [String: Any] else {return }
                if result["event_id"] as? String != nil, let status = result["status"] as? String {
                    self.releasedStatus = CampaignStatus(rawValue: status)
                    AOLinkedStoryboardSegue.performWithIdentifier("ObjectReleaseSucceed@Product", source: self, sender: nil)
                }
            } else {
                Utility.hideMBProgressHUD()
                if let msg = error?.userInfo["message"] as? String {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
    
    func requestCampaignInfo() {
        
        var  parameters: [String: Any] = [:]
        if  modifyType == .copy {
            parameters["event_id"] = copyCampInfoID
            } else {
            parameters["event_id"] = campInfo.id
        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, msg) -> Void in
            if let msg = msg, !msg.isEmpty {
                Utility.showAlert(self, message: msg)
                return
            }
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: AnyObject] else {
                    return
                }
                guard let campInfo = Mapper<CampaignInfo>().map(JSON: result) else {
                    return
                }
                if self.modifyType == .edit {
                    self.unEditCamInfo = Mapper<CampaignInfo>().map(JSON: result) ?? CampaignInfo()
                }
                self.campInfo = campInfo
                self.tableView.reloadData()
                self.tableView2.reloadData()
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
}

// MARK: - Go Next Or Previous Step
extension CampaignAddNewSaleViewController: GoNextOrPreviousStep {
    func goNextOrPrevious(next: Bool) {
        if next {
            if currentPage < 1 {
                if firstPageParameterValidate() {
                    commitAction()
                }
            } else if currentPage == 1 {
                if modifyType == .edit {
                     guard let st = status else { return  }
                    switch st {
                    case .over:
                        _ = navigationController?.popViewController(animated: true)
                        return
                    default:
                        break
                    }
                }
                if secondPageParameterValidate() {
                    commitAction()
                }
            } else {
                _ = navigationController?.popViewController(animated: true)
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

extension CampaignAddNewSaleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            switch modifyType {
            case .addNew, .copy:
                return 6
            case .edit:
                return 7
            }
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            switch (modifyType, section) {
            case (.addNew, 5), (.copy, 5):
                return 2
            case (.edit, 0):
                return 0
            case (.edit, 6):
                return 2
            default:
                return 1
            }
        } else {
            switch section {
            default:
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            switch (modifyType, indexPath.section, indexPath.row) {
            case (.edit, 0, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (.addNew, 0, _), (.copy, 0, _), (.edit, 1, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
                return cell
            case (.addNew, 1, _), (.copy, 1, _), (.edit, 2, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
                return cell
            case (.addNew, 2, _), (.copy, 2, _), (.edit, 3, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .none
                return cell
            case (.addNew, 3, _), (.copy, 3, _), (.edit, 4, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
}

extension CampaignAddNewSaleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        case 1:
            if modifyType == .edit {
                return CGFloat.leastNormalMagnitude
            }
            return 10
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            switch (modifyType, section) {
            case (.addNew, 0), (.copy, 0), (.edit, 1):
                return 35
            default:
                return CGFloat.leastNormalMagnitude
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            switch (modifyType, indexPath.section) {
            case (.addNew, 3), (.copy, 3):
                return 86
            case (.edit, 4):
                return 86
            default:
                return 46
            }
        }
        return 46
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            switch (modifyType, section) {
            case (.addNew, 0), (.copy, 0), (.edit, 1):
                let attrTxt = NSAttributedString(string: "需要帮助？", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
                btn.setAttributedTitle(attrTxt, for: UIControlState())
                btn.addTarget(self, action: #selector(self.showCoverHelpPage), for: .touchUpInside)
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            default:
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
                return titleBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none         
        if tableView == self.tableView {
            switch (modifyType, indexPath.section, indexPath.row) {
            case (.edit, 0, _):
             guard let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动状态"
                _cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
             if campInfo.isApproved == .approved {
                     _cell.rightTxtLabel.text = status!.desc
             } else {
                 _cell.rightTxtLabel.text = campInfo.isApproved.desc
                }
            case (.addNew, 0, _), (.copy, 0, _), (.edit, 1, _):
               guard let _cell = cell as? RightImageTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动封面"
                if !campInfo.cover.isEmpty {
                    _cell.rightImageView.sd_setImage(with: URL(string: campInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
                }
            case (.addNew, 1, _), (.copy, 1, _), (.edit, 2, _):
                cell.accessoryType = .disclosureIndicator
               guard let _cell = cell as? RightTxtFieldTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动名称"
                _cell.rightTxtField.placeholder = "请输入简洁有特色的活动名称"
                _cell.rightTxtField.text = campInfo.title
                if modifyType == .edit {
                    _cell.accessoryType = .none
                }
                if status == .inProgress {
                    _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtField.textColor = UIColor.commonTxtColor()
                }
            case (.addNew, 2, _), (.copy, 2, _), (.edit, 3, _):
               guard let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动类型"
                _cell.rightTxtLabel.text = "满减"
                _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
            case (.addNew, 3, _), (.copy, 3, _), (.edit, 4, _):
              guard  let _cell = cell as? NormalDescTableViewCell else { return  }
                if campInfo.detail.isEmpty {
                    _cell.txtLabel.text = "活动说明、特色…详细的描述能使您的活动更撩人哦~（1000字以内）"
                    _cell.txtLabel.textColor = UIColor.textfieldPlaceholderColor()
                } else {
                    _cell.txtLabel.text = campInfo.detail
                    _cell.txtLabel.textColor = UIColor.commonTxtColor()
                }
            case (.addNew, 4, 0), (.copy, 4, _), (.edit, 5, 0):
               guard let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动须知"
                _cell.rightTxtLabel.text = "\(campInfo.notes.count)"
                if status == .inProgress {
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                
                if modifyType == .edit && campInfo.notes.isEmpty {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
                
            case (.addNew, 5, 0), (.copy, 5, 0), (.edit, 6, 0):
                
               guard let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动开始时间"
                cell.accessoryType = .disclosureIndicator
                if campInfo.startTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.startTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                if modifyType == .edit {
                    if status == .inProgress {
                        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                        cell.accessoryType = .none
                    } else {
                        _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                        cell.accessoryType = .disclosureIndicator
                    }
                }
                
            case (.addNew, 5, 1), (.copy, 5, 1), (.edit, 6, 1):
              guard  let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "活动结束时间"
                cell.accessoryType = .disclosureIndicator
                if campInfo.endTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.endTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                if modifyType == .edit {
                    if status == .inProgress {
                        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                        cell.accessoryType = .none
                    } else {
                        _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                        cell.accessoryType = .disclosureIndicator
                    }
                }
            default:
                break
            }
        } else {
            
            switch (indexPath.section, indexPath.row) {
            case (0, _):
              guard  let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "设置满减规则"
                let count = campInfo.couponRule.count
                _cell.rightTxtLabel.text = "\(count)"
                
                if status == .inProgress {
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                
                if status == .inProgress && campInfo.couponRule.isEmpty {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
                
            case (1, _):
             guard   let _cell = cell as? DefaultTxtTableViewCell else { return  }
                _cell.leftTxtLabel.text = "设置满减商品"
                let count = campInfo.eventGoodsNumb
                _cell.rightTxtLabel.text = "\(count)"
                _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                cell.accessoryType = .disclosureIndicator

            default:
                break
            }
//            return 45
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !kApp.pleaseAttestationAction(showAlert: true, type: .publish) {
            return
        }
        if modifyType == .edit {
            switch status! {
            case .over:
                return
            default:
                break
            }
        }
        
        if currentPage == 0 {
            switch (modifyType, indexPath.section, indexPath.row) {
            case (.addNew, 0, 0), (.copy, 0, 0), (.edit, 1, 0):
                showAddPhotoAlertController()
            case (.addNew, 1, 0), (.copy, 1, 0), (.edit, 2, 0):
                if modifyType == .addNew || modifyType == .copy || status == .draft {
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: DetailInputType.title.rawValue as AnyObject?)
                }
            case (.addNew, 2, 0), (.copy, 2, 0), (.edit, 3, 0):
                break
            case (.addNew, 3, 0), (.copy, 3, 0), (.edit, 4, 0):
                AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: DetailInputType.description.rawValue as AnyObject?)
            case (.addNew, 4, 0), (.copy, 4, 0), (.edit, 5, 0):
                if status == .inProgress && campInfo.notes.isEmpty {
                    break
                }
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath as AnyObject?)
            case (.addNew, 5, 0), (.copy, 5, 0),
                 (.edit, 6, 0) where status != .inProgress:
                let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
                timeVC.isEndTime = false
                Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.startTime)
                timeVC.completeBlock = {date in
                    self.campInfo.startTime = date.toString("yyyy-MM-dd HH:mm")
                    self.tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
                }
                navigationController?.pushViewController(timeVC, animated: true)
            case (.addNew, 5, 1), (.copy, 5, 1),
                 (.edit, 6, 1) where status != .inProgress:
                
                let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
                Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.endTime)
                timeVC.completeBlock = {date in
                    self.campInfo.endTime = date.toString("yyyy-MM-dd HH:mm")
                    self.tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
                }
                navigationController?.pushViewController(timeVC, animated: true)
                
            default:
                break
            }
        } else if currentPage == 1 {
            switch (indexPath.section, indexPath.row) {
            case (0, 0):
                if status == .inProgress && campInfo.couponRule.isEmpty {
                    break
                }
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: nil)
            case (1, 0):
                pushtoChooseItemVC()
            default:
                break
            }
        }
    }
    
    fileprivate  func pushtoChooseItemVC( ) {
        let destVC = CampaignChooseViewController()
        if !campInfo.eventGoodsConfigID.isEmpty {
            destVC.previousSelectedConfigIDs = campInfo.eventGoodsConfigID
        }
        destVC.choosedgoodsConfigIDsCallBack = {[unowned self] goodsConfigIDs, goodsNum in
            self.campInfo.eventGoodsNumb = goodsNum
            self.campInfo.eventGoodsConfigID = goodsConfigIDs
            self.tableView2.reloadSections(IndexSet(integer: 1), with: .automatic)
//            print("pushtoChooseItemVC\(self.campInfo.eventGoodsConfigID)")
        }
        navigationController?.pushViewController(destVC, animated: true)
    }
}
