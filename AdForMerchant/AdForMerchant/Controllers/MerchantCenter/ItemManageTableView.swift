//
//  ItemManageTableView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/24.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let itemManageCellID = "itemManageCell"
class ItemManageTableView: UITableView {
    
//    var models: = <#value#>
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        dataSource = self
        delegate = self
        registerNib(UINib(nibName: "ItemManageTableViewCell", bundle: nil), forCellReuseIdentifier: itemManageCellID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ItemManageTableView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(itemManageCellID, forIndexPath: indexPath)  as? ItemManageTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension ItemManageTableView: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
}
