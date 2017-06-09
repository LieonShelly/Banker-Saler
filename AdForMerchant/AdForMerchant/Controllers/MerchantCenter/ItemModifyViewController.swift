//
//  ItemModifyViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/25.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let setpControlHeight: CGFloat = 80
private let goNextStepHeight: CGFloat = 44
private let itemWidth: CGFloat = screenWidth
private let itemHeight: CGFloat = screenHeight - setpControlHeight - goNextStepHeight
class ItemModifyViewController: BaseViewController {
    var newItem: Goods = Goods()
    
    fileprivate lazy var setpControl: StepPageControl = {
        let step = StepPageControl(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        step.stepTitleArray = ["设置货号", "设置商品名称", "设置规格"]
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
        let codeVC = ModifyItemCodeViewController()
        let cateVC = ModifyitemCatViewController()
        let specVC = ModifyItemSpecViewController()
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
                goNextStepView.animateOnlyNextStep = false
                goNextStepView.nextStepButtonTitle = "下一步"
            case 2:
                goNextStepView.animateOnlyNextStep = false
                goNextStepView.nextStepButtonTitle = "确定修改"
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
    }
}

extension ItemModifyViewController {
    func setupUI() {
        navigationItem.title = "修改商品货号"
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
    
    func cancelAtion() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func commitAction() {
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
            if msg?.isEmpty == true {
                 _ = self.navigationController?.popViewController(animated: true)
            } else {
                if let msg = msg {
                    Utility.showAlert(self, message: msg)
                }
            }
            
        }
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

extension ItemModifyViewController: GoNextOrPreviousStep {
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
