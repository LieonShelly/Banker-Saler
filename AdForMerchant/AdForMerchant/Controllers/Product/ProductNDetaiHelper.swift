//
//  ProductNDetaiHelper.swift
//  AdForMerchant
//
//  Created by lieon on 2016/12/29.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

extension ProductNDetailViewController {
    func requestData() {
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        var param: [String: Any] = [:]
        param["goods_id"] = productID
        RequestManager.request(AFMRequest.goodsDetail(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if object != nil {
                if let result = object as? [String: Any] {
                    self.productModel = ProductDetailModel(JSON: result)
                    self.table.reloadData()
                }
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg, dismissCompletion: nil)
                }
            }
        }
    }
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func serviceGoodsIsOutDated() -> Bool {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.locale = Locale(identifier: "zh")
        guard let model = productModel, let closeTime =  format.date(from: model.closeTime) else {
            return false
        }
        if (Date().compare(closeTime) == .orderedDescending || Date().compare(closeTime) == .orderedSame) && productType == .service {
            return true
        }
        return false
       
    }
    
    func doMoreAction() {
        let modalViewController = NavPopoverViewController()
        modalViewController.offsetY = 69
        guard let model = productModel else { return  }
        if model.isApproved == .approved { // 审核过的状态有 出售中， 下架， 缺货
            switch (model.status, productType) {
            case (.readyForSale, .service):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_delay", "延期"),
                                                 ("product_btn_stock_replenishment", "补库存"),
                                                 ("product_btn_off_the_shelf", "下架"),
                                                 ("product_btn_share", "分享")]
            case (.noStock, .service),
                 (.noStock, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_btn_stock_replenishment", "补库存"),
                                                 ("product_btn_off_the_shelf", "下架"),
                                                 ("product_btn_share", "分享")]
            case (.offShelf, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_head_btn_edit", "编辑"),
                                                 ("product_btn_the_shelves", "提交审核"),
                                                 ("product_btn_delete", "删除")]
            case (.offShelf, .service):
                if serviceGoodsIsOutDated() {
                    modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                     ("product_btn_preview", "预览"),
                                                     ("product_head_btn_edit", "编辑"),
                                                     ("product_btn_the_shelves", "提交审核"),
                                                     ("product_btn_delete", "删除")]
                } else {
                    modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                     ("product_btn_preview", "预览"),
                                                     ("product_head_btn_edit", "编辑"),
                                                     ("product_btn_the_shelves", "提交审核")]
                }
            case (.readyForSale, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                 ("product_btn_stock_replenishment", "补库存"),
                                                 ("product_btn_off_the_shelf", "下架"),
                                                 ("product_btn_share", "分享")]
                default: break
            }

            } else { // 审核未通过的状态有 待审核 异常 草稿
                
            switch (model.isApproved, productType) {
            case (.waitingForReview, .service),
                 (.waitingForReview, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览")]
            case (.exception, .service),
                 (.exception, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_btn_preview", "预览"),
                                                ("product_head_btn_edit", "编辑"),
                                                 ("product_btn_delete", "删除")]
            case (.draft, .service),
                 (.draft, .normal):
                modalViewController.itemInfos = [("product_btn_copy", "复制"),
                                                 ("product_head_btn_edit", "编辑"),
                                                 ("product_btn_delete", "删除")]
            default:
                break
            }
        }
        
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = .custom
        modalViewController.selectItemCompletionBlock = {(index: Int) -> Void in
            self.modalAction(index)
        }
        self.navigationController?.present(modalViewController, animated: true, completion: nil)
    }
   private func deferProduct(type: ProductType, productID: String) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .edit
        destVC.productType = type
        destVC.productID = productID
        destVC.isdefer = true
        navigationController?.pushViewController(destVC, animated: true)
    }
    
  private  func addStockNum(type: ProductType, productID: String) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .edit
        destVC.productType = type
        destVC.productID = productID
        destVC.isAddStockNum = true
        navigationController?.pushViewController(destVC, animated: true)
        
    }
    
    /*
     //编辑
     AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: ProductType.service.rawValue)
     case 1://预览
     */
    
    func modalAction(_ index: Int) {
        guard let model = productModel else { return  }
        
        if model.isApproved == .approved { // 审核过的状态有 出售中， 下架， 缺货
            switch (model.status, productType) {
            case (.readyForSale, .service):
                switch index {
                case 0:
                    copy(productID: productID, type: .service)
                case 1:
                    deferProduct(type: .service, productID: productID)
                case 2:
                    addStockNum(type: .service, productID: productID)
                case 3:
                    offShelf()
                case 4:
                    shareItem()
                 default: break
                }
            
            case (.noStock, .service),
                 (.noStock, .normal):
                switch index {
                case 0:
                    copy(productID: productID, type: productType)
                case 1:
                    seePreview()
                case 2:
                    addStockNum(type: productType, productID: productID)
                case 3:
                    offShelf()
                case 4:
                    shareItem()
                default:
                    break
                }
                
            case (.offShelf, .normal):
                switch index {
                case 0:
                    copy(productID: productID, type: productType)
                case 1:
                    seePreview()
                case 2:
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: productType.rawValue)
                case 3:
                    onShelf()
                case 4:
                    delGoods()
                default:
                    break
                }
            case (.offShelf, .service):
                if serviceGoodsIsOutDated() {
                    switch index {
                    case 0:
                        copy(productID: productID, type: productType)
                    case 1:
                        seePreview()
                    case 2:
                        AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: productType.rawValue)
                    case 3:
                        onShelf()
                    case 4:
                        delGoods()
                    default:
                        break
                    }
                } else {
                    switch index {
                    case 0:
                        copy(productID: productID, type: productType)
                    case 1:
                        seePreview()
                    case 2:
                        AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: productType.rawValue)
                    case 3:
                        onShelf()
                        break
                    default:
                        break
                    }
                }
            case (.readyForSale, .normal):
                switch index {
                case 0:
                    copy(productID: productID, type: productType)
                case 1:
                    seePreview()
                case 2:
                    addStockNum(type: productType, productID: productID)
                case 3:
                    offShelf()
                case 4:
                    shareItem()
                default:
                    break
                }
            default: break
            }
            
        } else { // 审核未通过的状态有 待审核 异常 草稿
            
            switch (model.isApproved, productType) {
            case (.waitingForReview, .service),
                 (.waitingForReview, .normal):
                switch index {
                case 0:
                    copy(productID: productID, type: productType)
                case 1:
                    seePreview()
                default:
                    break
                }
                
            case (.exception, .service),
                 (.exception, .normal):
                switch index {
                case 0:
                    copy(productID: productID, type: productType)
                case 1:
                    seePreview()
                case 2:
                      AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: productType.rawValue)
                case 3:
                    delGoods()
                default:
                    break
                }
            case (.draft, .service),
                 (.draft, .normal):
                switch index {
                case 0:
                     copy(productID: productID, type: productType)
                case 1:
                    AOLinkedStoryboardSegue.performWithIdentifier("ProductEdit@Product", source: self, sender: productType.rawValue)
                case 2:
                    delGoods()
                default:
                    break
                }
            default:
                break
            }
        }
        
    }
    
    func seePreview() {
        let params = ["goods_id": productID]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsPreview(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            Utility.hideMBProgressHUD()
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            } else {
                if let result = object as? [String: Any], let html = result["html"] as? String {
                    AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: html)
                }
            }
        }
        
    }
    
    fileprivate func copy(productID: String, type: ProductType) {
        guard  let destVC = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductEdit") as? ProductAddNewViewController else { return }
        destVC.modifyType = .copy
        destVC.productType = type
        destVC.productID = productID
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func shareItem() {
        let shareVC = ShareViewController()
        guard let model = productModel else { return  }
        shareVC.shareTitle = model.title
        shareVC.shareDetailLink = model.shareUrl
        shareVC.shareItems = [.wechatFriends, .wechatCircle, .qqFriends, .copyLink]
        shareVC.transitioningDelegate = shareVC
        shareVC.modalPresentationStyle = .custom
        navigationController?.present(shareVC, animated: true, completion: nil)
    }
    
    func onShelf() {
        let params: [String: Any] = ["goods_id": productID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showConfirmAlert(self, message: "是否确认上架该商品", confirmCompletion: {
            RequestManager.request(AFMRequest.goodsPutaway(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                Utility.showAlert(self, message: "上架成功")
                self.requestData()
            })
        })
    }
    
    func offShelf() {
        
        let params: [String: Any] = ["goods_id": productID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showConfirmAlert(self, message: "是否确认下架该商品", confirmCompletion: {
            
            RequestManager.request(AFMRequest.goodsSoldout(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                Utility.showAlert(self, message: "下架成功")
                self.requestData()
            }
        })
    }
    
    func delGoods() {
        let params: [String: Any] = ["goods_id": productID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        Utility.showConfirmAlert(self, message: "是否确认删除该商品", confirmCompletion: {
            RequestManager.request(AFMRequest.goodsDel(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
                if object == nil {
                    if let msg = msg {
                        Utility.showAlert(self, message: msg)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    func keyboardWillShow(_ notifi: Notification) {
        guard  let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else { return }
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            self.table.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard  let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.table.contentInset = UIEdgeInsets.zero
            self.table.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        })
    }
}

extension ProductNDetailViewController {
    
    ///商品状态
    func cellStatus(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = productModel else { return }
        
        _cell.leftTxtLabel.text = "商品状态"
        _cell.rightTxtLabel.textColor = UIColor.commonBlueColor()
        // 为审核状态用isApproved字段判断
        if model.isApproved == .approved {
            switch  model.status {
            case .readyForSale:
                _cell.rightTxtLabel.text = "出售中"
            case .noStock:
                _cell.rightTxtLabel.text = "无库存"
            case .offShelf:
                _cell.rightTxtLabel.text = "已下架"
            default :break
            }
        } else {
             _cell.rightTxtLabel.text = model.isApproved.desc
        }
    }
    
    ///商品评分
    func cellScore(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品评分"
        _cell.rightTxtLabel.textColor = UIColor.commonOrangeColor()
        _cell.rightTxtLabel.text = String(format: "%.1f", Float(productModel?.grade ?? "0.0") ?? 0.0)
    }
    
    /// 商品货号 ProductChoosecodeCell
    func cellGoodsConfigID(_ cell: UITableViewCell) {
        guard let model = productModel, let _cell = cell as? ProductChoosecodeCell else {return}
        _cell.titleLabel.text = "商品货号"
        _cell.subTitleLabel.text = model.goodsConfigTitle+"("+"\(model.goodsConfigCode)"+")"
        _cell.dividerLine.backgroundColor = table.backgroundColor
        _cell.arrowIcon.isHidden = true
        _cell.arrowTrailingCons.constant = -10
    }
    ///参与次数
    func cellActive(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else {return}
        _cell.leftTxtLabel.text = "参与活动"
        _cell.rightTxtLabel.text = String(format: "%d", productModel?.events.count ?? 0)
        
        if self.productModel?.events.isEmpty == true {
            _cell.accessoryType = .none
        } else {
            _cell.accessoryType = .disclosureIndicator
        }
    }
    
    ///  商品封面
    func cellCover(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightImageTableViewCell else {return}
        _cell.leftTxtLabel.text = "商品封面"
        if let imageData = imageData {
            _cell.rightImageView.image = UIImage(data: imageData)
        } else {
            if productModel?.cover.isEmpty == false, let url = URL(string: productModel?.cover ?? "") {
                _cell.rightImageView.sd_setImage(with: url)
            }
        }
    }
    
    ///  商品名称
    func cellName(_ cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品名称"
        if  self.productModel?.title.isEmpty == false {
            _cell.rightTxtField.text = self.productModel?.title
        } else {
            _cell.rightTxtField.placeholder = "请输入简洁有特色的商品名称"
        }
        _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
    }
    
    ///  商品概述
    func cellSummary(_ cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品概述"
        if  self.productModel?.summary.isEmpty == false {
            _cell.rightTxtField.text = self.productModel?.summary
        } else {
            _cell.rightTxtField.placeholder = "请输入简洁的商品概述"
        }
        _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
        
    }
    
    ///  选择商品分类
    func cellGoodsCategory(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
        guard let model = productModel else { return  }
        _cell.leftTxtLabel.text = "商品分类"
        if self.productModel?.childCatName.isEmpty == false {
            _cell.rightTxtField.text = "\(model.catName), \(model.childCatName)"
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
        } else {
            _cell.rightTxtField.text = "未选择"
            _cell.rightTxtField.textColor = UIColor.black
        }
    }
    
    ///  选择店铺分类
    func cellShopCategory(_ cell: UITableViewCell) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return  }
        _cell.leftTxtLabel.text = "店铺分类"
        if self.productModel?.storeCatId.isEmpty == false {
            _cell.rightTxtField.text = self.productModel?.storeCatName
            _cell.rightTxtField.textColor = UIColor.commonGrayTxtColor()
        } else {
            _cell.rightTxtField.text = "未选择"
            _cell.rightTxtField.textColor = UIColor.black
        }
    }
    
    ///  添加商户信息
    func cellBusiness(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = productModel else { return  }
        _cell.leftTxtLabel.text = "商户信息"
        if self.productModel?.storesStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int(model.storesStruct.count))"
            _cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator
        } else {
            _cell.rightTxtLabel.text = "0"
            _cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        }
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    ///  商品描述
    func cellDetail(_ cell: UITableViewCell) {
        guard  let _cell = cell as? NormalDescTableViewCell else { return }
        _cell.txtLabel.textColor = UIColor.commonGrayTxtColor()
        if self.productModel?.detail.isEmpty == false {
            _cell.txtLabel.text = self.productModel?.detail
        } else {
            _cell.txtLabel.text = "请输入商品描述"
        }
    }
    
    ///  商品配图
    func cellGoodsImgs(_ cell: UITableViewCell) {
        guard let _cell = cell as? ProductDetailPhotoTableViewCell, let model = productModel  else { return }
        _cell.imgView1.image = UIImage(named: "CommonIconAddImage")
        _cell.moreImgBgView.isHidden = true
        
        _cell.imgView1.isHidden = true
        _cell.imgView2.isHidden = true
        _cell.imgView3.isHidden = true
        _cell.imgView4.isHidden = true
        for (index, value) in (model.imgsStruct.enumerated()) {
            switch index {
            case 0:
                _cell.imgView1.isHidden = false
                _cell.imgView1.sd_setImage(with: URL(string: value.file), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 1:
                _cell.imgView2.isHidden = false
                _cell.imgView2.sd_setImage(with: URL(string: value.file), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 2:
                _cell.imgView3.isHidden = false
                _cell.imgView3.sd_setImage(with: URL(string: value.file), placeholderImage: UIImage(named: "CommonGrayBg"))
            case 3:
                _cell.imgView4.isHidden = false
                _cell.imgView4.sd_setImage(with: URL(string: value.file), placeholderImage: UIImage(named: "CommonGrayBg"))
            default:
                break
            }
        }
        _cell.addCompletionBlock = {
            let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
            var  urlImgArr = [String]()
            for item in (model.imgsStruct) {
                urlImgArr.append(item.file)
            }
            detailVC.photosUrlArray = urlImgArr
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        _cell.detailCompletionBlock = {
            let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
            var  urlImgArr = [String]()
            guard let imgstruct = model.imgsStruct else { return  }
            for item in imgstruct {
                urlImgArr.append(item.file)
            }
            detailVC.photosUrlArray = urlImgArr
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        if model.imgsStruct.count > 4 {
            _cell.moreImgBgView.isHidden = false
            _cell.photoCountLabel.text = String(format: "%d", model.imgsStruct.count)
        }
        
        _cell.bottomNoteLabel.text = ""
        
        if self.productModel?.imgsStruct.isEmpty == true {
            _cell.imgView1.isHidden = false
            _cell.addCompletionBlock = nil
        }
        
    }
    
    ///商品平台价
    func cellPrice(_ cell: UITableViewCell) {
        guard  let _cell = cell as? CenterTxtFieldTableViewCell, let model = self.productModel else { return }
        
        _cell.leftTxtLabel.text = "商品平台价"
        if productModel?.price.isEmpty == false {
            _cell.centerTxtField.text = "￥\(model.price)"
        }
        _cell.centerTxtField.placeholder = "￥0.00"
        _cell.rightTxtLabel.text = "元"
        _cell.endEditingBlock = {(str) -> Void in
            self.productModel?.price = str
            //            self.bottomStatus()
        }
        _cell.isUserInteractionEnabled = false
        _cell.centerTxtField.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    ///商品市场价
    func cellMarketPrice(_ cell: UITableViewCell) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell, let model = self.productModel else { return }
        
        _cell.leftTxtLabel.text = "商品市场价"
        if productModel?.marketPrice.isEmpty == false {
            _cell.centerTxtField.text = "￥\(model.marketPrice)"
        }
        _cell.centerTxtField.placeholder = "￥0.00(选填)"
        _cell.rightTxtLabel.text = "元"
        _cell.endEditingBlock = {(str) -> Void in
            self.productModel?.marketPrice = str
        }
        _cell.isUserInteractionEnabled = false
        _cell.centerTxtField.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    ///商品积分
    func cellPoint(_ cell: UITableViewCell) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell, let model = self.productModel else { return }
        _cell.leftTxtLabel.text = "商品积分金额"
        _cell.centerTxtField.placeholder = "请输入数字"
        if self.productModel?.pointPrice.isEmpty == false {
            _cell.centerTxtField.text = "￥\(model.pointPrice)"
        }
        _cell.rightTxtLabel.text = "元"
        _cell.endEditingBlock = {(str) -> Void in
            self.productModel?.pointPrice = str
        }
        _cell.isUserInteractionEnabled = false
        _cell.centerTxtField.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
    }
    
    ///商品库存
    func cellStock(_ cell: UITableViewCell) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell else { return }
        
        _cell.centerTxtField.textColor = UIColor.commonGrayTxtColor()
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "商品库存"
        if productModel?.stockNum.isEmpty == false {
            _cell.centerTxtField.text = self.productModel?.stockNum
        }
        _cell.isUserInteractionEnabled = false
        _cell.centerTxtField.placeholder = "如. 123456"
        _cell.rightTxtLabel.text = "件"
        _cell.endEditingBlock = {(str) -> Void in
            self.productModel?.stockNum = str
        }
    }
    
    ///商品购买须知
    func cellRules(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = self.productModel else { return }
        
        _cell.rightTxtLabel.textColor = UIColor.black
        _cell.leftTxtLabel.text = "购买须知"
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        if self.productModel?.rulesStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int(model.rulesStruct.count))"
            _cell.accessoryType = .disclosureIndicator
        } else {
            _cell.rightTxtLabel.text = "0"
            _cell.accessoryType = .none
        }
    }
    
    ///商品运费
    func cellDelivery(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "商品运费"
        if let cost = productModel?.deliveryCost {
            _cell.rightTxtLabel.text = cost
        } else {
            _cell.rightTxtLabel.text = "包邮（默认）"
        }
    }
    
    //商品参数
    func cellParams(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = self.productModel else { return }
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "商品参数"
        if self.productModel?.paramsStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int(model.paramsStruct.count))"
            _cell.accessoryType = .disclosureIndicator
        } else {
            _cell.rightTxtLabel.text = "0"
            _cell.accessoryType = .none
        }
    }
    
    //商品规格
    func cellProperties(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = self.productModel else { return }
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "设置规格"
        let list = model.properList
        if list.isEmpty == false {
            var str = ""
            for value in list {
                guard let provalue = value.value else { continue }
                str += provalue + "/"
            }
            let ns = str as NSString
            let subns = ns.substring(to: str.characters.count - 1)
            _cell.rightTxtLabel.text = subns as String
            _cell.accessoryType = .disclosureIndicator
        } else {
            _cell.rightTxtLabel.text = "0"
            _cell.accessoryType = .none
        }
    }
    
    //消费券起始日期
    func cellStartTime(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = self.productModel else { return }
        
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "消费券起始日期"
        _cell.rightTxtLabel.text = ""
        if model.startTime.characters.count > 10 {
            let index = model.startTime.characters.index(model.startTime.endIndex, offsetBy: -9)
            _cell.rightTxtLabel.text = model.startTime.substring(to: index)
            
        } else {
            _cell.rightTxtLabel.text = self.productModel?.startTime
        }
    }
    
    //消费券结束日期
    func cellCloseTime(_ cell: UITableViewCell) {
        guard let _cell = cell as? DefaultTxtTableViewCell, let model = self.productModel else { return }
        _cell.rightTxtLabel.textColor = UIColor.commonGrayTxtColor()
        _cell.leftTxtLabel.text = "消费券截止日期"
        _cell.rightTxtLabel.text = ""
        if model.closeTime.characters.count > 10 {
            let index = model.closeTime.characters.index(model.closeTime.endIndex, offsetBy: -9)
            _cell.rightTxtLabel.text = self.productModel?.closeTime.substring(to: index)
        } else {
            _cell.rightTxtLabel.text = self.productModel?.closeTime
        }
    }
}
