//
//  SetSpecificationViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//
// swiftlint:disable empty_count
// swiftlint:disable force_unwrapping
import UIKit

class SetSpecificationViewController: ItemBaseViewController {

    override var models: [AnyObject]? {
        var models = [SetItemCodeViewHelpModel]()
        for i in 1 ... 5 {
            let desc = "规格\(i)"
            let titleValue = "请输入规格"
            let  model = SetItemCodeViewHelpModel(desc: desc, titleValue: titleValue)
            models.append(model)
            
        }
        return models
    }
    override var cellID: String {
        return "SetSpecifiSetItemCodeTableViewCell"
    }
    
    override func setupUI() {
        super.setupUI()
        self.addItemHomeViewController.newItem.propList = [GoodsProperty]()
        tableView.register(UINib(nibName: "SetItemCodeTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
    }

}

extension SetSpecificationViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SetItemCodeTableViewCell, let modelArray = models as? [SetItemCodeViewHelpModel] else { return UITableViewCell() }
        // cell .block
        cell.endEditingBlock = { [unowned self] text, path in
            self.addNewSpec(text, index: path.row)
        }
        if indexPath.row == modelArray.count - 1 {
            cell.clipsToBounds = true
        }
        cell.maxCharacterCount = 10
        cell.model = modelArray[indexPath.row]
        return cell
    }

    fileprivate func validSameSpecName(_ title: String) -> Bool {
       guard let list = self.addItemHomeViewController.newItem.propList else { return true }
        for pro in list {
             guard let protitle = pro.title else { return  true }
            if protitle == title {
                Utility.showAlert(self, message: "该规格已存在，请重新输入")
                return false
            }
        }
        return true
    }
    
    fileprivate func addNewSpec(_ title: String, index: Int) {
        guard let list = self.addItemHomeViewController.newItem.propList else { return }
       
        if title == "" {
            for pro in list.enumerated() {
                let proIndex = pro.element.index
                if proIndex == index {
                    self.addItemHomeViewController.newItem.propList!.remove(at: pro.offset)
                    return
                }
            }
        }
        
            for pro in list {
                let proIndex = pro.index
                if proIndex == index {
                    pro.title = title
                    return
                }
            }
            
            let proper = GoodsProperty()
            proper.title = title
            proper.index = index
            self.addItemHomeViewController.newItem.propList?.append(proper)
        }
    }
