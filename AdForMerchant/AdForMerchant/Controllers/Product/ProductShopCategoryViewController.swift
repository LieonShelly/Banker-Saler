//
//  ProductShopCategoryViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/4/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductShopCategoryViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    var categoryTF: UITextField?
    var storeParam: StoreCateSaveParameter = StoreCateSaveParameter()
    internal var selectCompletionBlock: ((ShopCategoryModel?) -> Void)?
    
    fileprivate var categoryDataArray: [ShopCategoryModel] = [ShopCategoryModel]()
    fileprivate var selectIndex: Int = -1
    
    var selectedShopCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "选择店铺分类"
        
        tableView.register(UINib(nibName: "ShopCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ShopCategoryTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        confirmButton.setTitle("确定", for: UIControlState())
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "CommonButtonAdd"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addNewCategoryAction(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
//        self.bottomStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utility.showMBProgressHUDWithTxt("", dimBackground: false)
        requestData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestData() {
         guard let type = storeParam.type else { return  }
        let params = ["type": type.rawValue]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.storeCatList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if object == nil {
                Utility.showAlert(self, message: msg ?? "")
                return
            }
            
            if let result = object as? [String: Any], let tempArray = result["cat_list"] as? [[String: Any]] {
                self.categoryDataArray.removeAll()
                for cat in tempArray {
                    if let data = ShopCategoryModel(JSON: cat) {
                        self.categoryDataArray.append(data)
                    }
                }
            }
            
            for i in 0..<self.categoryDataArray.count where self.selectedShopCategory == self.categoryDataArray[i].catID {
                self.selectIndex = i
                break
            }
            self.tableView.reloadData()
        }
    }
    
    func requestCategorySave(_ param: StoreCateSaveParameter) {
        let parameters: [String: Any] = param.toJSON()
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.storeSaveCat(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else { return }
                if let _ = result["cat_id"] as? String {
                    Utility.showMBProgressHUDToastWithTxt("添加分类成功")
                    self.requestData()
                } else {
                    Utility.hideMBProgressHUD()
                }
            } else {
                if let msg = message {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }

    func addNewCategoryAction(_ sender: AnyObject) {
        let codeAlertView = CustomIOSAlertView()
        codeAlertView?.containerView = categoryInputView()
        codeAlertView?.delegate = self
        codeAlertView?.buttonTitles = ["取消", "确定"]
        codeAlertView?.useMotionEffects = true
        codeAlertView?.show()
    }
    
    func categoryInputView() -> UIView {
        
        let viewWidth = screenWidth / 5 * 4
        let titilWidth = viewWidth / 2
        
        let codeView = UIView(frame:CGRect(x: 0, y: 0, width: viewWidth, height: 120))//30+20+60
        let titleLabel = UILabel(frame:CGRect(x: viewWidth / 2 - titilWidth / 2, y: 20, width: titilWidth, height: 20))
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeView.addSubview(titleLabel)
        
        titleLabel.text = "添加新分类"
        
        let starBgView = UIView(frame:CGRect(x: 20, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 20, width: viewWidth - 40, height: 40))
        starBgView.backgroundColor = UIColor.white
        starBgView.layer.cornerRadius = 8.0
        starBgView.layer.masksToBounds = true
        starBgView.layer.borderColor = UIColor.colorWithHex("666666").cgColor
        starBgView.layer.borderWidth = 1.0
        codeView.addSubview(starBgView)
        
        let codeTfd = UITextField(frame: starBgView.frame.insetBy(dx: 10, dy: 2))
        codeTfd.borderStyle = UITextBorderStyle.none
        codeTfd.placeholder = "分类名称"
        codeTfd.keyboardType = UIKeyboardType.default
        codeView.addSubview(codeTfd)
        categoryTF = codeTfd
        categoryTF?.becomeFirstResponder()
        codeTfd.addTarget(self, action: #selector(self.txtFieldChanged(_:)), for: .editingChanged)
        return codeView
    }
    
    func txtFieldChanged(_ textField: UITextField) {
         guard let chars = textField.text?.characters else { return  }
        if chars.count > 10, let startIndex = textField.text?.startIndex {
            textField.text = textField.text?.substring(to: chars.index(startIndex, offsetBy: 10))
        }
    }

    @IBAction func confirmAction() {
        if selectIndex >= 0 {
            if let block = selectCompletionBlock {
                let selectCategoryModel = categoryDataArray[selectIndex]
                block(selectCategoryModel)
            }
        } else {
            if let block = selectCompletionBlock {
                block(nil)
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func bottomStatus() {
        var status: Bool = true
        status = judgeBottomStatus()
        if status {
            self.confirmButton.setBackgroundImage(UIImage(named: "CommonBlueBg"), for: UIControlState())
            self.confirmButton.isUserInteractionEnabled = true
        } else {
            self.confirmButton.setBackgroundImage(UIImage(named: "CommonGrayBg"), for: UIControlState())
            self.confirmButton.isUserInteractionEnabled = false
        }
    }
    
    func judgeBottomStatus() -> Bool {
        if selectIndex == -1 {
            return false
        }
        return true
    }
}

extension ProductShopCategoryViewController: CustomIOSAlertViewDelegate {
    func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
         guard let alter = alertView as? CustomIOSAlertView else { return  }
        switch buttonIndex {
        case 0:
            alter.close()
        case 1:
            if let categoryName =  categoryTF?.text {
                alter.close()
                storeParam.categoryName = categoryName
                requestCategorySave(storeParam)
            }
        default:
            break
        }
    }
}

extension ProductShopCategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCategoryTableViewCell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let cateInfo = categoryDataArray[indexPath.row]
        guard let pCell = cell as? ShopCategoryTableViewCell else { return  UITableViewCell()}
        pCell.config(cateInfo.catName, count: cateInfo.goodsNum)
        pCell.isCategorySelected = false
        if indexPath.row == selectIndex {
            pCell.isCategorySelected = true
        }
        
        return cell
        
    }
}

extension ProductShopCategoryViewController: UITableViewDelegate {
    
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
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectIndex == indexPath.row {
            selectIndex = -1
        } else {
            selectIndex = indexPath.row
        }
        tableView.reloadData()
//        self.bottomStatus()
    }
}
