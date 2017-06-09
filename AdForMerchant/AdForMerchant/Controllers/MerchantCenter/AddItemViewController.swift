//
//  AddItemViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let setpControlHeight: CGFloat = 80
private let goNextStepHeight: CGFloat = 44
private let itemWidth: CGFloat = screenWidth
private let itemHeight: CGFloat = screenHeight - setpControlHeight - goNextStepHeight
class AddItemViewController: BaseViewController {
    var newItem: Goods = Goods()
    
    fileprivate lazy var setpControl: StepPageControl = {
        let step = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        step.stepTitleArray = ["设置货号", "选择商品分类", "设置规格"]
        return step
    }()
    
    fileprivate lazy var goNextStepView: GoNextStepView = {
        let nextview = GoNextStepView()
        nextview.delegate = self
        return nextview
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: UIControlState())
        btn.titleLabel?.textColor = UIColor.white
        btn.addTarget(self, action: #selector(self.cancelAtion), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        return btn
    }()

     lazy var contenView: ItemContenView = { [unowned self] in
        let codeVC = SetItemCodeViewController()
        let cateVC = SetItemCategoryViewController()
        let specVC = SetSpecificationViewController()
        codeVC.view.backgroundColor = UIColor.blue
        cateVC.view.backgroundColor = UIColor.red
        specVC.view.backgroundColor = UIColor.yellow
        let contenView = ItemContenView(frame: CGRect.zero, childVCs: [codeVC, cateVC, specVC], parentVC: self)
        contenView.backgroundColor = UIColor.randomColor()
        return contenView
    }()

    fileprivate var currentPage: Int = 0 {
        didSet {
            switch currentPage {
            case 0:
                goNextStepView.animateOnlyNextStep = true
                goNextStepView.nextStepButtonTitle = "下一步"
            case 1:
                if validInputCode() == false {
                    currentPage = 0
                    return
                }
                goNextStepView.animateOnlyNextStep = false
                goNextStepView.nextStepButtonTitle = "下一步"
            case 2:
                if validInputCate() == false {
                    currentPage = 1
                    return
                }
                goNextStepView.animateOnlyNextStep = false
                goNextStepView.nextStepButtonTitle = "确定添加"
                
            case 3:
                commitAction()
            default:
                break
            }
            if currentPage < 3 {
                setpControl.selectSubVeiwByIndex(currentPage)
                contenView.selectedPage(currentPage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initilaData()
    }
}

extension AddItemViewController {
     func setupUI() {
        navigationItem.title = "添加商品货号"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        view.backgroundColor = UIColor.white
        view.addSubview(setpControl)
        view.addSubview(goNextStepView)
        view.addSubview(contenView)
        goNextStepView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
       contenView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-44)
            make.top.equalTo(80)
        }
    }
    
    func initilaData() {
        newItem.propList = [GoodsProperty]()
    }
    
    func cancelAtion() {
        dismiss(animated: true, completion: nil)
    }
    
   fileprivate func commitAction() {
    view.endEditing(true)
    /// 剔除垃圾数据
    guard let list = newItem.propList else { return }
    
    let newarray = list.filter {
        if let title = $0.title {
            return !(title.isEmpty)
        } else {
            return false
        }
    }
    newItem.propList = newarray
    let params = newItem.toJSON()
    let aesKey = AFMRequest.randomStringWithLength16()
    let aesIV = AFMRequest.randomStringWithLength16()
    validInput(newItem) { (flag, message) in
        if !flag {
            let aleter = UIAlertController(title: "温馨提示", message:message, preferredStyle: .alert)
            let action0 = UIAlertAction(title: "好的", style: .default, handler: nil)
            aleter.addAction(action0)
            self.present(aleter, animated: true, completion: nil)
            return
        }
    }
    RequestManager.request(AFMRequest.saveGoods(params, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, object, error, msg) in
        if msg == "" {
              self.dismiss(animated: true, completion: nil)
        } else {
            if let msg = msg {
                Utility.showAlert(self, message: msg)
            }
        }
      
       }
    }
    
    fileprivate func validInputCode() -> Bool {
        if newItem.title == nil {
            Utility.showAlert(self, message: "请输入货号标题")
            return false
        }
        if let title = newItem.title, title.isEmpty {
            Utility.showAlert(self, message: "请输入货号标题")
            return false
        }
        if newItem.code == nil {
            Utility.showAlert(self, message: "请输入货号")
            return false
        }
        if let code = newItem.code, code.isEmpty {
            Utility.showAlert(self, message: "请输入货号")
            return false
        }
        return true
    }
    
    fileprivate func validInputCate() -> Bool {
        if newItem.storeCatID == nil {
            Utility.showAlert(self, message: "请输入商店铺分类")
            return false
        }
        if let storeCatID = newItem.storeCatID, storeCatID.isEmpty {
            Utility.showAlert(self, message: "请输入商店铺分类")
            return false
        }
        if newItem.childCatID == nil {
            Utility.showAlert(self, message: "请输入平台分类")
            return false
        }
        if let childID = newItem.childCatID, childID.isEmpty {
            Utility.showAlert(self, message: "请输入平台分类")
            return false
        }
        return true
    }
    
    fileprivate  func validInput(_ input: Goods, vaildBlock: (_ flag: Bool, _ message: String) -> Void) {
        var msg = "请输入"
        if input.title == nil {
            msg.append("标题")
            vaildBlock(false, msg)
        } else if input.code == nil {
            msg.append("货号")
             vaildBlock(false, msg)
        } else if input.storeCatID == nil {
            msg.append("店铺分类")
             vaildBlock(false, msg)
        } else if input.catID == nil {
            msg.append("商品一级分类")
             vaildBlock(false, msg)
        } else if input.childCatID == nil {
            msg.append("商品二级分类")
             vaildBlock(false, msg)
        }
       return vaildBlock(true, "")
    }
}

extension AddItemViewController: GoNextOrPreviousStep {
    func goNextOrPrevious(next: Bool) {
        if next {
            currentPage += 1
            if currentPage > 3 {
                currentPage = 3
            }
        } else {
            if currentPage == 3 {
                currentPage -= 2
            } else {
               currentPage -= 1
            }
            if currentPage < 0 {
                currentPage = 0
            }
        }
//        print(currentPage)
    }
}
