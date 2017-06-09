//
//  FeedbackViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 7/18/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class FeedbackViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmBtn: UIButton!
    @IBOutlet fileprivate var txtField: UITextField!

    var content: String! = ""
    var contact: String? = ""
    
    var catsInfoArray: [FeedbackCategoryInfo] = []
    
    var catAndSubIdSelected: (catId: String, subCatId: String) = ("", "")
    var catAndSubIndexSelected: (catIndex: Int, subCatIndex: Int) = (-1, -1)

    fileprivate var isSubCategorySelected: Bool = false
    
    let bgView: UIView = UIView()
    var pickerView: UIPickerView!
    var pickerViewBg: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "意见反馈"
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "TextCounterTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCounterTableViewCell")
        
        confirmBtn.setTitle("提交", for: UIControlState())
        confirmBtn.addTarget(self, action: #selector(self.commitAction), for: .touchUpInside)
        let pickerViewBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 240 + 44))
        pickerViewBg.backgroundColor = UIColor.commonBgColor()
        
        let pickerConfirmBtn = UIButton(type: .custom)
        pickerConfirmBtn.setTitle("确认", for: UIControlState())
        pickerConfirmBtn.setTitleColor(UIColor.commonBlueColor(), for: UIControlState())
        pickerConfirmBtn.frame = CGRect(x: screenWidth - 80, y: 0, width: 80, height: 44)
        pickerConfirmBtn.addTarget(self, action: #selector(self.pickerConfirmAction), for: .touchUpInside)
        pickerViewBg.addSubview(pickerConfirmBtn)

        pickerView = UIPickerView(frame: CGRect(x: 0, y: 44, width: screenWidth, height: 240))
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerViewBg.addSubview(pickerView)
        txtField.inputView = pickerViewBg
        txtField.delegate = self
        bgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        bgView.backgroundColor = UIColor.black
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.resignTxtFiled)))
        bgView.alpha = 0.7
        
        requestFeedbackCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notifi:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notifi:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notifi: NSNotification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration) { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.view.layoutIfNeeded()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if segue.identifier == "ProductDescInput@Product" {
        //            let desVC = segue.destinationViewController as! DetailInputViewController
        //            let indexPath = sender as! NSIndexPath
        //
        //            switch (indexPath.section, indexPath.row) {
        //            case (3, _):
        //                desVC.navTitle = "输入商品名称"
        //            case (4, _):
        //                desVC.navTitle = "输入商品描述"
        //            default:
        //                break
        //            }
        //
        //        }
    }
    
    // MARK: - Action
    
    func commitAction() {
        //        if merchantInfo.logo.isEmpty {
        //            Utility.showMBProgressHUDToastWithTxt("请上传商户标识")
        //            return
        //        } else if merchantInfo.name.isEmpty {
        //            Utility.showMBProgressHUDToastWithTxt("请输入商户昵称")
        //            return
        //        } else if merchantInfo.tel.isEmpty {
        //            Utility.showMBProgressHUDToastWithTxt("请输入联系电话")
        //            return
        //        }
        
        requestFeedbackCommit()
        
    }
    
    func pickerConfirmAction() {
        
        if isSubCategorySelected {
            if let firstCat = catsInfoArray.first {
                if catAndSubIndexSelected.subCatIndex < 0 {
                    catAndSubIndexSelected.subCatIndex = 0
                }
                 catAndSubIdSelected.subCatId = firstCat.subCats[catAndSubIndexSelected.subCatIndex].catId
            } else {
                catAndSubIdSelected.subCatId = ""
            }
        } else {
            if catsInfoArray.isEmpty == false {
                catAndSubIndexSelected.catIndex = 0
            }
            
            if catAndSubIndexSelected.catIndex >= 0 {
                catAndSubIdSelected.catId = catsInfoArray[catAndSubIndexSelected.catIndex].catId
            }
        }
        tableView.reloadData()
                
        resignTxtFiled()
    }
    
    func pickerCancelAction() {
        
        resignTxtFiled()
    }
    
    func resignTxtFiled() {
        txtField.resignFirstResponder()
        bgView.removeFromSuperview()
    }
    
    // MARK: - HTTP request
    
    func requestFeedbackCategory() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.feedbackCatList(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if let result = object as? [String: AnyObject] {
                guard let list = result["cat_list"] as? [AnyObject] else {return}
                self.catsInfoArray = list.flatMap({FeedbackCategoryInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
            }
        }
    }
    
    func requestFeedbackCommit() {
        
        if catAndSubIdSelected.catId.isEmpty {
            Utility.showAlert(self, message: "请选择反馈分类")
            return
        } else if catAndSubIdSelected.subCatId.isEmpty {
            Utility.showAlert(self, message: "请选择反馈原因")
            return
        } else if content.isEmpty {
            Utility.showAlert(self, message: "请输入你的宝贵意见")
            return
        } else if contact?.characters.count < 1 {
            Utility.showAlert(self, message: "请填写联系方式")
            return
        }
        guard let contact = contact else {return}
        let parameters: [String: AnyObject] = [
            "top_cat_id": catAndSubIdSelected.catId as AnyObject,
            "child_cat_id": catAndSubIdSelected.subCatId as AnyObject,
            "content": content as AnyObject,
            "contact": contact as AnyObject
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.feedbackSave(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, _) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                Utility.showAlert(self, message: "反馈成功", dismissCompletion: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                Utility.hideMBProgressHUD()
                if let msg = error?.userInfo["message"] as? String {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
}

extension FeedbackViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCounterTableViewCell", for: indexPath)
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightTxtFieldTableViewCell", for: indexPath)
            
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .value1, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension FeedbackViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 17
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return 150
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.detailTextLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = "请选择反馈分类"
            if catAndSubIndexSelected.catIndex >= 0 {
                cell.detailTextLabel?.text = catsInfoArray[catAndSubIndexSelected.catIndex].catName
            } else {
                cell.detailTextLabel?.text = nil
            }
        case (0, 1):
            cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.detailTextLabel?.textColor = UIColor.colorWithHex("#393939")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.text = "请选择反馈原因"
            if catAndSubIndexSelected.subCatIndex >= 0 {
                cell.detailTextLabel?.text = catsInfoArray.first?.subCats[catAndSubIndexSelected.subCatIndex].catName
            } else {
                cell.detailTextLabel?.text = nil
            }
            
        case (1, 0):
            guard let _cell = cell as? TextCounterTableViewCell else {return}
            _cell.textView.text = content
            _cell.placeHolder = "请输入你的宝贵意见..."
            _cell.endEditingBlock = { textView in
                self.content = Utility.getTextByTrim(textView.text)
            }
            
        case (2, 0):
            
            guard let _cell = cell as? RightTxtFieldTableViewCell else {return}
            _cell.leftTxtLabel.text = "联系方式"

            _cell.rightTxtField.keyboardType = .numberPad
            _cell.rightTxtField.isUserInteractionEnabled = true
            _cell.rightTxtField.textAlignment = .left
//            _cell.textFieldLeadingConstraint.constant = 30
            _cell.rightTxtField.placeholder = "请输入手机号码/QQ号"
            _cell.rightTxtField.text = contact
            _cell.sourceIsAllowEdit = true
            _cell.endEditingBlock = { textField in
                self.contact = textField.text ?? ""
            }
        default:
            break
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            isSubCategorySelected = false
            
            if catsInfoArray.isEmpty {
                Utility.showAlert(self, message: "暂无反馈分类")

                return
            }
            
            pickerView.reloadAllComponents()
            if catAndSubIndexSelected.catIndex >= 0 {
                pickerView.selectRow(catAndSubIndexSelected.catIndex, inComponent: 0, animated: false)
            }
            txtField.becomeFirstResponder()
        case (0, 1):
            isSubCategorySelected = true
            guard let catsInfo = catsInfoArray.first else {return}
            if catsInfoArray.isEmpty || catsInfo.subCats.isEmpty {
                Utility.showAlert(self, message: "暂无反馈原因")

                return
            }
            pickerView.reloadAllComponents()
            if catAndSubIndexSelected.subCatIndex >= 0 {
                pickerView.selectRow(catAndSubIndexSelected.subCatIndex, inComponent: 0, animated: false)
            }
            txtField.becomeFirstResponder()
        default:
            break
        }
    }
}

extension FeedbackViewController: UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isSubCategorySelected {
            if let firstCat = catsInfoArray.first {
                return firstCat.subCats.count
            } else {
                return 0
            }
        } else {
            return catsInfoArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }

}

extension FeedbackViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isSubCategorySelected {
            if let firstCat = catsInfoArray.first {
                return firstCat.subCats[row].catName
            } else {
                return nil
            }
        } else {
            return catsInfoArray[row].catName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if isSubCategorySelected {
            catAndSubIndexSelected.subCatIndex = row
        } else {
            catAndSubIndexSelected.catIndex = row
        }
        
    }
}

extension FeedbackViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //        textField.inputView = timeView
        //        textField.reloadInputViews()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addSubview(bgView)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        let timeViewBg = txtField.inputView as! UIDatePicker
        
        //        Utility.sharedInstance.dateFormatter.dateFormat = "HH:mm"
        //        textField.text = Utility.sharedInstance.dateFormatter.stringFromDate(timeView.date)
        
    }
    
}
