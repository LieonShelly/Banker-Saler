//
//  BaseTableView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/25.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {
    var models: [AnyObject]?
    var selectRowAction: ((_ model: AnyObject) -> Void)?
    var cellID: String?
    var nibName: String? {
        didSet {
            if let nib = self.nibName, let id = cellID {
                register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: id )
            }
        }
    }
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        separatorStyle = .none
        backgroundColor = UIColor.colorWithHex("f7f7f7")
        contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let id = cellID else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        return cell
    }
}

extension BaseTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let modelArray = models else { return  }
        let model = modelArray[indexPath.row]
        if let block = selectRowAction {
            block(model)
        }
    }
}
