//
//  DiscountViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/13.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class DiscountViewController: UITableViewController {
    
    var settingCoverView = SettingCoverView()
    var noneDisountView = NoneReduceView()
    var isSetting = true
    
    fileprivate var dataArray: [PrivilegeRuleInfo] = []
    var editArray = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.beginRrfresh), name: Notification.Name(rawValue: "addNewReducePrivilege"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAlertTitle), name: Notification.Name(rawValue: dataSourceWhenRuleInfoFullThreeNotification), object: nil)
        tableView.register(UINib(nibName: "DiscountTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscountTableViewCell")
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 64, right: 0)
        tableView.separatorStyle = .none
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.mj_header.beginRefreshing()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        settingCoverView.dissmiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DiscountViewController {
    
    func checkDataArray() {
        if dataArray.count >= 3 {
            if tableView.window == nil {return}
            Utility.showAlert(self, message: "满减／折扣只能添加3个")
            return
        }
    }
    
    func beginRrfresh() {
        self.tableView.mj_header.beginRefreshing()
    }
    
    func requestListWithReload() {
        requestData(1)
    }
    
    func requestData(_ type: Int) {
        let params: [String: AnyObject] = ["type": type as AnyObject]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.privilegeRuleList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {                                
                guard let tempArray = result["rule_list"] as? [Any] else {return}
                self.dataArray = tempArray.flatMap({PrivilegeRuleInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                if self.dataArray.isEmpty {
                    self.tableView.backgroundView = self.nodataBgView()
                } else {
                    self.tableView.tableFooterView = UIView()
                }
               self.dataArray.sort(by: { (model1, model2) -> Bool in
                    if model1.privilegeId > model2.privilegeId {
                    return true
                    } else {
                        return false
                }
               })
               self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
            } else {
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    func deleteData(_ index: IndexPath) {
        let privilegeInfo = dataArray[index.section]
        let params: [String: AnyObject] = ["privilege_id": privilegeInfo.privilegeId as AnyObject]
        
                Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.privilegeDeleteRule(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if (object as? [String: AnyObject]) != nil {
                Utility.hideMBProgressHUD()
                self.dataArray.remove(at: index.section)
                Utility.showAlert(self, message: "删除成功", dismissCompletion: {
                    self.requestData(1)
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

extension DiscountViewController {
    
    func pushController(_ name: String, title: String, id: String, ruleInfo: PrivilegeRuleInfo) {
        guard let editDiscountVC = AOLinkedStoryboardSegue.sceneNamed(name) as? AddDiscountViewController else {return}
        editDiscountVC.title = title
        editDiscountVC.id = id
        editDiscountVC.ruleInfo = ruleInfo
        self.navigationController?.pushViewController(editDiscountVC, animated: true)
    }
    
    func nodataBgView() -> UIView {
        let bgView = UIView(frame: tableView.bounds)
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        descLbl.text = "当前暂无折扣活动, 请点击右上角添加"
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        return bgView
    }
    
    func showAlertTitle() {
        if dataArray.count >= 3 {
            let index = UserDefaults.standard.integer(forKey: "index")
            if index == 0 {
                Utility.showAlert(self, message: "折扣优惠活动最多三个")
            }
        }
    }
}

extension DiscountViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscountTableViewCell", for: indexPath) as? DiscountTableViewCell else {
            return UITableViewCell()
        }
        
        // 侧滑按钮
        let cusview = UIView()
        cusview.frame = CGRect(x: cell.width, y: 0, width: 122, height: 125)
        cusview.backgroundColor = UIColor.colorWithHex("EBEBF1")
        cell.addSubview(cusview)

        let deleteBtn = UIButton()
        deleteBtn.frame = CGRect(x: 1, y: 0, width: 65, height: 125)
        deleteBtn.setImage(UIImage(named: "CellItemDelete"), for: .normal)
        deleteBtn.backgroundColor = UIColor.white
        
        let editBbtn = UIButton()
        editBbtn.frame = CGRect(x: 67, y: 0, width: 70, height: 125)
        editBbtn.setImage(UIImage(named: "btn_modify"), for: .normal)
        editBbtn.backgroundColor = UIColor.white
        
        cusview.addSubview(deleteBtn)
        cusview.addSubview(editBbtn)
        
        cell.config(dataArray[indexPath.section])
        // 展开block
        cell.expandBlock = {
            self.dataArray[indexPath.section].isExpand = true
            self.editArray.append(indexPath.row)
            self.tableView.reloadData()
        }
        // 收缩block
        cell.shrinkBlock = {
            self.dataArray[indexPath.section].isExpand = false
            self.editArray.remove(at: 0)
            self.tableView.reloadData()
        }
        
            return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coverView =
            Bundle.main.loadNibNamed("SettingCoverView", owner: nil, options: nil)?.first as? SettingCoverView else {return}
        coverView.frame = UIScreen.main.bounds
        coverView.deleteBlock = {
            self.deleteData(indexPath)
            self.settingCoverView.dissmiss()

        }
        coverView.editBlock = {
            self.pushController("AddDiscount@MerchantCenter", title: "折扣编辑", id: self.dataArray[indexPath.section].privilegeId, ruleInfo: self.dataArray[indexPath.section])
            self.settingCoverView.dissmiss()
        }
        self.settingCoverView = coverView
        self.navigationController?.view.addSubview(coverView)
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .default, title: "删除") { (action, indexPath) in
            self.deleteData(indexPath)
        }
        action1.backgroundColor = UIColor.white
        let action2 = UITableViewRowAction(style: .normal, title: "删除") { (action, indexPath) in
            self.pushController("AddDiscount@MerchantCenter", title: "折扣编辑", id: self.dataArray[indexPath.section].privilegeId, ruleInfo: self.dataArray[indexPath.section])
            self.settingCoverView.dissmiss()
            
        }
        action2.backgroundColor = UIColor.white
        return [action2, action1]
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if dataArray[indexPath.section].isExpand == false {
            return 125
        } else {
            return DiscountTableViewCell.getRuleLabelHeight(dataArray[indexPath.section])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.editArray.isEmpty ? true : false
    }
}
