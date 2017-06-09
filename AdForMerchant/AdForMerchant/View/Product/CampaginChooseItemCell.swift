//
//  CampaginChooseItemCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/31.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class CampaginChooseItemCell: UITableViewCell {
    var contentsViewTapAction: ((_ model: Goods) -> Void)?
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var specLabel: UILabel!
    @IBOutlet weak var cateLabel: UILabel!
    @IBOutlet weak var shopCateLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    fileprivate var  tap = UITapGestureRecognizer()
    var model: Goods? {
        didSet {
            guard let codestr = model?.code, let title = model?.title, let properList = model?.propList, let cate = model?.catName, let shopCate = model?.storeCatName, let num = model?.goodsNum  else {
                return
            }
            var str = " "
            for txt in properList {
                if let text = txt.title {
                    str += text + "、"
                }
            }
            let ns = str as NSString
            let  subStr = ns.substring(to: str.characters.count - 1)
            specLabel.text = "规格: " + subStr as String
            codeLabel.text = "货号" + codestr + "(\(title))"
            cateLabel.text = "平台分类: " + cate
            shopCateLabel.text = "店铺分类: " + shopCate
            numLabel.text = num + "件商品"
        }
    }
    
}

extension CampaginChooseItemCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        tap.addTarget(self, action: #selector(self.contsTapAction))
        contentsView.addGestureRecognizer(tap)
        
    }
}

extension CampaginChooseItemCell {
    func removeGesture() {
        contentsView.removeGestureRecognizer(tap)
    }
}

extension CampaginChooseItemCell {
    @objc fileprivate func contsTapAction() {
        if let block = contentsViewTapAction {
            guard let goods = model else { return  }
            block(goods)
        }
    }
}
