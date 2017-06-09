//
//  CampaignProductFilterViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class CampaignProductFilterViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    
    internal var selectCompletionBlock: ((String) -> Void)?
    
    fileprivate var categoryDataArray: [GoodsCategoryModel] = []
    var selection: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "筛选类别"
        
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshFilterTag))
        navigationItem.rightBarButtonItem = rightBarItem
        
        tableView.register(UINib(nibName: "ProductCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCategoryTableViewCell")
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        confirmButton.setTitle("确定", for: UIControlState())
        
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func confirmAction() {
//        let navVCs = navigationController!.viewControllers
//        let destinationVC = navVCs[navVCs.count - 2]
//        navigationController?.popToViewController(destinationVC, animated: true)
        
        let catIdArray = selection.components(separatedBy: ",")
        let array = catIdArray.filter { $0 != ""}
        if array.contains("0") {
            selection = ""
        } else {
            selection = (array as NSArray).componentsJoined(by: ",")
        }
        
        if let block = selectCompletionBlock {
            block(selection)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshFilterTag() {
        selection = ""
        tableView.reloadData()
    }

    func requestData() {
        let params = ["type": "1"]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.goodsCatList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            
            if object == nil {
                Utility.showMBProgressHUDToastWithTxt(msg ?? "筛选类别信息获取失败")
                return
            }
            
           guard var result = object as? [String: AnyObject] else { return }
            guard let tempArray = result["cat_list"] as? [AnyObject] else { return }
            self.categoryDataArray = tempArray.flatMap({GoodsCategoryModel(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]())})
//            self.categoryDataArray.insert(GoodsCategoryModel(JSON: ["cat_id":"0", "cat_name":"全部分类"])!, atIndex: 0)
            
            self.tableView.reloadData()
            if !self.selection.isEmpty {
                for (index, category) in self.categoryDataArray.enumerated() where category.catId == self.selection {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                }
            }
        }
    }
}

extension CampaignProductFilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCategoryTableViewCell", for: indexPath)
        return cell
        
    }
}

extension CampaignProductFilterViewController: UITableViewDelegate {
    
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
        cell.selectionStyle = .none
        guard let pCell = cell as? ProductCategoryTableViewCell else { return }
        let cateData = categoryDataArray[indexPath.row]
        pCell.config(cateData.catName)
        if selection.components(separatedBy: ",").contains("0") {
            pCell.isCategorySelected = true
        } else {
            pCell.isCategorySelected = selection.components(separatedBy: ",").contains(cateData.catId)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cateData = categoryDataArray[indexPath.row]
        if cateData.catId == "0" {
            if selection.components(separatedBy: ",").contains(cateData.catId) {
                selection = ""
            } else {
                selection = "0"
            }
        } else {
            let catIdArray = selection.components(separatedBy: ",")
            if catIdArray.contains(cateData.catId) {
                let array = catIdArray.filter { $0 != cateData.catId}
                selection = (array as NSArray).componentsJoined(by: ",")
            } else {
                selection += ",\(cateData.catId)"
            }
        }
        tableView.reloadData()
    }
}
