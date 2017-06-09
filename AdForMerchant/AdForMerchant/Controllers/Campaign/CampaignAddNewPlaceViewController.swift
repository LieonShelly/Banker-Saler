//
//  CampaignAddNewPlaceViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/17/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit
import ObjectMapper
import ALCameraViewController

class CampaignAddNewPlaceViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var bottomBtnBottomConstr: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomBtn: UIButton!
    
    internal var modifyType: ObjectModifyType = .addNew
    
    internal var campInfo: PlaceCampaignInfo!
    internal var status: CampaignStatus?
    fileprivate var unEditCaminfo: PlaceCampaignInfo?
    fileprivate var campaignCoverImg: UIImage?
    fileprivate var originalPointPerPerson: Int?
    fileprivate var originalParticipatorCount: Int?
    
    fileprivate var agreementSelected: Bool = true
    var deductionPoints = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAlertAction))
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(title: "帮助", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showHelpPage))
        navigationItem.rightBarButtonItem = rightBarItem
        
        refreshPageStyle()
        
        tableView.backgroundColor = UIColor.commonBgColor()
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        bottomBtn.setTitle("提交审核", for: UIControlState())
        bottomBtn.addTarget(self, action: #selector(self.commitAction), for: .touchUpInside)
        
        if modifyType == .addNew {
            campInfo = PlaceCampaignInfo()
        } else {
            requestCampaignInfo()
            originalPointPerPerson = campInfo.point
            originalParticipatorCount = campInfo.maxNumb
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObjectReleaseSucceed@Product", let desVC = segue.destination as? ObjectReleaseSucceedViewController {
           
            if modifyType == .edit {
                desVC.navTitle = "编辑活动"
                desVC.desc = "活动编辑成功，可直接在活动列表查看"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.place.rawValue, "CampaignStatus": CampaignStatus.notBegin.rawValue])
                }
            } else {
                desVC.navTitle = "发布活动"
                desVC.desc = "活动发布完成，待平台审核"
                desVC.completionBlock = {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.place.rawValue, "CampaignStatus": CampaignStatus.inReview.rawValue])
                }
            }
        } else if segue.identifier == "ProductDescInput@Product", let desVC = segue.destination as? DetailInputViewController, let indexPath = sender as? IndexPath {
            switch (indexPath.section, indexPath.row) {
            case (1, _):
                desVC.navTitle = "输入活动名称"
                desVC.placeholder = "请输入简洁有特色的活动名称(限30字)"
                desVC.maxCharacterLimit = 30
                desVC.txt = campInfo.title
                desVC.completeBlock = {text in self.campInfo.title = text}
                if status == .notBegin {
                    desVC.canEdit = false
                }
            case (2, _):
                desVC.navTitle = "输入活动描述"
                desVC.txt = campInfo.detail
                desVC.maxCharacterLimit = 1000
                desVC.placeholder = "活动说明、特色…详细的描述能使您的活动更撩人哦~（1000字以内）"
                desVC.completeBlock = {text in self.campInfo.detail = text}
            case (4, 2):
                desVC.navTitle = "输入活动地址"
                desVC.placeholder = "请输入(限100字)"
                desVC.txt = campInfo.addressDetail
                desVC.maxCharacterLimit = 100
                desVC.completeBlock = {text in self.campInfo.addressDetail = text}
                if status == .notBegin {
                    desVC.canEdit = false
                }
            default:
                break
            }
        } else if segue.identifier == "ProductAddAttribute@Product", let desVC = segue.destination as? ProductAddAttributeViewController {
            
            desVC.type = .campaignNote
            desVC.dataArray = campInfo.notes.map { return ($0.name, $0.content)}
            desVC.completeBlock = { noteArray in
                self.campInfo.notes = noteArray.map {
                    CampaignNote(name: $0, content: $1)
                }
            }
            if status == .notBegin {
                desVC.canEdit = false
            }
        }
    }
}

extension CampaignAddNewPlaceViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 3
        case 5:
            return 1
        case 6:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightImageTableViewCell", for: indexPath)
            return cell
        case (1, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        case (2, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalDescTableViewCell", for: indexPath)
            return cell
        case (3, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "CenterTxtFieldTableViewCell", for: indexPath)
            return cell
        case (3, _), (4, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            return cell
        case (5, _), (6, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTxtTableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    
    }
}

extension CampaignAddNewPlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
            } else if section == 3 {
                return 35
            } else if section == 6 {
                return 54
            }
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 55
        case 2:
            return 80
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
                btn.addTarget(self, action: #selector(self.showCoverHelpPage), for: .touchUpInside)
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            } else if section == 3 {
                let attrTxt = NSAttributedString(string: "ⓘ积分说明", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.commonBlueColor(), NSUnderlineStyleAttributeName: 1.0])
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: screenWidth - 100, y: 0, width: 100, height: 35)
                btn.setAttributedTitle(attrTxt, for: UIControlState())
                btn.addTarget(self, action: #selector(self.showPointHelpPage), for: .touchUpInside)
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
                titleBg.addSubview(btn)
                return titleBg
            } else if section == 6 {
                let agreementSelectedButton = UIButton(type: .custom)
                agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOff"), for: UIControlState())
                agreementSelectedButton.setImage(UIImage(named: "CellItemCheckmarkOn"), for: .selected)
                agreementSelectedButton.addTarget(self, action: #selector(self.selectAgreementAction(_:)), for: .touchUpInside)
                agreementSelectedButton.frame = CGRect(x: 0, y: 0, width: 44, height: 54)
                agreementSelectedButton.isSelected = agreementSelected
                
                let agreementDetailButton = UIButton(type: .custom)
                agreementDetailButton.frame = CGRect(x: 44, y: 8, width: 150, height: 40)
                agreementDetailButton.addTarget(self, action: #selector(self.showAgreementDetailAction(_:)), for: .touchUpInside)
                
                let text = "同意《活动发布协议》" as NSString
                
                let attrText = NSMutableAttributedString(string: text as String)
                attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.commonBlueColor(), range: NSRange(location: 0, length: text.length))
                attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHex("#9498A9"), range: NSRange(location: 0, length: "同意".characters.count))
                attrText.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSRange(location: 0, length: text.length))
                agreementDetailButton.setAttributedTitle(attrText, for: UIControlState.normal)
                
                let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 54))
                titleBg.addSubview(agreementSelectedButton)
                titleBg.addSubview(agreementDetailButton)
                return titleBg
            }
        }
        let titleBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        return titleBg
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, _):
           guard let _cell = cell as? RightImageTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动封面"
            if !campInfo.cover.isEmpty {
                _cell.rightImageView.sd_setImage(with: URL(string: campInfo.cover), placeholderImage: UIImage(named: "ImageDefaultPlaceholderW55H50"))
            }
        case (1, _):
           guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动名称"
            _cell.rightTxtField.placeholder = "请输入简洁有特色的活动名称"
            _cell.rightTxtField.text = campInfo.title
            if status == .notBegin {
                _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
            }
            cell.accessoryType = .disclosureIndicator
        case (2, _):
           guard let _cell = cell as? NormalDescTableViewCell else { return }
            if campInfo.detail.isEmpty {
                _cell.txtLabel.text = "活动说明、特色…详细的描述能使您的活动更撩人哦~（1000字以内）"
                _cell.txtLabel.textColor = UIColor.textfieldPlaceholderColor()
            } else {
                _cell.txtLabel.text = campInfo.detail
                _cell.txtLabel.textColor = UIColor.commonTxtColor()
            }
            cell.accessoryType = .disclosureIndicator
        case (3, 0):
            
           guard let _cell = cell as? CenterTxtFieldTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动人数上限"
            _cell.centerTxtField.placeholder = "请设置人数上限"
            _cell.centerTxtField.keyboardType = .numberPad
            _cell.rightTxtLabel.text = "人"
            
            _cell.endEditingBlock = { text in
                if !text.isEmpty {
                    self.campInfo.maxNumb = Int(text) ?? 0
                } else {
                    self.campInfo.maxNumb = 0
                }
            }
            if campInfo.maxNumb != 0 {
                _cell.centerTxtField.text = "\(campInfo.maxNumb)"
            } else {
                _cell.centerTxtField.text = ""
            }
            
            if status == .notBegin || status == .inReview {
                _cell.centerTxtField.isUserInteractionEnabled = false
                _cell.centerTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.centerTxtField.isUserInteractionEnabled = true
                _cell.centerTxtField.textColor = UIColor.commonTxtColor()
            }
            
           if modifyType == .copy {
                _cell.centerTxtField.isUserInteractionEnabled = true
                _cell.centerTxtField.textColor = UIColor.commonTxtColor()
            }
        case (3, 1):
          guard  let _cell = cell as? RightTxtFieldTableViewCell else { return }
            _cell.leftTxtLabel.text = "单个赠予积分"
            _cell.rightTxtField.placeholder = "请输入积分"
            _cell.rightTxtField.keyboardType = .numberPad
            _cell.rightTxtField.text = "\(campInfo.point)"
            _cell.endEditingBlock = { textField in
                if textField.text != nil && !(textField.text ?? "").isEmpty {
                    self.campInfo.point = Int(textField.text ?? "0") ?? 0
                } else {
                    self.campInfo.point = 0
                }
            }
            if campInfo.point != 0 {
                _cell.rightTxtField.text = "\(campInfo.point)"
            } else {
                _cell.rightTxtField.text = ""
            }
            
            if status == .notBegin || status == .inReview {
                _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.rightTxtField.isUserInteractionEnabled = true
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
            }
          if modifyType == .copy {
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.textColor = UIColor.commonTxtColor()
            }
        case (4, 0):
          guard  let _cell = cell as? RightTxtFieldTableViewCell else { return }
            cell.accessoryType = .none
            _cell.leftTxtLabel.text = "联系人"
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = "请输入"
            _cell.rightTxtField.text = campInfo.addressContact
            _cell.maxCharacterCount = 13
            _cell.endEditingBlock = { textField in
                if textField.text != nil && !(textField.text ?? "").isEmpty {
                    self.campInfo.addressContact = textField.text ?? ""
                } else {
                    self.campInfo.addressContact = ""
                }
            }
            _cell.rightTxtField.textColor = UIColor.commonTxtColor()
        case (4, 1):
          guard  let _cell = cell as? RightTxtFieldTableViewCell else { return }
            cell.accessoryType = .none
            _cell.leftTxtLabel.text = "联系电话"
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.placeholder = "请输入"
            _cell.maxCharacterCount = 12
            _cell.rightTxtField.text = campInfo.addressTel
            _cell.rightTxtField.keyboardType = .numberPad
            _cell.endEditingBlock = { textField in
                if textField.text != nil && !(textField.text ?? "").isEmpty {
                    self.campInfo.addressTel = textField.text ?? ""
                } else {
                    self.campInfo.addressTel = ""
                }
            }
            _cell.rightTxtField.textColor = UIColor.commonTxtColor()
        case (4, 2):
          guard  let _cell = cell as? RightTxtFieldTableViewCell else { return }
            cell.accessoryType = .disclosureIndicator
            _cell.leftTxtLabel.text = "活动地址"
            _cell.rightTxtField.placeholder = "请输入"
            _cell.rightTxtField.text = campInfo.addressDetail
            if status == .notBegin {
                _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
            } else {
                _cell.rightTxtField.textColor = UIColor.commonTxtColor()
            }
        case (5, 0):
         guard   let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "活动须知"
            let count = campInfo.notes.count
            _cell.rightTxtLabel.text = "\(count)"
            
            if modifyType == .addNew ||  modifyType == .copy {
                cell.accessoryType = .disclosureIndicator
                if campInfo.notes.isEmpty {
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                } else {
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
            } else {
                if status == .inReview {
                    cell.accessoryType = .disclosureIndicator
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                } else {
                    if campInfo.notes.isEmpty {
                        cell.accessoryType = .none
                        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                    } else {
                        cell.accessoryType = .disclosureIndicator
                        _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                    }
                }
            }
        case (6, 0):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "报名开始时间"
            if modifyType == .addNew || modifyType == .copy {
                if campInfo.appointmentStartTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.appointmentStartTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                cell.accessoryType = .disclosureIndicator
            } else {
                _cell.rightTxtLabel.text = campInfo.appointmentStartTime
                if status == .inReview {
                    cell.accessoryType = .disclosureIndicator
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                } else {
                    cell.accessoryType = .none
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                }
            }
        case (6, 1):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "报名结束时间"
            if modifyType == .addNew || modifyType == .copy {
                if campInfo.appointmentEndTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.appointmentEndTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                cell.accessoryType = .disclosureIndicator
            } else {
                _cell.rightTxtLabel.text = campInfo.appointmentEndTime
                if status == .notBegin || status == .inReview {
                    cell.accessoryType = .disclosureIndicator
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                } else {
                    cell.accessoryType = .none
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                }
            }
        case (6, 2):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "开始时间"
            if modifyType == .addNew || modifyType == .copy {
                if campInfo.startTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.startTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                cell.accessoryType = .disclosureIndicator
            } else {
                _cell.rightTxtLabel.text = campInfo.startTime
                if status == .inReview {
                    cell.accessoryType = .disclosureIndicator
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                } else {
                    cell.accessoryType = .none
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                }
            }
        case (6, 3):
          guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
            _cell.leftTxtLabel.text = "结束时间"
            if modifyType == .addNew || modifyType == .copy {
                if campInfo.endTime.isEmpty {
                    _cell.rightTxtLabel.text = "请选择"
                    _cell.rightTxtLabel.textColor = UIColor.textfieldPlaceholderColor()
                } else {
                    _cell.rightTxtLabel.text = campInfo.endTime
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                }
                cell.accessoryType = .disclosureIndicator
            } else {
                _cell.rightTxtLabel.text = campInfo.endTime
                if status == .inReview {
                    cell.accessoryType = .disclosureIndicator
                    _cell.rightTxtLabel.textColor = UIColor.commonTxtColor()
                } else {
                    cell.accessoryType = .none
                    _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !kApp.pleaseAttestationAction(showAlert: true, type: .publish) {
            return
        }
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showAddPhotoAlertController()
        case (1, _):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (4, 2):
            AOLinkedStoryboardSegue.performWithIdentifier("ProductDescInput@Product", source: self, sender: indexPath as AnyObject?)
        case (5, 0):
            if !(modifyType == .edit && campInfo.notes.isEmpty && status != .inReview) {
                AOLinkedStoryboardSegue.performWithIdentifier("ProductAddAttribute@Product", source: self, sender: indexPath as AnyObject?)
            }
        case (6, _):
            let timeVC = TimeSelectViewController(nibName: "TimeSelectViewController", bundle: nil)
            Utility.sharedInstance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            switch indexPath.row {
            case 0 where modifyType == .addNew || modifyType == .copy || status == .inReview:
                timeVC.navTitle = "选择报名开始时间"
                timeVC.isEndTime = false
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.appointmentStartTime)
                timeVC.completeBlock = {date in
                    self.campInfo.appointmentStartTime = date.toString("yyyy-MM-dd HH:mm")
                }
            case 1 where modifyType == .addNew || modifyType == .copy || status == .notBegin || status == .inReview:
                timeVC.navTitle = "选择报名结束时间"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.appointmentEndTime)
                timeVC.completeBlock = {date in
                    self.campInfo.appointmentEndTime = date.toString("yyyy-MM-dd HH:mm")
                }
            case 2 where modifyType == .addNew || modifyType == .copy || status == .inReview:
                timeVC.navTitle = "选择开始时间"
                timeVC.isEndTime = false
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.startTime)
                timeVC.completeBlock = {date in
                    self.campInfo.startTime = date.toString("yyyy-MM-dd HH:mm")
                }
            case 3 where modifyType == .addNew || modifyType == .copy || status == .inReview:
                timeVC.navTitle = "选择结束时间"
                timeVC.dateSelected = Utility.sharedInstance.dateFormatter.date(from: campInfo.endTime)
                timeVC.completeBlock = {date in
                    self.campInfo.endTime = date.toString("yyyy-MM-dd HH:mm")
                }
            default:return
            }
            navigationController?.pushViewController(timeVC, animated: true)
        default:
            break
        }
    }
}

