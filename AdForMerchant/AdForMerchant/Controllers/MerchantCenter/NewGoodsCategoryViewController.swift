//
//  NewGoodsCategoryViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/3.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let rightTxtFieldCellID = "RightTxtFieldTableViewCell"

class NewGoodsCategoryViewController: BaseViewController {
    fileprivate var cate: StoreCateSaveParameter = StoreCateSaveParameter()
    fileprivate lazy var tableView: ItemTableView = {
        let tab = ItemTableView()
        tab.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        tab.backgroundColor = UIColor.colorWithHex("f7f7f7")
        tab.dataSource = self
        tab.delegate = self
        tab.register(UINib(nibName: "RightTxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: rightTxtFieldCellID)
        return tab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func bottomButtonAction() {
        commitAction()
    }
}

extension NewGoodsCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
             guard let cell = tableView.cellForRow(at: indexPath) as? RightTxtFieldTableViewCell else { return  }
           let destVC = GoodsCateViewController()
            let animator = TransitionAnimator()
            let x: CGFloat = 0
            let height: CGFloat = 132
            guard let barHeight = navigationController?.navigationBar.height else {return}
            let y = barHeight + UIApplication.shared.statusBarFrame.height + view.frame.height - height
            let width = view.frame.width
            animator.presentFrame = CGRect(x: x, y: y, width: width, height: height)
            destVC.transitioningDelegate = animator
            destVC.modalPresentationStyle = .custom
            present(destVC, animated: true, completion: nil)
            destVC.finishCallBack = {[unowned self] cate in
                self.cate.type = cate.type
                cell.rightTxtField.text = cate.categoryName
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension NewGoodsCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: rightTxtFieldCellID, for: indexPath) as? RightTxtFieldTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.accessoryType = .disclosureIndicator
            cell.leftTxtLabel.text = "商品类型"
            cell.rightTxtField.placeholder = "请选择商品类型"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        case 1:
            cell.accessoryType = .none
            cell.leftTxtLabel.text = "店铺分类标题"
            cell.rightTxtField.placeholder = "请输入店铺分类标题"
            cell.rightTxtField.isUserInteractionEnabled = true
            cell.maxCharacterCount = 20
            cell.endEditingBlock = { [unowned self] textfield in
                self.cate.categoryName = textfield.text ?? ""
            }
        default:
            break
        }
        return cell
    }
}

extension NewGoodsCategoryViewController {
    fileprivate  func setupUI() {
        bBtn.setTitle("保存", for: .normal)
        navigationItem.title = "新增店铺分类"
        view.addSubview(tableView)
        view.addSubview(bBtn)
        bBtn.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-44)
        }
    }
    
    fileprivate  func showSheet(_ finshCallBack: @escaping (_ cate: StoreCateSaveParameter) -> Void) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let normalGoods = UIAlertAction(title: "普通商品分类", style: .default) { (_) in
            let cate = StoreCateSaveParameter()
            cate.categoryName = "普通商品"
            cate.type = .normal
            finshCallBack(cate)
        }
        let serviceGoods = UIAlertAction(title: "生活服务商品分类", style: .default) {(_) in
            let cate = StoreCateSaveParameter()
            cate.categoryName = "生活服务商品"
            cate.type = .service
            finshCallBack(cate)
        }
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        sheet.addAction(normalGoods)
        sheet.addAction(serviceGoods)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }
    
  @objc  fileprivate  func commitAction() {
    if cate.type == nil {
        Utility.showAlert(self, message: "请选择商品类型")
        return
    }
    
    if cate.categoryName.isEmpty {
        Utility.showAlert(self, message: "请输入十个字以内的店铺分类名称")
        return
    }
    let param = cate.toJSON()
    let aesKey = AFMRequest.randomStringWithLength16()
    let aesIV = AFMRequest.randomStringWithLength16()
    RequestManager.request(AFMRequest.storeSaveCat(param, aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV), completionHandler: { (_, _, _, _, msg) in
        if msg == "" {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            if let msg = msg {
                Utility.showAlert(self, message: msg)
            }
        }
    })
 }
}
