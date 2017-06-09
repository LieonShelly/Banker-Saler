//
//  ShopProductMoveViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ShopProductCategorySelectionCell: UITableViewCell {
    @IBOutlet internal var selectionButton: UIButton!
    @IBOutlet internal var cateNameLabel: UILabel!
    @IBOutlet internal var countLabel: UILabel!
    internal var isCategorySelected: Bool = false {
        didSet {
            if isCategorySelected {
                selectionButton.isSelected = true
            } else {
                selectionButton.isSelected = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(_ title: String, count: String) {
        cateNameLabel.text = title
        countLabel.text = "共\(count)件商品"
    }
    
}

class ShopProductMoveViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    var type: GoodsType = .normal
    fileprivate var dataArray: [ShopProductCategoryInfo] = []
    fileprivate var selectedCategoryId: Int = 0
    var selectedProductIds: String = ""
    var confirmBlock: ((Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
//        dataArray += [false, true, false, true, false, true]
        requestCategoryList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Transition
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShopProductMovePresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShopProductMoveDismissingAnimator()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Action
    
    func addNewCategoryAction() {
        
    }
    
    func cancelAction() {
        confirmBlock?()
        dismiss(animated: true) { () -> Void in
            
        }
    }
    
    func confirmAction() {
        requestMoveCategory()
    }
    
    // MARK: - Methods
    
    // MARK: - Http request
    
    func requestCategoryList() {
        let param = ["type": type.rawValue]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeCatList(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {return}
                if let categoryList = result["cat_list"] as? [[String: Any]] {
                    self.dataArray.removeAll()
                    for category in categoryList {
                        guard let cate = Mapper<ShopProductCategoryInfo>().map(JSON: category) else {return}
                        self.dataArray.append(cate)
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
    
    func requestMoveCategory() {
        var parameters: [String: AnyObject] = [String: AnyObject]()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        var reuset: AFMRequest?
        if type == .normal {
            parameters = ["cat_id": selectedCategoryId as AnyObject, "goods_config_ids": selectedProductIds as AnyObject]
            reuset = AFMRequest.storeReclassifyGoodsConfig(parameters, aesKey, aesIV)
        } else {
            parameters = ["cat_id": selectedCategoryId as AnyObject, "goods_ids": selectedProductIds as AnyObject]
            reuset = AFMRequest.storeReclassifyServiceGoods(parameters, aesKey, aesIV)
        }
        Utility.showMBProgressHUDWithTxt()
        guard let request = reuset else {return}
        RequestManager.request(request, aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, msg) -> Void in
            Utility.hideMBProgressHUD()
            if msg == "" {
                if let block = self.confirmBlock {
                    block()
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
    }
}

extension ShopProductMoveViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopProductCategorySelectionCell", for: indexPath) as? ShopProductCategorySelectionCell else {return UITableViewCell()}
            return cell
        }
    }
}

extension ShopProductMoveViewController: UITableViewDelegate {
    
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
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let _cell = cell as? ShopProductCategorySelectionCell else {return}
        let cateInfo = dataArray[indexPath.row]

        _cell.isCategorySelected = (Int(cateInfo.catId) == selectedCategoryId)
        
        _cell.config(cateInfo.catName, count: "\(cateInfo.goodsNumb)")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cateInfo = dataArray[indexPath.row]
        selectedCategoryId = Int(cateInfo.catId) ?? 0
        tableView.reloadData()
        
    }
}
