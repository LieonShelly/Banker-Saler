//
//  ModifyItemSpecViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/28.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let cellID = "ModifyItemSpecTableViewCell"
class ModifyItemSpecViewController: UIViewController {

    var modifyItemHomeViewController: ItemModifyViewController {
        guard let vc = self.parent as? ItemModifyViewController else { return ItemModifyViewController()}
        return vc
    }
    var propList: [GoodsProperty]?
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: "ModifyItemSpecTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.isEditing = true
          tableView.backgroundColor = UIColor.colorWithHex("f7f7f7")
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
       view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
        propList = modifyItemHomeViewController.newItem.propList
    }
    
}

extension ModifyItemSpecViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ModifyItemSpecTableViewCell, let properlist = propList else { return UITableViewCell() }
        cell.titleLabel.text = "规格\(indexPath.row + 1)"
        cell.model = properlist[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       print(".......")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let models = modifyItemHomeViewController.newItem.propList else {
                return
            }
            let model = models[indexPath.row]
            model.isDeleted = true
            
            propList?.remove(at: indexPath.row)
            modifyItemHomeViewController.newItem.propList?.remove(at: indexPath.row)
            modifyItemHomeViewController.newItem.propList?.insert(model, at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
