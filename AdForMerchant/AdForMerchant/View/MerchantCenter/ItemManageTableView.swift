//
//  ItemManageTableView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/24.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let itemManageCellID = "itemManageCell"
class ItemManageTableView: BaseTableView {
    override var models: [AnyObject]? {
        didSet {
            reloadData()
        }
    }
    var editFlag: Bool? {
        didSet {
            reloadData()
        }
    }
    var editAction: ((_ model: Goods) -> Void)?
    var deleteAction: ( (_ model: Goods, _ indexPath: IndexPath) -> Void)?
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        cellID = itemManageCellID
        nibName = "ItemManageTableViewCell"
        rowHeight = 140
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ItemManageTableView {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: itemManageCellID, for: indexPath)  as? ItemManageTableViewCell else { return UITableViewCell() }
        guard let modelArray = models as? [Goods] else { return UITableViewCell() }
        if editFlag == true {
            cell.configEditMode(modelArray[indexPath.row])
            cell.editBlock = {[unowned self] index in
                if let block = self.editAction {
                    block(modelArray[index.row])
                }
                
            }
            cell.deleteBlock = {[unowned self] index in
//                print(index.row)
                if index.row < modelArray.count {
                    if let block = self.deleteAction {
                        block(modelArray[index.row], index as IndexPath)
                    }
                }
            }
        } else {
           cell.configItemManage(modelArray[indexPath.row]) 
        }
        return cell
    }
}

extension ItemManageTableView {
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}
