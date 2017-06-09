//
//  ItemDetailTableView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/25.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let itemDetailCellID = "itemDetailCell"
class ItemDetailTableView: BaseTableView {
    var items: [ProductModel]? {
        didSet {
            reloadData()
        }
    }
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        cellID = itemDetailCellID
        nibName = "ItemDetailTableViewCell"
        rowHeight = 115
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ItemDetailTableView {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: itemDetailCellID, for: indexPath)  as? ItemDetailTableViewCell else { return UITableViewCell() }
        cell.model = items?[indexPath.row]
        return cell
    }
}
