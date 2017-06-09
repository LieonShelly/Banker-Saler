//
//  GoodsSetViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/31.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
private let cellID = "CampaginChooseItemCell"
class GoodsSetViewController: BaseViewController {
   fileprivate var selectedGoodsIDs: [String]?
   fileprivate var selectedGoodsConfigIDs: [String]?
   fileprivate lazy var segmentControl: UISegmentedControl = { [unowned self] in
        let control = UISegmentedControl(items: ["普通商品", "服务商品"])
        control.addTarget(self, action: #selector(self.segmentAction(_:)), for: .valueChanged)
        control.frame = CGRect(x: 0, y: 0, width: 66, height: 33)
        return control
    }()
   fileprivate lazy var contenView: ItemContenView = { [unowned self] in
        let normalVC = SetNormalGoodsViewController()
        let serviceVC = SetServiceGoodsViewController()
        let contenView = ItemContenView(frame: CGRect.zero, childVCs: [normalVC, serviceVC], parentVC: self)
        normalVC.choosedgoodsConfigIDsCallBack = {[unowned self] selctedGoodsConfigIDs, _ in
             self.selectedGoodsConfigIDs = selctedGoodsConfigIDs
         }
        serviceVC.selctedCallback = {[unowned self] selctedGoodsIDs in
           self.selectedGoodsIDs = selctedGoodsIDs
         }
        return contenView
        }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension GoodsSetViewController {
    fileprivate func setupUI() {
        segmentControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentControl
        segmentAction(segmentControl)
        view.addSubview(contenView)
        contenView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.top.equalTo(0)
        }
    }
    
    @objc fileprivate  func segmentAction(_ segment: UISegmentedControl) {
        contenView.selectedPage(segment.selectedSegmentIndex)
    }
}

extension GoodsSetViewController {
   
}
