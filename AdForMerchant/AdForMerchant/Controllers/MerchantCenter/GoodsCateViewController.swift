//
//  GoodsCateViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/7.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let cellID = "cellID"
class GoodsCateViewController: UIViewController {
    var finishCallBack: ((_ cate: StoreCateSaveParameter) -> Void)?

    fileprivate lazy var tableView: UITableView = {[unowned self] in
        let tab = UITableView()
        tab.dataSource = self
        tab.delegate = self
        tab.isScrollEnabled = false
        tab.register(UINib(nibName: "NormalDescTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
    }
}

extension GoodsCateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? NormalDescTableViewCell else {
            return UITableViewCell()
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.txtLabel.textAlignment = .center
        cell.txtLabel.textColor = UIColor.colorWithHex("141414")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        switch indexPath.row {
        case 0:
            cell.txtLabel.text = "普通商品分类"
        case 1:
            cell.txtLabel.text = "生活服务商品分类"
        case 2:
            cell.txtLabel.textColor = UIColor.commonBlueColor()
            cell.txtLabel.text = "取消"
        default:
            break
        }
        return cell
    }
}

extension GoodsCateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cate = StoreCateSaveParameter()
        switch indexPath.row {
        case 0:
            cate.categoryName = "普通商品分类"
            cate.type = .normal
        case 1:
            cate.categoryName = "生活服务商品分类"
            cate.type = .service
        default:
            break
        }
        if let block = finishCallBack {
            block(cate)
        }
        dismiss(animated: true, completion: nil)
    }
}
