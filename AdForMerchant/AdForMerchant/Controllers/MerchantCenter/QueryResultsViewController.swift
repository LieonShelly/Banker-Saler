//
//  QueryResultsViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/23.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class QueryResultsViewController: UITableViewController {
    
    var dataArray: [PrivilegeInfo] = [] {
        didSet {
            if self.dataArray.isEmpty {
                self.tableView.backgroundView = self.nodataBgView()
            } else {
                tableView.reloadData()
                self.tableView.tableFooterView = UIView()
            }
        }
    }
    var monthIndex = 0
    var monthArray = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"]
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "扫码支付查询"
        tableView.rowHeight = 200
        tableView.separatorColor = UIColor.clear
        tableView.register(UINib(nibName: "MyCollectTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCollectTableViewCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nodataBgView() -> UIView {
        let bgView = UIView(frame: tableView.bounds)
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        descLbl.text = "未查询到优惠买单"
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        return bgView
    }
}

extension QueryResultsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCollectTableViewCell", for: indexPath) as? MyCollectTableViewCell else {
            return UITableViewCell() }
        cell.config(dataArray[indexPath.section])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 28
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 28)
            view.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.frame = CGRect(x: 20, y: 0, width: 130, height: 28)
            label.text = monthArray[monthIndex-1]+"月明细查询"
            label.textColor = UIColor.gray
            label.font = UIFont.systemFont(ofSize: 16)
            view.addSubview(label)
            return view
        } else {
            return nil
        }
    }
}