extension CampaignAddNewPlaceViewController {
    
    func showHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch modifyType {
        case .addNew, .copy:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignAddNav.detailUrl
        case .edit:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignEditNav.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func showCoverHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch modifyType {
        case .addNew, .copy:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignAddCover.detailUrl
        case .edit:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignEditCover.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func showPointHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch modifyType {
        case .addNew, .copy:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignAddPoint.detailUrl
        case .edit:
            helpWebVC.requestURL = WebviewHelpDetailTag.campaignEditPoint.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func selectAgreementAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        agreementSelected = btn.isSelected
    }
    
    func showAgreementDetailAction(_ btn: UIButton) {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        helpWebVC.requestURL = WebviewAgreementTag.campaign.detailUrl
        helpWebVC.title = "活动发布协议"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func refreshPageStyle() {
        switch modifyType {
        case .addNew, .copy:
            navigationItem.title = "新建现场活动"
            bottomBtnBottomConstr.constant = 0
        case .edit:
            navigationItem.title = "编辑现场活动"
            bottomBtnBottomConstr.constant = 0
        }
        
        tableView.reloadData()
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
        if campInfo.cover.isEmpty {
            Utility.showAlert(self, message: "请上传活动封面")
            return
        } else if campInfo.title.isEmpty {
            Utility.showAlert(self, message: "请输入活动名称")
            return
        } else if !Utility.containsChineseEnglishAndNumber(campInfo.title, length: 30) {
            Utility.showAlert(self, message: "活动名称应该是30个字以内汉字、英文字母或数字组成")
            return
        } else if campInfo.detail.isEmpty {
            Utility.showAlert(self, message: "请输入活动描述")
            return
        } else if campInfo.maxNumb == 0 {
            Utility.showAlert(self, message: "请输入活动人数上限")
            return
        } else if campInfo.maxNumb > 10000 {
            Utility.showAlert(self, message: "参加活动人数最多10000人")
            return
        } else if campInfo.point == 0 {
            Utility.showAlert(self, message: "请输入单个赠予积分")
            return
        } else if campInfo.point < 50 {
            Utility.showAlert(self, message: "积分必须大于等于50")
            return
        } else if campInfo.addressContact.isEmpty {
            Utility.showAlert(self, message: "请输入联系人")
            return
        } else if campInfo.addressContact.characters.count > 13 {
            Utility.showAlert(self, message: "联系人最多为13个汉字")
            return
        } else if campInfo.addressTel.isEmpty {
            Utility.showAlert(self, message: "请输入联系电话")
            return
        } else if campInfo.addressTel.characters.count > 12 || !Utility.isOnlyNumber(campInfo.addressTel) {
            Utility.showAlert(self, message: "联系电话最多为12个数字")
            return
        } else if campInfo.addressDetail.isEmpty {
            Utility.showAlert(self, message: "请输入活动地址")
            return
        } else if campInfo.addressDetail.characters.count > 100 {
            Utility.showAlert(self, message: "活动地址最多为100个字")
            return
        } else if campInfo.appointmentStartTime.isEmpty {
            Utility.showAlert(self, message: "请输入报名开始时间")
            return
        } else if campInfo.appointmentEndTime.isEmpty {
            Utility.showAlert(self, message: "请输入报名结束时间")
            return
        } else if campInfo.startTime.isEmpty {
            Utility.showAlert(self, message: "请选择开始时间")
            return
        } else if campInfo.endTime.isEmpty {
            Utility.showAlert(self, message: "请输入结束时间")
            return
        } else if !agreementSelected {
            Utility.showAlert(self, message: "请同意活动发布协议")
            return
        }
        
        if modifyType == .copy {
             self.requestAddNewPlaceCampaign()
        } else if validatePoints() && validateParticipators() {
                self.requestAddNewPlaceCampaign(status == CampaignStatus.inReview)
        } else {
            
        }
    }
    
    func validatePoints() -> Bool {
        guard let originalPointPerPerson = originalPointPerPerson else {
            return true
        }
        if campInfo.point >= originalPointPerPerson {
            return true
        }
        Utility.showAlert(self, message: "单个赠予积分修改后不能减少")
        return false
    }
    
    func validateParticipators() -> Bool {
        guard let originalParticipatorCount = originalParticipatorCount else {
            return true
        }
        
        if campInfo.maxNumb >= originalParticipatorCount {
            return true
        }
        Utility.showAlert(self, message: "活动人数上限修改后不能减少")
        return false
    }
    
    func showDraftAlert() {
        let alert = UIAlertController(title: "温馨提示", message: "是否保存为草稿", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            self.savePlaceCampaginInfoAsDraft()
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
            handleSaveNewPlaceCampaignAsDraft()
        }
        if  modifyType == .edit {
            handleSaveEditPlaceCampaignAsDraft()
        }
    }
    
    func handleSaveNewPlaceCampaignAsDraft() {
        if isNeedSaveNewPlaceCampaign() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func handleSaveEditPlaceCampaignAsDraft() {
        if isNeedSaveEditPlaceCampaign() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func isNeedSaveNewPlaceCampaign() -> Bool {
        return campInfo.canBeDraft
    }
    
    func isNeedSaveEditPlaceCampaign() -> Bool {
        if unEditCaminfo == campInfo {
            return false
        }
        return true
    }
    
    func createRequestParam() -> [String: Any] {
        var parameters: [String: Any] = [
            "cat": 2,
            "title": campInfo.title,
            "cover": campInfo.cover,
            "detail": campInfo.detail,
            "start_time": campInfo.startTime,
            "end_time": campInfo.endTime,
            "appointment_start_time": campInfo.appointmentStartTime,
            "appointment_end_time": campInfo.appointmentEndTime,
            "max_num": campInfo.maxNumb,
            "point": campInfo.point,
            "notes": campInfo.notes.toJSON(),
            "contact": campInfo.addressContact,
            "tel": campInfo.addressTel,
            "address": campInfo.addressDetail
        ]
        
        if  modifyType != .copy {
            if campInfo.id != 0 {
                parameters["event_id"] = campInfo.id
            }
        }
        return parameters
    }
    func savePlaceCampaginInfoAsDraft() {
        var param = createRequestParam()
        param["is_approved"] = 3
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.placeEventSave(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if error != nil {
                Utility.showAlert(self, message: msg ?? "")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewCampaignAddedNotification), object: nil, userInfo: ["CampaignType": CampaignType.place.rawValue, "CampaignStatus": CampaignStatus.draft.rawValue])
            }
        }
    }
    
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
    
    func uploadImage() {
        guard let img = campaignCoverImg else { return }
        guard let imageData = UIImageJPEGRepresentation(img, 0.8) else { return }
        let parameters: [String: Any] = [
            "cover": imageData,
            "prefix[cover]": "event/cover"
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any], let photoUploadedArray = result["success"] as? [Any] else {
                    return
                }
                if let photoInfo = photoUploadedArray.first as? [String: Any], let imgUrl = photoInfo["url"] as? String {
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
    
    func requestAddNewPlaceCampaign(_ confirm: Bool = false) {
        var parameters: [String: Any] = [
            "cat": 2,
            "title": campInfo.title,
            "cover": campInfo.cover,
            "detail": campInfo.detail,
            "start_time": campInfo.startTime,
            "end_time": campInfo.endTime,
            "appointment_start_time": campInfo.appointmentStartTime,
            "appointment_end_time": campInfo.appointmentEndTime,
            "max_num": campInfo.maxNumb,
            "point": campInfo.point,
            "notes": campInfo.notes.toJSON(),
            "contact": campInfo.addressContact,
            "tel": campInfo.addressTel,
            "address": campInfo.addressDetail
        ]
        
        if confirm {
            parameters["step"] = 2
        } else {
            parameters["step"] = 1
        }
        if  modifyType != .copy {
            if campInfo.id != 0 {
                parameters["event_id"] = campInfo.id
            }
        }
        deductionPoints = campInfo.point * campInfo.maxNumb
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.placeEventSave(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: AnyObject] else { return }
                if confirm {
                    AOLinkedStoryboardSegue.performWithIdentifier("ObjectReleaseSucceed@Product", source: self, sender: nil)
                } else {
                    if let point = result["point_cost"] as? String {
                        let msg = String(format: "发布本次活动需要先扣除积分：%@（活动人数上限*单个赠与积分），活动结束后24小时系统根据具体参与活动的人数退还多余的积分。是否确认支付积分", point)
                        
                        Utility.showConfirmAlert(self, message: msg, confirmCompletion: {
                            self.requestAddNewPlaceCampaign(true)
                        })
                    } else {
                        self.requestAddNewPlaceCampaign(true)
                    }
                }
            } else {
                Utility.hideMBProgressHUD()
                if let msg = error?.userInfo["message"] as? String {
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
                        Utility.showAlert(self, message: msg)
//                        // 这里肯定 积分不够
//                        let msg = "发布本次活动需要先扣除积分："+"\(self.deductionPoints)"+"（活动人数上限*单个赠与积分），活动结束后24小时系统根据具体参与活动的人数退还多余的积分。是否确认支付积分"
//                        Utility.showConfirmAlert(self, message: msg, confirmCompletion: { (Void) in
//                            Utility.showConfirmAlert(self, title: "提示", cancelButtonTitle: "取消", confirmButtonTitle: "充值", message: "当前积分不足，请充值", confirmCompletion: { (Void) in
//                                guard let vc = AOLinkedStoryboardSegue.sceneNamed("ChargePoints@MerchantCenter") as? ChargePointsViewController else {return}
//                                self.navigationController?.pushViewController(vc, animated: true)
//                                
//                            })
//                        })

                    }
                }
            }
        }
    }
    
    func requestCampaignInfo() {
        
        let parameters: [String: AnyObject] = [
            "event_id": campInfo.id as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.eventDetail(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let result = object as? [String: AnyObject] else { return}
                
                let campInfo = Mapper<PlaceCampaignInfo>().map(JSON: result)
                self.campInfo = campInfo
                if self.modifyType == .edit {
                    self.unEditCaminfo = Mapper<PlaceCampaignInfo>().map(JSON: result)
                }
                self.tableView.reloadData()
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
}
