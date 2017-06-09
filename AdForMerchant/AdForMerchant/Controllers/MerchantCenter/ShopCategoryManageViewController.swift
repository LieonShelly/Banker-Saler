//
//  ShopCategoryManageViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

private let defaultCellID = "MyShopProductDefaultCategoryCell"
private let categoryID = "MyShopProductCategoryEditTableViewCell"
class ShopCategoryManageViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!

    @IBAction func modifyCategoryAction() {
        manageType = .edit
        tableView.reloadData()
    }
    
    fileprivate var dataArray: [ShopProductCategoryInfo] = [ShopProductCategoryInfo]()
    fileprivate var defaulutDataArray: [ShopProductCategoryInfo] = [ShopProductCategoryInfo]()
    fileprivate var normalDataArray: [ShopProductCategoryInfo] = [ShopProductCategoryInfo]()
    var selectedCategoryInfo: ShopProductCategoryInfo?
    
    internal var manageType: ShopCategoryManageType = .add
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "店铺分类"
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "MyShopProductDefaultCategoryCell", bundle: nil), forCellReuseIdentifier: defaultCellID)
        tableView.register(UINib(nibName: "MyShopProductCategoryEditTableViewCell", bundle: nil), forCellReuseIdentifier: categoryID)
       let rightBarItem = UIBarButtonItem(image: UIImage(named: "bottom_ic_addto"), style: .plain, target: self, action: #selector(self.addNewCategoryAction(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCategoryList()
    }
    
    func addNewCategoryAction(_ sender: AnyObject) {
        selectedCategoryInfo = nil
        navigationController?.pushViewController(NewGoodsCategoryViewController(), animated: true)
    }
    
}

extension ShopCategoryManageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
              return defaulutDataArray.count
        case 1:
            return normalDataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
             guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellID, for: indexPath) as? MyShopProductDefaultCategoryCell else { return UITableViewCell() }
             cell.model = defaulutDataArray[indexPath.row]
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: categoryID, for: indexPath) as? MyShopProductCategoryEditTableViewCell else { return UITableViewCell() }
            cell.model = normalDataArray[indexPath.row]
            cell.editContentsView.isHidden = false
            configCellEditAction(cell)
            return cell
        default:
            break
        }
         return UITableViewCell()
    }
}

extension ShopCategoryManageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 15
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        case 1:
            return 90
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
}
// MARK: - Http request
extension ShopCategoryManageViewController {
    fileprivate func showEditAlter(_ goods: ShopProductCategoryInfo, finish: @escaping (_ newGoods: ShopProductCategoryInfo) -> Void) {
        var newgoods: ShopProductCategoryInfo = goods
        let aleter = UIAlertController(title: "编辑商品分类", message: "只能编辑分类名称", preferredStyle: .alert)
         let action0  = UIAlertAction(title: "取消", style: .default) { (_) in
        }
        let action1  = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            guard  let text = aleter.textFields?.first?.text else { return }
            newgoods.catName = text
            finish(newgoods)
        }
        aleter.addTextField { (textfield) in
            textfield.placeholder = "请输入商品分类名称"
        }
        aleter.addAction(action0)
        aleter.addAction(action1)
        present(aleter, animated: true, completion: nil)
    }
    
    fileprivate func configCellEditAction(_ cell: MyShopProductCategoryEditTableViewCell) {
        cell.editBlock = {[unowned self]  model in
           self.showEditAlter(model, finish: { [unowned self] (newGoods) in
              self.requestCategorySave(newGoods)
           })
        }
        
        cell.deleteBlock = {[unowned self]  model in
           self.requestCategoryDelete(model.catId)
        }
        
        cell.stickBlock = {[unowned self]  model in
           self.requestCategoryStickTop(model.catId, reverse: model.isTop)
        }
    }
    
  fileprivate  func requestCategorySave(_ goods: ShopProductCategoryInfo) {
       let parameters: [String: Any] = goods.toJSON()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()

        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeSaveCat(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else {return}
                if let _ = result["cat_id"] as? String {
                    if let _ = self.selectedCategoryInfo {
                        Utility.showMBProgressHUDToastWithTxt("修改分类成功")
                    } else {
                        Utility.showMBProgressHUDToastWithTxt("添加分类成功")
                    }
                    self.requestCategoryList()
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
    
   fileprivate func requestCategoryDelete(_ catId: String) {
        let parameters: [String: Any] = [
            "cat_id": catId
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showConfirmAlert(self, message: "确认要删除分类吗？", confirmCompletion: {
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(AFMRequest.storeDelCat(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
                if (object) != nil {
                    Utility.showMBProgressHUDToastWithTxt("删除分类成功")
                    self.requestCategoryList()
                } else {
                    if let msg = message {
                        Utility.showMBProgressHUDToastWithTxt(msg)
                    } else {
                        Utility.hideMBProgressHUD()
                    }
                }
            }
        })
        
    }
    
   fileprivate func requestCategoryStickTop(_ catId: String, reverse: Bool = false) {
        let parameters: [String: AnyObject] = [
            "cat_id": catId as AnyObject
            ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showConfirmAlert(self, message: (reverse ? "确认要移除置顶分类吗？" : "确认要置顶分类吗？"), confirmCompletion: {
            let request = reverse ? AFMRequest.storeUntopCat(parameters, aesKey, aesIV) : AFMRequest.storeTopCat(parameters, aesKey, aesIV)
            
            Utility.showMBProgressHUDWithTxt()
            RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
                if (object) != nil {
                    if reverse {
                        Utility.showMBProgressHUDToastWithTxt("移除置顶分类成功")
                    } else {
                        Utility.showMBProgressHUDToastWithTxt("置顶分类成功")
                    }
                    self.requestCategoryList()
                } else {
                    if let msg = message {
                        Utility.showMBProgressHUDToastWithTxt(msg)
                    } else {
                        Utility.hideMBProgressHUD()
                    }
                }
            }
        })
    }
    
  fileprivate  func requestCategoryList() {
        Utility.showMBProgressHUDWithTxt()
        let params = [String: Any]()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.storeCatList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {return}
                if let categoryList = result["cat_list"] as? [[String: Any]] {
                    self.dataArray.removeAll()
                    for category in categoryList {
                        guard let cate = Mapper<ShopProductCategoryInfo>().map(JSON: category) else {return}
                        self.dataArray.append(cate)
                    }
                    self.defaulutDataArray.removeAll()
                    self.normalDataArray.removeAll()
                    for i in 0...1 {
                        self.defaulutDataArray.append(self.dataArray[i])
                    }
                    for i in 2 ..< self.dataArray.count {
                        self.normalDataArray.append(self.dataArray[i])
                    }
                    self.tableView.reloadData()
                    
                    Utility.hideMBProgressHUD()
                } else {
                    Utility.hideMBProgressHUD()
                }
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }
}
