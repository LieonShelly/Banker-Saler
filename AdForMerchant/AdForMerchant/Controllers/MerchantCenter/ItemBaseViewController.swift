//
//  ItemBaseViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class ItemBaseViewController: UIViewController {
    var addItemHomeViewController: AddItemViewController {
         guard let vc = self.parent as? AddItemViewController else { return AddItemViewController()}
        return vc
    }
    var modifyItemHomeViewController: ItemModifyViewController {
        guard let vc = self.parent as? ItemModifyViewController else { return ItemModifyViewController()}
        return vc
    }
    
    var item: Goods = Goods()
    var cellID: String {
        return "cellID"
    }
    
    lazy var tableView: ItemTableView = { [unowned self] in
        let tableView = ItemTableView()
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.colorWithHex("f7f7f7")
        return tableView
        }()
    
    var models: [AnyObject]? {
        return [AnyObject]()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(view.snp.size)
        }
    }
    
}

extension ItemBaseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        guard let models = models else {return UITableViewCell()}
        if indexPath.row == models.count - 1 {
            cell.clipsToBounds = true
        }
        return cell
    }
}

class ItemTableView: UITableView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard  let view = super.hitTest(point, with: event) else {
            return nil
        }
        if !view.isKind(of: UITextField.self) {
            self.endEditing(true)
            return self
        } else {
            return view
        }
    }
}
