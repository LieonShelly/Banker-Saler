//
//  MyShopProductCategoryEditTableViewCell.swift
//  AdForMerchant
//
//  Created by Kuma on 2/25/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class MyShopProductCategoryEditTableViewCell: UITableViewCell {
    var editBlock: ((_ model: ShopProductCategoryInfo) -> Void)?
    var stickBlock: ((_ model: ShopProductCategoryInfo) -> Void)?
    var deleteBlock: ((_ model: ShopProductCategoryInfo) -> Void)?
    @IBOutlet weak var editContentsView: UIView!
    @IBOutlet internal var leftTopTxtLabel: UILabel!
    @IBOutlet internal var leftBottomTxtLabel: UILabel!
    @IBOutlet internal var editButton: UIButton!
    @IBOutlet internal var stickButton: UIButton!
    @IBOutlet internal var deleteButton: UIButton!
    @IBOutlet weak var cateLabel: UILabel!
    
    var isStickOnTop: Bool = false {
        didSet {
            stickButton.isSelected = isStickOnTop
        }
    }
    
    var model: ShopProductCategoryInfo? {
        didSet {
             guard let num = model?.goodsNumb else { return  }
            leftTopTxtLabel.text = model?.catName
            leftBottomTxtLabel.text = "共\(num)件商品"
            cateLabel.text = model?.type.title
            cateLabel.backgroundColor = model?.type.backgroudColor
            guard let model = model else {return}
            stickButton.isSelected =  (model.isTop)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cateLabel.layer.cornerRadius = 10
        cateLabel.layer.masksToBounds = true
        editContentsView.isHidden = true
        editButton.addTarget(self, action: #selector(self.editAction(_:)), for: .touchUpInside)
        stickButton.addTarget(self, action: #selector(self.stickAction(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(self.deleteAction(_:)), for: .touchUpInside)
    }
}

extension MyShopProductCategoryEditTableViewCell {
    func editAction(_ sender: AnyObject) {
        if let block = editBlock {
            if let model = self.model {
                block(model)
            }
        }
    }
    
    func stickAction(_ sender: AnyObject) {
        if let block = stickBlock {
            if let model = self.model {
                block(model)
            }
        }
    }
    
    func deleteAction(_ sender: AnyObject) {
        if let block = deleteBlock {
            if let model = self.model {
                block(model)
            }
        }
    }
}
