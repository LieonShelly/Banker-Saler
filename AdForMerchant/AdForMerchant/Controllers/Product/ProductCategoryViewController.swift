//
//  ProductCategoryViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/4/16.
//  Copyright © 2016 Windward. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit

enum ProductCategoryLevel {
    case first, second
}

class ProductCategoryViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    
    var selectCompletionBlock: ((_ catId: String, _ catName: String, _ childCatId: String, _ childCatName: String) -> Void)?
    internal var categoryLevel: ProductCategoryLevel = .first
    
    var type: Int = 0
    fileprivate var goodsCategoryDataArray: [GoodsCategoryModel]! = [GoodsCategoryModel]()
    fileprivate var childCategoryDataArray: [ChildCats]! = [ChildCats]()
    fileprivate var categorySelectIndex: Int! = -1
    fileprivate var childCategorySelectIndex: Int! = -1
    
    var categorySelected: String?
    var childCategorySelected: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ProductCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryTableViewCell")
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        switch categoryLevel {
        case .first:
            navigationItem.title = "选择商品分类"
            confirmButton.setTitle("下一步", for: UIControlState())
            fetchData()
        case .second:
            navigationItem.title = "选择商品二级分类"
            confirmButton.setTitle("确定", for: UIControlState())
            refreshSelectedIndex()
        }
    }

    func fetchData() {
        let params = ["type": type]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsCatList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if object == nil {
                Utility.showMBProgressHUDToastWithTxt(msg ?? "分类信息获取失败")
                return
            }
            guard let result = object as? [String: AnyObject], let tempArray = result["cat_list"] as? [AnyObject] else { return }
            self.goodsCategoryDataArray = tempArray.flatMap({GoodsCategoryModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]())})
            self.refreshSelectedIndex()
            self.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ProductCategory@Product", let desVC = segue.destination as? ProductCategoryViewController, let cates = goodsCategoryDataArray {
            desVC.categoryLevel = .second
            desVC.type = self.type
            desVC.goodsCategoryDataArray = goodsCategoryDataArray
            desVC.childCategoryDataArray = cates[categorySelectIndex].childCatsStruct
            desVC.categorySelectIndex = self.categorySelectIndex
            desVC.childCategorySelected = self.childCategorySelected
            desVC.selectCompletionBlock = self.selectCompletionBlock
        }
    }
    
    func refreshSelectedIndex() {
        switch self.categoryLevel {
        case .first:
            for (index, cateInfo) in self.goodsCategoryDataArray.enumerated() where self.categorySelected == cateInfo.catId {
                self.categorySelectIndex = index
                break
            }
        case .second:
            for (index, cateInfo) in self.childCategoryDataArray.enumerated() where self.childCategorySelected == cateInfo.catId {
                self.childCategorySelectIndex = index
                break
            }
        }
    }
    
    @IBAction func confirmAction() {
        switch categoryLevel {
        case .first:
            if categorySelectIndex == -1 {
                Utility.showAlert(self, message: "请选择商品分类")
                return
            }
            AOLinkedStoryboardSegue.performWithIdentifier("ProductCategory@Product", source: self, sender: nil)
        case .second:
            if childCategorySelectIndex == -1 {
                Utility.showAlert(self, message: "请选择商品二级分类")
                return
            }
             guard let dataArray = goodsCategoryDataArray, let childCates = childCategoryDataArray  else { return  }
            selectCompletionBlock?(dataArray[categorySelectIndex].catId,
                                   dataArray[categorySelectIndex].catName,
                                   childCates[childCategorySelectIndex].catId,
                                   childCates[childCategorySelectIndex].catName)
            
            guard let vcs = self.navigationController?.viewControllers else { return  }
            _ = self.navigationController?.popToViewController(vcs[vcs.count - 3], animated: true)
        }
    }
}

extension ProductCategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch categoryLevel {
        case .first:
            return goodsCategoryDataArray?.count ?? 0
        case .second:
            return childCategoryDataArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCategoryTableViewCell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    
    }
}

extension ProductCategoryViewController: UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       guard let pCell = cell as? ProductCategoryTableViewCell else { return  }
        switch categoryLevel {
        case .first:
            pCell.config(goodsCategoryDataArray![indexPath.row].catName)
            if categorySelectIndex == indexPath.row {
                pCell.isCategorySelected = true
                pCell.selectionButton.isHidden = false
            } else {
                pCell.isCategorySelected = false
                pCell.selectionButton.isHidden = true
            }
        case .second:
            pCell.config(childCategoryDataArray![indexPath.row].catName)
            if childCategorySelectIndex == indexPath.row {
                pCell.isCategorySelected = true
                pCell.selectionButton.isHidden = false
            } else {
                pCell.isCategorySelected = false
                pCell.selectionButton.isHidden = true
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch categoryLevel {
        case .first:
            if categorySelectIndex == indexPath.row {
                categorySelectIndex = -1
            } else {
                categorySelectIndex = indexPath.row
            }
        case .second:
            if childCategorySelectIndex == indexPath.row {
                childCategorySelectIndex = -1
            } else {
                childCategorySelectIndex = indexPath.row
            }
        }
        self.tableView.reloadData()
    }
}
