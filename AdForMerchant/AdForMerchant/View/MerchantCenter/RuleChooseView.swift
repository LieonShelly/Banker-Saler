//
//  RuleChooseView.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/19.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
typealias RuleChooseBlockCancel = () -> Void
typealias RuleChooseBlockConfirm = (_ info: PrivilegeRuleInfo?, _ isUsePrivilege: Bool) -> Void
class RuleChooseView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUsePrivilegeView: UIView!
    @IBOutlet weak var chooseImageView: UIImageView!
    @IBOutlet weak var chooseImageLeftConstraint: NSLayoutConstraint!
    
    var cancelBlock: RuleChooseBlockCancel?
    var confirmBlock: RuleChooseBlockConfirm?
    var selectedPriveilegeRuleInfo: PrivilegeRuleInfo?
    var isUsePrivilege = false
    var lastIndex: IndexPath?
    
    var dataArray: [PrivilegeRuleInfo] = [] {
        didSet {
            tableView.reloadData()
            if let ruleInfo = selectedPriveilegeRuleInfo {
                for (index, rule) in dataArray.enumerated() where rule.id == ruleInfo.id {
                    self.lastIndex = NSIndexPath(row: index, section: 0) as IndexPath
                }
            }
        }
    }

    override func layoutSubviews() {
        if let index = lastIndex {
            self.tableView(self.tableView, didSelectRowAt: index)
        }
    }
    
    @IBAction func cancelHandle(_ sender: AnyObject) {
        if let block = cancelBlock {
            block()
        }
    }
    @IBAction func confirmHandle(_ sender: AnyObject) {
        if let block = confirmBlock {
           
            if let info = self.selectedPriveilegeRuleInfo {
                block(info, !chooseImageView.isHidden)
            } else {
                block(nil, !chooseImageView.isHidden)
            }
            
        }
    }
    
    func noUsePrivileteHandle() {
        chooseImageView.isHidden = false
        for i in 0..<self.dataArray.count {
            self.dataArray[i].isSeleted = false
        }
        self.tableView.reloadData()
    }
    
    override func awakeFromNib() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 125
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: "RuleTableViewCell", bundle: nil), forCellReuseIdentifier: "RuleTableViewCell")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.noUsePrivileteHandle))
        noUsePrivilegeView.addGestureRecognizer(tap)
        if screenHeight == 736 {
            chooseImageLeftConstraint.constant = 30
        }
    }

}

extension RuleChooseView:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let privilegeInfo = self.dataArray[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RuleTableViewCell", for: indexPath) as? RuleTableViewCell else {
            return RuleTableViewCell() }
        cell.config(privilegeInfo)
        
        // 展开block
        cell.expandBlock = {
            self.dataArray[indexPath.row].isExpand = true
            self.tableView.reloadData()
        }
        // 收缩block
        cell.shrinkBlock = {
            self.dataArray[indexPath.row].isExpand = false
            self.tableView.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseImageView.isHidden = true
        self.dataArray[indexPath.row].isSeleted = true
        
        if let lastIndex = self.lastIndex {
            // 如果点同一个按钮 啥也不做 ,不是的话 就取消
            if lastIndex == indexPath {
            } else {
                self.dataArray[lastIndex.row].isSeleted = false
            }
        }
        self.lastIndex = indexPath
        self.selectedPriveilegeRuleInfo = dataArray[indexPath.row]
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataArray[indexPath.row].isExpand == false {
            return 120
        } else {
            return RuleTableViewCell.getRuleLabelHeight(dataArray[indexPath.row])
        }
    }
}
