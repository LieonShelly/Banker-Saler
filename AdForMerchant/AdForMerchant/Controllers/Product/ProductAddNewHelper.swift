//
//  ProductAddNewHelper.swift
//  AdForMerchant
//
//  Created by lieon on 2016/12/29.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ALCameraViewController
import ObjectMapper

extension ProductAddNewViewController {
    
    func addStockNum(goodsID: String, num: Int) {
        let param: [String: Any] = ["goods_id": goodsID,
                     "num": num]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.addNum(param, aesKey, aesIV)) { (_, _, _, _, msg) in
            if let msg = msg, !msg.isEmpty {
                Utility.showAlert(self, message: msg)
            } else {
                Utility.showMBProgressHUDToastWithTxt("库存量修改成功", customView: nil, hideAfterDelay: 2.0)
               _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func postone(goodsID: String, date: String) {
        let param: [String: Any] = ["goods_id": goodsID,
                                    "close_time": date]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.postpone(param, aesKey, aesIV)) { (_, _, _, _, msg) in
            if let msg = msg, !msg.isEmpty {
                Utility.showAlert(self, message: msg)
            } else {
                Utility.showMBProgressHUDToastWithTxt("消费券截止日期修改成功", customView: nil, hideAfterDelay: 2.0)
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func requestSeletedItemFinalGoods(_ item: Goods) {
        if item.goodsConfigID == nil {
            Utility.showAlert(self, message: "请选择货号")
            return
        }
        guard let id = item.goodsConfigID else { return  }
        let param: [String: Any] = ["goods_config_id": id]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsConfigGetFinalGoods(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, _, msg) in
            if msg != "" {
                Utility.showAlert(self, message: msg ?? "")
                return
            }
            guard let dict = object as? [String: Any] else { return }
            self.productModel = Mapper<ProductDetailModel>().map(JSON: dict) ?? ProductDetailModel()
            guard let id = item.goodsConfigID else { return  }
            self.productModel.goodsConfigID = id
            self.productModel.properList = (item.propList) ?? [GoodsProperty]()
            self.productModel.type = "1"
            self.imageData = nil
            self.tableView.reloadData()
        }
    }
    
    func requestData() {
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        let param: [String: Any] = ["goods_id": productID]
        RequestManager.request(AFMRequest.goodsDetail(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                self.productModel = ProductDetailModel(JSON: result) ?? ProductDetailModel()
                if self.modifyType == .copy {
                    self.productID = ""
                }
                if self.modifyType == .edit {
                    self.unEditProduct = ProductDetailModel(JSON: result) ?? ProductDetailModel()
                }
                self.tableView.reloadData()
            } else {
                Utility.showAlert(self, message: msg ?? "")
            }
        }
    }
    
    func requestUploadImage() {
        guard let data = imageData else { return  }
        let parameters: [String: Any] = [
            "cover": data,
            "prefix[cover]": "goods/cover"
        ]
        Utility.showMBProgressHUDWithTxt()
        RequestManager.uploadImage(AFMRequest.imageUpload, params: parameters) { (_, _, object, error) -> Void in
            Utility.hideMBProgressHUD()
            if (object) != nil {
                guard let result = object as? [String: AnyObject] else { return }
                guard let photoUploadedArray = result["success"] as? [AnyObject] else { return }
                
                if let photoInfo = photoUploadedArray.first, let coverImgUrl = photoInfo["url"] as? String {
                    self.productModel.cover = coverImgUrl
                    Utility.hideMBProgressHUD()
                    self.tableView.reloadData()
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            } else {
                if let userInfo = error?.userInfo, let msg = userInfo["message"] as? String {
                    Utility.showMBProgressHUDToastWithTxt(msg)
                } else {
                    Utility.showMBProgressHUDToastWithTxt("上传失败，请稍后重试")
                }
            }
        }
        
        self.dismiss(animated: true) { () -> Void in
            self.tableView.reloadData()
        }
        
    }
    
    func validateNormalProductParams() {
        //判断必填项是否完整
        if productModel.cover.isEmpty == true {
            Utility.showAlert(self, message: "请上传商品封面")
            return
        }
        if productModel.title.isEmpty == true {
            Utility.showAlert(self, message: "请输入商品名称")
            return
        }
        if productModel.title.characters.count > 30 {
            Utility.showAlert(self, message: "商品名称应该是30个字以内汉字、英文字母或数字组成")
            return
        }
        if productModel.summary.isEmpty == true {
            Utility.showAlert(self, message: "请输入商品概述")
            return
        }
        if productModel.detail.isEmpty == true {
            Utility.showAlert(self, message: "请输入商品描述")
            return
        }
        if productModel.price.isEmpty == true {
            Utility.showAlert(self, message: "请输入平台价")
            return
        }
        guard let price = Float(productModel.price) else { return  }
        if price < 0.1 {
            Utility.showAlert(self, message: "商品平台价不低于0.10元")
            return
        }
        if productModel.marketPrice.isEmpty == true {
            Utility.showAlert(self, message: "请输入市场价")
            return
        }
        guard let marketPrice = Float(productModel.marketPrice) else { return  }
        if productModel.marketPrice.isEmpty {
            if marketPrice < price {
                Utility.showAlert(self, message: "市场价必须大于平台价")
                return
            }
        }
        if productModel.pointPrice.isEmpty == true {
            Utility.showAlert(self, message: "请设置商品积分金额")
            return
        }
        let percent = (Float(productModel.pointPrice) ?? 0) / (Float(productModel.price) ?? 1)
        
        if percent < 0.05 || percent > 0.5 {
            let msg = String(format: "积分金额的值范围【%.2f，%.2f之间】", price * 0.05, price * 0.5)
            Utility.showAlert(self, message: msg)
            return
        }
        if productModel.stockNum.characters.count < 1 {
            Utility.showAlert(self, message: "请输入商品库存")
            return
        }
        if productModel.stockNum.characters.count > 4 {
            Utility.showAlert(self, message: "商品库存不能大于9999件")
            return
        }
        guard let stockNum = Int(productModel.stockNum) else { return  }
        if stockNum <= 0 {
            Utility.showAlert(self, message: "库存必须大于0")
            return
        }
        for proper in productModel.properList {
            guard let id = proper.value else { return  Utility.showAlert(self, message: "请填写规格内容") }
            if id.isEmpty {
                Utility.showAlert(self, message: "规格内容不能为空")
                return
            }
        }
        requestAddNormalProductData()
    }
    
    func isNeedSaveNewServiceProductAsDraft() -> Bool {
        if productType != .service {
            return false
        }
        if !productModel.cover.characters.isEmpty ||
            !productModel.title.isEmpty ||
            !productModel.summary.characters.isEmpty ||
            !productModel.detail.characters.isEmpty ||
            !productModel.price.characters.isEmpty ||
            !productModel.marketPrice.characters.isEmpty ||
            !productModel.pointPrice.characters.isEmpty ||
            !productModel.stockNum.characters.isEmpty ||
            !productModel.startTime.characters.isEmpty ||
            !productModel.closeTime.characters.isEmpty {
            return true
        }
        
        return false
    }
    
    func isNeedSaveNewNormalProductAsDraft() -> Bool {
        if productType != .normal {
            return false
        }
        if !productModel.title.characters.isEmpty ||
            !((productModel.goodsConfigID) ?? "").characters.isEmpty ||
            !productModel.cover.characters.isEmpty ||
            !productModel.summary.characters.isEmpty ||
            !productModel.detail.characters.isEmpty ||
            !productModel.imgsStruct.isEmpty ||
            !productModel.price.characters.isEmpty ||
             !productModel.marketPrice.characters.isEmpty ||
            !productModel.pointPrice.characters.isEmpty ||
            !productModel.stockNum.characters.isEmpty ||
            !productModel.paramsStruct.isEmpty ||
            !productModel.properList.isEmpty {
            return true
        }
        return false
    }
    
    func createNormalProductParam() -> [String: Any] {
        var params: [String: Any] = [:]
        params["title"] = productModel.title
        params["summary"] = productModel.summary
        params["type"] = productModel.type
        params["cover"] = productModel.cover
        params["detail"] = productModel.detail
        params["price"] = productModel.price.isEmpty ? 0: productModel.price
        params["market_price"] = productModel.marketPrice.isEmpty ? 0: productModel.marketPrice
        params["point_price"] = productModel.pointPrice.isEmpty ? 0: productModel.pointPrice
        params["stock_num"] = productModel.stockNum.isEmpty ? 0: productModel.stockNum
        params["delivery_cost"] = productModel.deliveryCost.isEmpty ? 0: productModel.deliveryCost 
       
        if productModel.imgsStruct.isEmpty == false {
            //商品图片
            var imgArr: [Any] = []
            for item in productModel.imgsStruct {
                let dic = ["file": item.file]
                imgArr.append(dic)
            }
            params["img"] = imgArr
            
        }
        if productModel.paramsStruct .isEmpty == false {
            //商品参数
            var goodsArr: [Any] = []
            for value in productModel.paramsStruct {
                let dic = ["param_name": value.paramName,
                           "param_value": value.paramValue]
                goodsArr.append(dic)
            }
            params["params"] = goodsArr
        }
        //商品规格
        if productModel.properList.isEmpty == false {
            params["prop_list"] = productModel.properList.toJSON()
        }
        
        // 货号
        if let goodsConfigID = productModel.goodsConfigID {
             params["goods_config_id"] = goodsConfigID
        }
        return params
    }
    
    func creatServiceProductParam() -> [String: Any] {
        var params: [String: AnyObject] = [:]
        if productID.isEmpty == false {
            params["goods_id"] = productID as AnyObject?
        }
        params["title"] = productModel.title as AnyObject?
        params["summary"] = productModel.summary as AnyObject?
        params["type"] = productModel.type as AnyObject?
        params["cover"] = productModel.cover as AnyObject?
        params["cat_id"] = (productModel.catId.isEmpty ? (0 as AnyObject?) :  productModel.catId as AnyObject?)
        params["child_cat_id"] = productModel.childCatId.isEmpty ? (0 as AnyObject?):  productModel.childCatId as AnyObject?
        params["store_cat_id"] = productModel.storeCatId.isEmpty ? (0 as AnyObject?): productModel.storeCatId as AnyObject?
        params["detail"] = productModel.detail as AnyObject?
        params["price"] = productModel.price as AnyObject?
        params["market_price"] = productModel.marketPrice as AnyObject?
        params["point_price"] = productModel.pointPrice as AnyObject?
        params["stock_num"] = productModel.stockNum as AnyObject?
        params["delivery_cost"] = "0" as AnyObject?
        params["start_time"] = productModel.startTime as AnyObject?
        params["close_time"] = productModel.closeTime as AnyObject?
        
        //商品图片
        var imgArr = [AnyObject]()
        if let imagStruct = productModel.imgsStruct {
            for item in imagStruct {
                let dic = ["file": item.file]
                imgArr.append(dic as AnyObject)
            }
            params["img"] = imgArr as AnyObject?
        }
        
        var rulesArr = [AnyObject]()
        if let rules = productModel.rulesStruct {
            for item in rules {
                let dic = ["name": item.name,
                           "content": item.content]
                rulesArr.append(dic as AnyObject)
            }
            params["rules"] = rulesArr as AnyObject?
        }
        
        //参与店铺ID
        var storesArr = [AnyObject]()
        if let stores = productModel.storesStruct {
            for item in stores {
                storesArr.append(item.id as AnyObject)
            }
            params["stores"] = storesArr as AnyObject?
        }
        return params
    }
    
    func requestAddNormalProductData() {
        var params: [String: Any] = [:]
        params["title"] = productModel.title
        params["summary"] = productModel.summary
        params["type"] = productModel.type
        params["cover"] = productModel.cover
        params["cat_id"] = productModel.catId
        params["child_cat_id"] = productModel.childCatId
        params["store_cat_id"] = productModel.storeCatId
        params["detail"] = productModel.detail
        params["price"] = productModel.price.isEmpty ? 0: productModel.price
        params["market_price"] = productModel.marketPrice.isEmpty ? 0: productModel.marketPrice
        params["point_price"] = productModel.pointPrice.isEmpty ? 0: productModel.pointPrice
        params["stock_num"] = productModel.stockNum.isEmpty ? 0: productModel.stockNum
        params["delivery_cost"] = productModel.deliveryCost
        if modifyType != .copy {
            if productID.isEmpty == false {
                params["goods_id"] = productID
            }
        }
        if let imgSturct = productModel.imgsStruct {
            //商品图片
            var imgArr: [Any] = []
            for item in imgSturct {
                let dic = ["file": item.file]
                imgArr.append(dic)
            }
            params["img"] = imgArr
            
        }
        if let paramStruct = productModel.paramsStruct {
            //商品参数
            var goodsArr: [Any] = []
            for value in paramStruct {
                let dic = ["param_name": value.paramName,
                           "param_value": value.paramValue]
                goodsArr.append(dic)
            }
            params["params"] = goodsArr
        }
        //商品规格
        params["prop_list"] = productModel.properList.toJSON()
        // 货号
        params["goods_config_id"] = productModel.goodsConfigID
        //        if modifyType != .copy {
        //            params["goods_config_id"] = productModel.goodsConfigID
        //        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.goodsSave(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if object == nil {
                Utility.showAlert(self, message: msg ?? "")
                return
            } else {
                AOLinkedStoryboardSegue.performWithIdentifier("ObjectReleaseSucceed@Product", source: self, sender: nil)
            }
        }
    }
    
    func requestAddServiceProductData() {
        //判断必填项是否完整
        
        if productModel.cover.characters.count < 1 {
            Utility.showAlert(self, message: "请上传商品封面")
            return
        }
        if productModel.title.characters.count < 1 {
            Utility.showAlert(self, message: "请输入商品名称")
            return
        }
        if productModel.title.characters.count > 30 {
            Utility.showAlert(self, message: "商品名称应该是30个字以内汉字、英文字母或数字组成")
            return
        }
        
        if productModel.summary.characters.count < 1 {
            Utility.showAlert(self, message: "请输入商品概述")
            return
        }
        if productModel.detail.characters.count < 1 {
            Utility.showAlert(self, message: "请输入商品描述")
            return
        }
        if productModel.price.characters.count < 1 {
            Utility.showAlert(self, message: "请输入平台价")
            return
        }
        guard let price =  Float(productModel.price) else { return  }
        if price <= 0.1 {
            Utility.showAlert(self, message: "平台价必须大于0.1元")
            return
        }
        if productModel.marketPrice.characters.count < 1 {
            Utility.showAlert(self, message: "请输入市场价")
            return
        }
        guard let marketPrice =  Float(productModel.marketPrice) else { return  }
        if !productModel.marketPrice.isEmpty {
            if marketPrice < price {
                Utility.showAlert(self, message: "市场价必须大于平台价")
                return
            }
        }
        if productModel.pointPrice.characters.count < 1 {
            Utility.showAlert(self, message: "请设置商品积分金额")
            return
        }
        
        let percent = (Float(productModel.pointPrice) ?? 0) / (Float(productModel.price) ?? 1)
        if percent < 0.05 || percent > 0.5 {
            let msg = String(format: "积分金额的值范围【%.2f，%.2f之间】", (Float(productModel.price) ?? 0) * 0.05, (Float(productModel.price) ?? 0) * 0.5)
            Utility.showAlert(self, message: msg)
            return
        }
        if productModel.stockNum.characters.count < 1 {
            Utility.showAlert(self, message: "请输入商品库存")
            return
        }
        guard let stcokNum = Int(productModel.stockNum) else { return  }
        if stcokNum <= 0 {
            Utility.showAlert(self, message: "库存必须大于0")
            return
        }
        if productModel.startTime.characters.count < 1 {
            Utility.showAlert(self, message: "请设置消费券起始日期")
            return
        }
        if productModel.closeTime.characters.count < 1 {
            Utility.showAlert(self, message: "请设置消费券截止日期")
            return
        }
        var params: [String: AnyObject] = [:]
        if productID.isEmpty == false {
            params["goods_id"] = productID as AnyObject?
        }
        params["title"] = productModel.title as AnyObject?
        params["summary"] = productModel.summary as AnyObject?
        params["type"] = productModel.type as AnyObject?
        params["cover"] = productModel.cover as AnyObject?
        params["cat_id"] = productModel.catId as AnyObject?
        params["child_cat_id"] = productModel.childCatId as AnyObject?
        params["store_cat_id"] = productModel.storeCatId as AnyObject?
        params["detail"] = productModel.detail as AnyObject?
        params["price"] = productModel.price as AnyObject?
        params["market_price"] = productModel.marketPrice as AnyObject?
        params["point_price"] = productModel.pointPrice as AnyObject?
        params["stock_num"] = productModel.stockNum as AnyObject?
        params["delivery_cost"] = "0" as AnyObject?
        params["start_time"] = productModel.startTime as AnyObject?
        params["close_time"] = productModel.closeTime as AnyObject?
        
        //商品图片
        var imgArr = [AnyObject]()
        if let imagStruct = productModel.imgsStruct {
            for item in imagStruct {
                let dic = ["file": item.file]
                imgArr.append(dic as AnyObject)
            }
            params["img"] = imgArr as AnyObject?
        }
        
        var rulesArr = [AnyObject]()
        if let rules = productModel.rulesStruct {
            for item in rules {
                let dic = ["name": item.name,
                           "content": item.content]
                rulesArr.append(dic as AnyObject)
            }
            params["rules"] = rulesArr as AnyObject?
        }
        
        //参与店铺ID
        var storesArr = [AnyObject]()
        if let stores = productModel.storesStruct {
            for item in stores {
                storesArr.append(item.id as AnyObject)
            }
            params["stores"] = storesArr as AnyObject?
        }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.goodsSave(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if object == nil {
                Utility.showAlert(self, message: msg ?? "")
                return
            } else {
                AOLinkedStoryboardSegue.performWithIdentifier("ObjectReleaseSucceed@Product", source: self, sender: nil)
            }
            
        }
    }
    
    /// 商品上下架
    func shelves() {
        let params: [String: Any] = ["goods_id": productID]
        
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        if self.productModel.status == .offShelf || self.productModel.status == .waitingForReview {
            RequestManager.request(AFMRequest.goodsPutaway(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (_, _, object, error, msg) in
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                Utility.showAlert(self, message: "上架成功")
                self.requestData()
            })
        } else {
            RequestManager.request(AFMRequest.goodsSoldout(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
                if object == nil {
                    Utility.showAlert(self, message: msg ?? "")
                    return
                }
                Utility.showAlert(self, message: "下架成功")
                self.requestData()
            }
        }
    }
    
    /// 商品删除
    func delGoods() {
        let params: [String: Any] = ["goods_id": productID]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.goodsDel(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) in
            if object == nil {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
                return
            }
            Utility.showAlert(self, message: "删除成功")
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func validateEditable(_ indexPath: IndexPath) -> Bool {
        let cellType = productCellType(indexPath)
        
        switch modifyType {
        case .addNew, .copy:
            return true
        case .edit:
            switch cellType {
            case .cover, .goodsImgs, .stock, .goodsConfigID:
                return true
            default:
                if productModel.status == .offShelf || productModel.status == .waitingForReview {
                    return true
                } else {
                    return false
                }
                
            }
        }
    }
    
    func validateDisclosureIndicator(_ indexPath: IndexPath) -> Bool {
        let cellType = productCellType(indexPath)
        switch productType {
        case .normal:
            switch cellType {
            case .cover,
                 .name,
                 .summary:
                return true
            case .goodsCategory:
                return validateEditable(indexPath)
            case .shopCategory,
                 .detail,
                 .merchantInfo,
                 .rules:
                return true
            case .params,
                 .property,
                 .startTime,
                 .closeTime:
                return validateEditable(indexPath)
            default:
                return false
            }
        case .service:
            switch cellType {
            case .cover,
                 .name,
                 .summary:
                return true
            case .goodsCategory:
                return validateEditable(indexPath)
            case .shopCategory,
                 .detail,
                 .merchantInfo,
                 .rules:
                return true
            case .startTime,
                 .closeTime:
                return validateEditable(indexPath)
            default:
                return false
            }
        }
        
    }
}

extension ProductAddNewViewController {
    
    func showCoverHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch (modifyType, productType) {
        case (.addNew, .normal), (.copy, .normal):
            helpWebVC.requestURL = WebviewHelpDetailTag.productAddCover.detailUrl
        case (.edit, .normal):
            helpWebVC.requestURL = WebviewHelpDetailTag.productEditCover.detailUrl
        case (.addNew, .service), (.copy, .service):
            helpWebVC.requestURL = WebviewHelpDetailTag.serviceProductAddCover.detailUrl
        case (.edit, .service):
            helpWebVC.requestURL = WebviewHelpDetailTag.serviceProductEditCover.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func showPointHelpPage() {
        guard let helpWebVC = AOLinkedStoryboardSegue.sceneNamed("CommonWebViewScene@AccountSession") as? CommonWebViewController else { return }
        switch (modifyType, productType) {
        case (.addNew, .normal), (.copy, .normal):
            helpWebVC.requestURL = WebviewHelpDetailTag.productAddPoint.detailUrl
        case (.edit, .normal):
            helpWebVC.requestURL = WebviewHelpDetailTag.productEditPoint.detailUrl
        case (.addNew, .service), (.copy, .service):
            helpWebVC.requestURL = WebviewHelpDetailTag.serviceProductAddPoint.detailUrl
        case (.edit, .service):
            helpWebVC.requestURL = WebviewHelpDetailTag.serviceProductEditPoint.detailUrl
        }
        helpWebVC.title = "帮助"
        navigationController?.pushViewController(helpWebVC, animated: true)
    }
    
    func backAlertAction() {
        if  modifyType == .addNew || modifyType == .copy {
            handleNewProductAction()
        }
        
        if  modifyType == .edit {
            handleEditProductAction()
        }
        
    }
    
    func handleEditProductAction() {
        if isNeedSaveEditServiceProductAsDraft() ||
            isNeedSaveEditNormalProductAsDraft() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func isNeedSaveEditServiceProductAsDraft() -> Bool {
        if unEditProduct == productModel {
            return false
        } else {
            return true
        }
    }
    
    func isNeedSaveEditNormalProductAsDraft() -> Bool {
        if unEditProduct == productModel {
            return false
        } else {
            return true
        }
    }
    func handleNewProductAction() {
        if isNeedSaveNewServiceProductAsDraft() ||
            isNeedSaveNewNormalProductAsDraft() {
            showDraftAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveProductAsDraft() {
        if productType == .normal {
            saveNormalProductAsDraft()
        }
        if productType == .service {
            saveServiceProductAsDraft()
        }
    }
    
    func saveServiceProductAsDraft() {
        var param = creatServiceProductParam()
        param["is_approved"] = "3"
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.goodsSave(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if error != nil {
                Utility.showAlert(self, message: msg ?? "")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil, userInfo: ["ProductSaleStatus": ProductSaleStatus.draft.rawValue])
            }
            
        }
    }
    
    func saveNormalProductAsDraft() {
        var param = createNormalProductParam()
         param["is_approved"] = 3
        print(param)
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.goodsSave(param, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            Utility.hideMBProgressHUD()
            if error != nil {
                Utility.showAlert(self, message: msg ?? "")
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceNeedRefreshWhenNewProductAddedNotification), object: nil, userInfo: ["ProductSaleStatus": ProductSaleStatus.draft.rawValue])
            }
        }
    }
    
    func showDraftAlert() {
        let alert = UIAlertController(title: "温馨提示", message: "是否保存为草稿", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "保存", style: .default) { _ in
            self.saveProductAsDraft()
        }
        let unsaveAction = UIAlertAction(title: "不保存", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in }
        alert.addAction(saveAction)
        alert.addAction(unsaveAction)
        alert.addAction(cancleAction)
        present(alert, animated: true, completion: nil)
    }
    
    func pushToSetProductSpeVC() {
        let destVC = SetProductSpecViewController()
        guard let _ = productModel.goodsConfigID else { return   Utility.showAlert(self, message: "请选择货号") }
        destVC.model.propList = productModel.properList
        destVC.model.goodsConfigID = productModel.goodsConfigID
        destVC.newModelCallBack = { [unowned self] newModel in
            guard let list = newModel.propList else { return  }
            self.productModel.properList =  list
        }
        navigationController?.pushViewController(destVC, animated: true)
        
    }
    
    func keyboardWillShow(_ notifi: Notification) {
        guard  let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard  let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else { return }
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        })
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else { return }
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        })
    }
    
    func showAddPhotoAlertController() {
        
        let actionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionAlert.addAction(UIAlertAction(title: "选择相册", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.photoLibrary)
        }))
        actionAlert.addAction(UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.chooseFromType(.camera)
        }))
        actionAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionAlert, animated: true, completion: nil)
    }
    
    func chooseFromType(_ type: UIImagePickerControllerSourceType) {
        switch type {
        case .photoLibrary:
            let libraryViewController = CameraViewController.imagePickerViewController(croppingRatio: 1.0) { image, asset in
                if let image = image {
                    self.imageData = UIImageJPEGRepresentation(image, 0.8)
                    self.dismiss(animated: true, completion: {
                        self.requestUploadImage()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(libraryViewController, animated: true, completion: nil)
        case .camera:
            let cameraViewController = CameraViewController(croppingRatio: 1.0) { image, asset in
                if let image = image {
                    self.imageData = UIImageJPEGRepresentation(image, 0.8)
                    self.dismiss(animated: true, completion: {
                        self.requestUploadImage()
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            present(cameraViewController, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension ProductAddNewViewController {
    
    func setupUI() {
        switch (modifyType, productType) {
        case (.addNew, .normal), (.copy, .normal):
            navigationItem.title = "发布普通商品"
            productModel.type = "1"
        case (.addNew, .service), (.copy, .service):
            navigationItem.title = "发布服务商品"
            productModel.type = "2"
        case (.edit, .normal):
            navigationItem.title = "编辑商品"
            productModel.type = "1"
            bottomBtnBottomConstr.constant = 0
        case (.edit, .service):
            navigationItem.title = "编辑商品"
            productModel.type = "2"
            bottomBtnBottomConstr.constant = 0
        }
        if isAddStockNum {
            bottomBtn.setTitle("确定", for: UIControlState())
        } else {
             bottomBtn.setTitle("提交审核", for: UIControlState())
        }
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "CommonBackButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAlertAction))
        if !isNoticeSource {
            navigationItem.leftBarButtonItem = leftBarItem
        } 
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: "ProductChoosecodeCell", bundle: nil), forCellReuseIdentifier: "ProductChoosecodeCell")
        tableView.register(UINib(nibName: "DefaultTxtTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTxtTableViewCell")
        tableView.register(UINib(nibName: "CenterTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "CenterTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RightTxtFieldTableViewCell")
        tableView.register(UINib(nibName: "RightImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RightImageTableViewCell")
        tableView.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NormalDescTableViewCell")
        tableView.register(UINib(nibName: "ProductDetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailPhotoTableViewCell")
        tableView.register(UINib(nibName: "ProductStockTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductStockTableViewCell")
        tableView.separatorColor = tableView.backgroundColor
        
        //判断页面状态
        if modifyType == .edit || modifyType == .copy {
            requestData()
        }
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        tableView.reloadData()
    }
    
    func showAlter() {
        
        if willShowAlertWhenEnter && (modifyType == .addNew || modifyType == .copy) {
            willShowAlertWhenEnter = false
            let userDef = UserDefaults.standard
            
            switch productType {
            case .normal:
                
                if let _ = userDef.value(forKey: "NewNormalProductReleaseTipsNoMore") as? String {
                } else {
                    Utility.showConfirmAlert(self, title: "温馨提示", cancelButtonTitle: "不再提示", confirmButtonTitle: "我知道了", message: "需确保所售商品属于经营范围内且未在经营企业异常名录中", cancelCompletion: {
                        userDef.set("true", forKey: "NewNormalProductReleaseTipsNoMore")
                        userDef.synchronize()
                    }, confirmCompletion: {
                    })
                }
            case .service:
                if let _ = userDef.value(forKey: "NewServiceProductReleaseTipsNoMore") as? String {
                } else {
                    Utility.showConfirmAlert(self, title: "温馨提示", cancelButtonTitle: "不再提示", confirmButtonTitle: "我知道了", message: "需确保所售商品属于经营范围内且未在经营企业异常名录中", cancelCompletion: {
                        userDef.set("true", forKey: "NewServiceProductReleaseTipsNoMore")
                        userDef.synchronize()
                    }, confirmCompletion: {
                    })
                }
            }
            
        }
    }
    
    func productCellType(_ indexPath: IndexPath) -> ProductCellType {
        
        switch productType {
        case .normal:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): return .status
            case (1, _): return .cover
            case (2, 0): return .name
            case (2, 1): return .summary
            case (3, 0): return .goodsCategory
            case (3, 1): return .shopCategory
            case (4, _): return .detail
            case (5, _): return .goodsImgs
            case (6, 0): return .price
            case (6, 1): return .marketPrice
            case (7, 0): return .point
            case (8, 0): return .stock
            case (8, 1): return .delivery
            case (9, 0): return .params
            case (9, 1): return .property
            default: break
            }
        case .service:
            switch (indexPath.section, indexPath.row) {
            case (0, 0): return .status
            case (1, _): return .cover
            case (2, 0): return .name
            case (2, 1): return .summary
            case (3, 0): return .goodsCategory
            case (3, 1): return .shopCategory
            case (4, 0): return .merchantInfo
            case (5, _): return .detail
            case (6, _): return .goodsImgs
            case (7, 0): return .price
            case (7, 1): return .marketPrice
            case (8, 0): return .point
            case (9, 0): return .stock
            case (10, 0): return .rules
            case (11, 0): return .startTime
            case (11, 1): return .closeTime
            default: break
            }
        }
        return .undefined
    }
    /// 选择货号
    func cellCode(_ cell: UITableViewCell, indexPath: IndexPath) {
        /// ProductChoosecodeCell
        guard let _cell = cell as? ProductChoosecodeCell  else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.titleLabel.text = "选择货号"
        _cell.dividerLine.backgroundColor = tableView.backgroundColor
        _cell.subTitleLabel.text = goodsNumText
        if modifyType == .copy || modifyType == .edit {
            _cell.subTitleLabel.text = goodsNumText != "" ? goodsNumText : self.productModel.goodsConfigTitle + "(\(self.productModel.goodsConfigCode))"            
        }
    }
    ///  商品状态
    func cellStatus(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell  as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商品状态"
        
        switch productModel.status {
        case .waitingForReview:
            _cell.rightTxtLabel.text = "审核"
        case .readyForSale:
            _cell.rightTxtLabel.text = "出售中"
        case .noStock:
            _cell.rightTxtLabel.text = "无库存"
        case .offShelf:
            _cell.rightTxtLabel.text = "已下架"
        case .exception:
            _cell.rightTxtLabel.text = "异常"
        case .draft:
            _cell.rightTxtLabel.text = "草稿"
        }
    }
    
    ///  商品封面
    func cellCover(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? RightImageTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品封面"
        if let imageData = imageData {
            _cell.rightImageView.image = UIImage(data: imageData)
        } else if productModel.cover.isEmpty == false {
            _cell.rightImageView.sd_setImage(with: URL(string: (productModel.cover)))
        } else {
            _cell.rightImageView.image = nil
        }
        if modifyType == .copy {
            _cell.rightImageView.sd_setImage(with: URL(string: (productModel.cover)))
        }
    }
    
    ///  商品名称
    func cellName(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商品名称"
        _cell.rightTxtField.text = self.productModel.title
        _cell.rightTxtField.placeholder = "请输入简洁有特色的商品名称"
        if modifyType == .copy {
            _cell.rightTxtField.text = self.productModel.title
        }
    }
    
    ///  商品概述
    func cellSummary(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? RightTxtFieldTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商品概述"
        
        _cell.rightTxtField.text = self.productModel.summary
        
        _cell.rightTxtField.placeholder = "请输入简洁的商品概述"
        //        if  self.productModel.summary.isEmpty == false {
        //            _cell.rightTxtField.text = self.productModel.summary
        //        } else {
        //            _cell.rightTxtField.placeholder = "请输入简洁的商品概述"
        //        }
    }
    
    ///  选择商品分类
    func cellGoodsCategory(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商品分类"
        if self.productModel.childCatName.isEmpty == false {
            _cell.rightTxtLabel.text = "\(self.productModel.catName), \(self.productModel.childCatName)"
        } else {
            _cell.rightTxtLabel.text = ""
        }
        
    }
    
    ///  选择店铺分类
    func cellShopCategory(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        print("店铺分类"+"\(_cell.isEditableColor)")

        _cell.leftTxtLabel.text = "店铺分类"
        
        if self.productModel.storeCatId.isEmpty == false {
            _cell.rightTxtLabel.text = self.productModel.storeCatName
        } else {
            _cell.rightTxtLabel.text = ""
        }
    }
    
    ///  添加商户信息
    func cellBusiness(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商户信息"
        
        if self.productModel.storesStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int((self.productModel.storesStruct.count)))"
        } else {
            _cell.rightTxtLabel.text = ""
        }
        
    }
    
    ///  商品描述
    func cellDetail(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard  let _cell = cell as? NormalDescTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        if self.productModel.detail.isEmpty == false {
            _cell.txtLabel.text = self.productModel.detail
        } else {
            _cell.txtLabel.text = "商品使用方法、优缺点…详细的描述能使您的商品更撩人哦~（1000字以内）"
            _cell.txtLabel.textColor = UIColor.textfieldPlaceholderColor()
        }
    }
    
    ///  商品配图
    func cellGoodsImgs(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard  let _cell = cell as? ProductDetailPhotoTableViewCell else { return }
        _cell.imgView1.image = UIImage(named: "CommonIconAddImage")
        _cell.moreImgBgView.isHidden = true
        _cell.bottomNoteLabel.text = "上传商品配图，最多10张"
        
        _cell.imgView2.isHidden = true
        _cell.imgView3.isHidden = true
        _cell.imgView4.isHidden = true
        for (index, value) in (self.productModel.imgsStruct.enumerated()) {
            switch index {
            case 0:
                _cell.imgView2.isHidden = false
                _cell.imgView2.sd_setImage(with: URL(string: value.file))
            case 1:
                _cell.imgView3.isHidden = false
                _cell.imgView3.sd_setImage(with: URL(string: value.file))
            case 2:
                _cell.imgView4.isHidden = false
                _cell.imgView4.sd_setImage(with: URL(string: value.file))
            default:
                break
            }
        }
        if isAddStockNum {
            _cell.addCompletionBlock = _cell.detailCompletionBlock
        } else {
            _cell.addCompletionBlock = {
                let photoVC = AddPhotoViewController(nibName: "AddPhotoViewController", bundle: nil)
                var urlImgArr = [String]()
                guard let imgStruct = self.productModel.imgsStruct else { return  }
                for item in imgStruct {
                    urlImgArr.append(item.file)
                }
                photoVC.photosUrlArray = urlImgArr
                photoVC.completeBlock = { imgUrls in
                    var tempImgsArr = [Imgs]()
                    for value in imgUrls {
                        var imgStruct = Imgs()
                        imgStruct.file = value
                        tempImgsArr.append(imgStruct)
                    }
                    self.productModel.imgsStruct = tempImgsArr
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(photoVC, animated: true)
            }
        }

        _cell.detailCompletionBlock = {
            let detailVC = PhotoDetailViewController(nibName: "PhotoDetailViewController", bundle: nil)
            var  urlImgArr = [String]()
            guard let imgstruct = self.productModel.imgsStruct else { return  }
            for item in imgstruct {
                urlImgArr.append(item.file )
            }
            detailVC.photosUrlArray = urlImgArr
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        if self.productModel.imgsStruct.count > 3 {
            _cell.moreImgBgView.isHidden = false
            
        }
        if self.productModel.imgsStruct.count > 3 {
            _cell.moreImgBgView.isHidden = false
            _cell.photoCountLabel.text = String(format: "%d", (productModel.imgsStruct.count))
        }
    }
    
    /// 商品平台价
    func cellPrice(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard   let _cell = cell as? CenterTxtFieldTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "商品平台价格"
        if productModel.price == "" {
            _cell.centerTxtField.placeholder = "￥0.00"
            _cell.centerTxtField.text = ""
        } else {
            _cell.centerTxtField.text = "￥\(self.productModel.price)"
        }
        _cell.isNumberInputType = true
        _cell.rightTxtLabel.text = "元"
        
        if validateEditable(indexPath) {
            _cell.endEditingBlock = {(str) -> Void in
                self.productModel.price = str
                self.tableView.reloadData()
            }
            _cell.isEditableColor = true
        } else {
            _cell.endEditingBlock = nil
            _cell.isEditableColor = false
        }
        
    }
    
    /// 商品市场价
    func cellMarketPrice(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品市场价格"
        if productModel.marketPrice.isEmpty == true {
            _cell.centerTxtField.text = ""
            
            _cell.centerTxtField.placeholder = "￥0.00"
        } else {
            _cell.centerTxtField.text = "￥\(self.productModel.marketPrice)"
        }
        _cell.isNumberInputType = true
        _cell.rightTxtLabel.text = "元"
        if validateEditable(indexPath) {
            _cell.endEditingBlock = {(str) -> Void in
                self.productModel.marketPrice = str
            }
            _cell.isEditableColor = true
        } else {
            _cell.endEditingBlock = nil
            _cell.isEditableColor = false
        }
        
    }
    
    /// 商品积分
    func cellPoint(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品积分"
        _cell.centerTxtField.placeholder = "￥0.00"
        _cell.isNumberInputType = true
        if self.productModel.pointPrice.isEmpty == true {
            
            _cell.centerTxtField.placeholder = "￥0.00"
            _cell.centerTxtField.text = ""
        } else {
            _cell.centerTxtField.text = "￥\(self.productModel.pointPrice)"
        }
        _cell.rightTxtLabel.text = "元"
        
        if validateEditable(indexPath) {
            _cell.endEditingBlock = {(str) -> Void in
                self.productModel.pointPrice = str
                self.tableView.reloadData()
            }
            _cell.isEditableColor = true
        } else {
            _cell.endEditingBlock = nil
            _cell.isEditableColor = false
        }
    }
    
    /// 商品库存
    func configStock(_ cell: ProductStockTableViewCell) -> ProductStockTableViewCell {
        cell.endEditingBlock = {(str) -> Void in
            self.productModel.stockNum = str
        }
        if productModel.stockNum.isEmpty == true {
            cell.textField.placeholder = "如. 123456"
            cell.textField.text = ""
        } else {
            cell.textField.text = self.productModel.stockNum
        }
        if isAddStockNum {
            cell.endEditingBlock = { (str) -> Void in
                if let currentValue = Int(str) {
                    self.addedStockNum = currentValue
                } 
            }
        }
        return cell
    }
    
    func cellStock(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? CenterTxtFieldTableViewCell else { return }
        _cell.leftTxtLabel.text = "商品库存"
        _cell.maxCharacterCount = 4
        _cell.isNumberInputType = false
        if productModel.stockNum.isEmpty == true {
            _cell.centerTxtField.placeholder = "如. 123456"
            _cell.centerTxtField.text = ""
        } else {
            _cell.centerTxtField.text = self.productModel.stockNum
        }
        _cell.rightTxtLabel.text = "件"
        _cell.endEditingBlock = {(str) -> Void in
            //            print(str)
            self.productModel.stockNum = str
        }
        _cell.isEditableColor = true
        
        if isAddStockNum {
            _cell.endEditingBlock = { (str) -> Void in
                if let currentValue = Int(str) {
                     self.addedStockNum = currentValue
                }
            }
        }
    }
    
    /// 商品购买须知
    func cellRules(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "购买须知"
        if self.productModel.rulesStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int((self.productModel.rulesStruct.count)))"
        } else {
            _cell.rightTxtLabel.text = ""
        }
        
        if modifyType == .edit {
            if self.productModel.rulesStruct.isEmpty == false {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
                _cell.rightTxtLabel.text = "0"
            }
        }
    }
    
    /// 商品运费
    func configDelivery(_ cell: DefaultTxtTableViewCell) -> DefaultTxtTableViewCell {
        if isAddStockNum {
            cell.rightTxtLabel?.textColor = UIColor.commonGrayTxtColor()
        }
        cell.leftTxtLabel.text = "商品运费"
        cell.rightTxtLabel.text = "包邮（默认)"
        
        //        if productModel.deliveryCost.isEmpty == true {
        //            cell.centerTxtField.placeholder = "￥0.00"
        //            cell.centerTxtField.text = ""
        //        } else {
        //            cell.centerTxtField.text = "￥\(self.productModel!.deliveryCost)"
        //        }
        //        cell.endEditingBlock = {(str) -> Void in
        //            self.productModel.deliveryCost = str
        //        }
        return cell
    }
    
    /// 商品参数
    func cellParams(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "添加商品参数"
        if self.productModel.paramsStruct.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int((productModel.paramsStruct.count)))"
        } else {
            _cell.rightTxtLabel.text = "0"
        }
        if modifyType == .edit {
            _cell.leftTxtLabel.text = "商品参数"
            if self.productModel.paramsStruct.isEmpty == false {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    /// 商品规格
    func cellProperties(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "添加商品规格"
        if productModel.properList.isEmpty == false {
            _cell.rightTxtLabel.text = "\(Int((productModel.properList.count)))"
        } else {
            _cell.rightTxtLabel.text = "0"
        }
        if modifyType == .edit {
            _cell.leftTxtLabel.text = "商品规格"
            if productModel.properList.isEmpty == false {
                _cell.rightTxtLabel.text = "\(Int((productModel.properList.count)))"
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    /// 消费券起始日期
    func cellStartTime(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "消费券起始日期"
        _cell.rightTxtLabel.text = ""
        if productModel.startTime.characters.count > 10 {
            let index = productModel.startTime.characters.index(productModel.startTime.endIndex, offsetBy: -9)
            _cell.rightTxtLabel.text = productModel.startTime.substring(to: index)
        } else {
            _cell.rightTxtLabel.text = productModel.startTime
        }
    }
    
    //消费券结束日期
    func cellCloseTime(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard  let _cell = cell as? DefaultTxtTableViewCell else { return }
        _cell.isEditableColor = validateEditable(indexPath)
        _cell.leftTxtLabel.text = "消费券截止日期"
        _cell.rightTxtLabel.text = ""
        if productModel.closeTime.characters.count > 10 {
            let index = productModel.closeTime.characters.index(productModel.closeTime.endIndex, offsetBy: -9)
            _cell.rightTxtLabel.text = productModel.closeTime.substring(to: index)
        } else {
            _cell.rightTxtLabel.text = productModel.closeTime
        }
        
    }
}
