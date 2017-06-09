//
//  MyShopAssistantViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/17.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

private let cellID = "cellID"

class MyShopAssistantViewController: BaseViewController {
    fileprivate lazy var staffList: [Staff] = [Staff]()
    fileprivate lazy var defaultView: MyShopAssistantDefaultView = {
        let defaultView = MyShopAssistantDefaultView.defaultView()
        return defaultView
    }()
    @IBOutlet fileprivate weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        tableView.mj_header.beginRefreshing()
        
    }
}

extension MyShopAssistantViewController {
    
    func requestListWithReload() {
        loadStaffList()
    }
    
    fileprivate  func setupUI() {
        navigationItem.title = "我的店员"
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.colorWithHex("F5F5F5")
        tableView.register(UINib(nibName: "ShopAssistantTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        
        defaultView.isHidden = true
        view.addSubview(defaultView)
        defaultView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
        defaultView.tapAction = {[unowned self] in
            let vc = UIStoryboard(name: "MerchantCenter", bundle: nil).instantiateViewController(withIdentifier: "AddShopAssistantTableViewController")
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate  func loadStaffList() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.getStaffList(aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
            if let result = object as? [String: AnyObject] {
                guard let list = result["staff_list"] as? [[String: AnyObject]] else {return}
                self.staffList.removeAll()
                list.forEach({ (dict) in
                    if let model = Mapper<Staff>().map(JSON: dict) {
                        self.staffList.append(model)
                    }
                })
                
                self.tableView.isHidden = self.staffList.isEmpty
                self.tableView.reloadData()
                self.defaultView.isHidden = !self.staffList.isEmpty
                self.tableView.mj_header.endRefreshing()
            } else {
                self.defaultView.isHidden = false
                self.tableView.mj_header.endRefreshing()
            }}
    }
    
    fileprivate func deleteStaff(_ staff: Staff, atIndex: Int) {
        Utility.showMBProgressHUDWithTxt()
        guard let staffID = staff.staffID else {return}
        let param = ["staff_id": staffID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.deleteStaff(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) {(_, _, object, _, msg) in
            if let message = msg, !message.characters.isEmpty {
                Utility.showAlert(self, message: message)
            }
        }
    }
}

extension MyShopAssistantViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = staffList.isEmpty
        defaultView.isHidden = !tableView.isHidden
        return staffList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)  as? ShopAssistantTableViewCell
            else { return UITableViewCell() }
        cell.model = staffList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension MyShopAssistantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .default, title: "      ", handler: { (_, indexPath) in
                let editeVC = EditShopAssistantViewController()
                editeVC.staffModel = self.staffList[indexPath.row]
                self.navigationController?.pushViewController(editeVC, animated: true)
            }), UITableViewRowAction(style:
                .default, title: "      ", handler: { (_, indexPath) in
                    Utility.showConfirmAlert(self, message: "弹出提示“删除后店员将不具备相关权限，确认删除？", confirmCompletion: {
                        self.deleteStaff(self.staffList[indexPath.row], atIndex: indexPath.row)
                        self.staffList.remove(at: indexPath.row)
                        Utility.hideMBProgressHUD()
                        self.tableView.reloadData()
                    })
                    
            })]
    }
    
}
