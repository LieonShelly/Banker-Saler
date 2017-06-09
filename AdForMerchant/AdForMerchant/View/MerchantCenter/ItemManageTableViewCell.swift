//
//  ItemManageTableViewCell.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/24.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ItemManageTableViewCell: UITableViewCell {
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
    var editBlock: ((_ indexPath: IndexPath) -> Void)?
    var deleteBlock: ((_ indexPath: IndexPath) -> Void)?
    var markButtonTapAction: (() -> Void)?
    var contentsViewTapAction: ((_ model: Goods) -> Void)?
    @IBOutlet weak var editContentsWidthCons: NSLayoutConstraint!
    @IBOutlet weak var editContentView: UIView!
    
    fileprivate weak var ownerTableView: UITableView?
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var markButton: UIButton?
    @IBOutlet weak var specLabel: UILabel!
    @IBOutlet weak var cateLabel: UILabel!
    @IBOutlet weak var shopCateLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var contentViewLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var contentsView: UIView!
    
    @IBAction func markButtonAction(_ sender: UIButton) {
        if let block = self.markButtonTapAction {
            block()
        }
    }
    @IBAction func editAction(_ sender: AnyObject) {
        if let block = self.editBlock {
            block(self.slectedIndexPath())
        }
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        if let block = self.deleteBlock {
            block(self.slectedIndexPath())
        }
    }
    
    func configItemCampagin(_ model: Goods) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.contsTapAction))
        contentsView.addGestureRecognizer(tap)
        
    }
    func configItemManage(_ model: Goods) {
        self.model = model
        contentViewLeadingCons.constant = 0
        self.editContentsWidthCons.constant = self.contentViewLeadingCons.constant
        editContentView.isHidden = true
        markButton?.isHidden = true
        layoutIfNeeded()
    }

    func configChooseItem(_ model: Goods) {
        self.model = model
        editContentView.isHidden = true
        self.editContentsWidthCons.constant = 0
        layoutIfNeeded()
    }
    
    func configEditMode(_ model: Goods) {
        self.model = model
        editContentView.isHidden = false
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            self.contentViewLeadingCons.constant = 150
            self.editContentsWidthCons.constant = self.contentViewLeadingCons.constant
            self.layoutIfNeeded()
        }) 
    }
}

extension ItemManageTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        editContentView.isHidden = true
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let tableView = (newSuperview?.superview) as? ItemManageTableView else { return  }
        ownerTableView = tableView
    }
    
    override var isSelected: Bool {
        didSet {
            markButton?.isSelected = isSelected
        }
    }
}
extension ItemManageTableViewCell {
   fileprivate func slectedIndexPath() -> IndexPath {
        guard let tableView =  ownerTableView else { return  IndexPath(row: 0, section: 0) }
        guard let idx = tableView.indexPath(for: self) else {
            return IndexPath(row: 0, section: 0)
        }
        return idx
    }
    
  @objc fileprivate func contsTapAction() {
    if let block = contentsViewTapAction {
         guard let goods = model else { return  }
        block(goods)
     }
    }
}
