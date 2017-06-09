//
//  ProductSetSpecFooterView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/11/1.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

private let cellID = "SetSpecFooterViewCell"
class ProductSetSpecFooterView: UIView {
    fileprivate lazy var tableView: ItemTableView = { [unowned self] in
        let tab = ItemTableView()
        tab.separatorStyle = .none
        tab.backgroundColor = UIColor.colorWithHex("f5f5f5")
        tab.dataSource = self
        tab.allowsSelection = false
        tab.register(SetSpecFooterViewCell.self, forCellReuseIdentifier: cellID)
        tab.rowHeight = UITableViewAutomaticDimension
        tab.estimatedRowHeight = 20
        tab.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        return tab
        }()
    fileprivate var strings: [String] = [String]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.colorWithHex("f5f5f5")
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.size.equalTo(self.snp.size)
            make.center.equalTo(self.snp.center)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProductSetSpecFooterView {
    func configSpec(_ goodsLlist: [GoodsModel]?) {
        if let list = goodsLlist {
            
            for goods in list {
                var temp = " "
                 guard let properlist = goods.propList else { continue  }
                for proper in properlist {
                    guard let value = proper.value else { continue }
                    temp += value + "+"
                }
                strings.append(temp.deleteLastCharacter())
//                print( temp)
            }
            tableView.reloadData()
        } else {
           return
        }
    }
}

extension ProductSetSpecFooterView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SetSpecFooterViewCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.label.attributedText = NSMutableAttributedString(leftString: "ⓘ ", rightString: " 已有规格", leftColor: UIColor.commonBlueColor(), rightColor: UIColor.lightGray, leftFontSize: 15, rightFoneSize: 15)
        } else {
            cell.label.text = strings[indexPath.row - 1]
        }
        
        return cell
    }
}

class SetSpecFooterViewCell: UITableViewCell {
    lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.colorWithHex("f5f5f5")
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.colorWithHex("f5f5f5")
        label.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(5)
            make.right.equalTo(-20)
            make.bottom.equalTo(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
