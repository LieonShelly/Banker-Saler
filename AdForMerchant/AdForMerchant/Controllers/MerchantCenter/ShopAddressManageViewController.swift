//
//  ShopAddressManageViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ShopAddressManageViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bottomButton: UIButton!
    
    fileprivate var dataArray: [ShopAddressInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "店铺地址"
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "CommonButtonAdd"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addNewAddressAction))
        navigationItem.rightBarButtonItem = rightBarItem
        
        tableView.register(UINib(nibName: "ShopInfoAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "ShopInfoAttributeTableViewCell")
        
//        bottomButton.addTarget(self, action: "changeStyleAction:", forControlEvents: .TouchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestAddressList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "ProductAddNewAddress@Product" {
//            let desVC = segue.destinationViewController as! ProductAddNewAddressViewController
//            desVC.completeBlock = { totalAmount, couponAmount in
//            }
//            
//        }

    }

    // MARK: - Button Action
    
    func addNewAddressAction() {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("ProductAddNewAddress@Product") as? ProductAddNewAddressViewController else {return}      
        vc.title = "添加新商户信息"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func nodataBgView() -> UIView {// type: 0 系统，1 个人
        let bgView = UIView(frame: tableView.bounds)
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 45, width: 138, height: 135))
        imgView.image = UIImage(named: "ShopAddressNoData")
        imgView.center = CGPoint(x: bgView.frame.size.width / 2, y: imgView.center.y)
        imgView.contentMode = .scaleAspectFill
        
        bgView.addSubview(imgView)
        
        let descLbl = UILabel(frame: CGRect(x: 55, y: 16 + imgView.frame.maxY, width: screenWidth - 110, height: 18))
        descLbl.font = UIFont.systemFont(ofSize: 15.0)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.text = "暂时没有店铺地址"
        descLbl.numberOfLines = 0
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 55, y: 39 + descLbl.frame.maxY, width: screenWidth - 110, height: 44)
        btn.backgroundColor = UIColor.commonBlueColor()
        btn.setTitle("现在去添加", for: UIControlState())
        btn.addTarget(self, action: #selector(self.addNewAddressAction), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 22
        bgView.addSubview(btn)
        
        return bgView
        
    }
    
    // MARK: - Http request
    
    func requestDeleteAddress(_ addressId: Int) {
//        let addressId 
        
        let parameters: [String: Any] = [
            "add_id": addressId
        ]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeDelAddress(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, msg) -> Void in
            
            Utility.hideMBProgressHUD()
            if (object) != nil {
                Utility.showAlert(self, message: "删除店铺地址成功")
                self.requestAddressList()
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
        }
        
    }
    
    func requestAddressList() {
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.storeAddressList(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, _) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {return}
                if let addressList = result["address_list"] as? [[String: Any]] {
                    self.dataArray.removeAll()
                    for address in addressList {
                        guard let address = Mapper<ShopAddressInfo>().map(JSON: address) else {return}
                        self.dataArray.append(address)
                    }
                    
                    if self.dataArray.isEmpty {
                        self.tableView.backgroundView = self.nodataBgView()
                    } else {
                        self.tableView.backgroundView = nil
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

extension ShopAddressManageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopInfoAttributeTableViewCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        
        }
    }
}

extension ShopAddressManageViewController: UITableViewDelegate {
    
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
        switch (indexPath.section, indexPath.row) {
        default:
            return 202
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _cell = cell as? ShopInfoAttributeTableViewCell else {return}
        let addressInfo = dataArray[indexPath.section]
        _cell.config(addressInfo)
        _cell.deleteBlock = { cCell in
            Utility.showConfirmAlert(self, message: "是否删除该地址？", confirmCompletion: {
                if let indexPath = self.tableView.indexPath(for: cCell) {
                    let info = self.dataArray[indexPath.section]
                    self.requestDeleteAddress(info.id)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = AOLinkedStoryboardSegue.sceneNamed("ProductAddNewAddress@Product") as? ProductAddNewAddressViewController else {return}
        vc.addressInfo = self.dataArray[indexPath.section]
        vc.title = "编辑地址"
        navigationController?.pushViewController(vc, animated: true)
    }
}
