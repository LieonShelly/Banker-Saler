//
//  MyCollectViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/13.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class MyCollectViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var datePickerView = ShowDatePickerView()
    fileprivate var checked = true
    fileprivate var date: Date? = Date()
    fileprivate var dataArray = [PrivilegeInfo]()
    var isEdge = false
    
    fileprivate lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.frame = UIScreen.main.bounds
        coverView.backgroundColor = UIColor.black
        coverView.alpha = 0.6
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dissDatePickerView))
        coverView.addGestureRecognizer(tap)
        return coverView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDate(_:)), name: Notification.Name(rawValue: "notifacationDate"), object: nil)
        setupUI()
        tableView.addTableViewRefreshHeader(self, refreshingAction: "requestListWithReload")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isEdge == true {
            tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        }
        tableView.mj_header.beginRefreshing()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dissDatePickerView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension MyCollectViewController {
    func setupUI() {
        title = "扫码支付列表"
        tableView.dataSource = self
        tableView.delegate = self
        if UserManager.sharedInstance.loginType == .clerk {
            tableView.rowHeight = iphone5 ? 150 : 160
        } else {
            tableView.rowHeight = iphone5 ? 190 : 200
        }
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "MyCollectTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCollectTableViewCell")
        setBarButtonTitle()
    }
    func setBarButtonTitle() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "查询", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.checkHandle))
    }
    func checkHandle() {
        if checked == true {
            guard let datePickerView = Bundle.main.loadNibNamed("ShowDatePickerView", owner: nil, options: nil)?.first as? ShowDatePickerView else {return}
            datePickerView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 215)
            UIView.animate(withDuration: 0.25, animations: {
                datePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-215, width: screenWidth, height: 215)
                datePickerView.confirmBlock = {
                    if let date = self.date {
                        var starTime = "\(date)"
                        var endTime = ""
                        let range = NSRange(location: 8, length: 2)
                        let day = (starTime as NSString).substring(with: range)
                        if  day == "01" {
                            endTime = (starTime as NSString).replacingCharacters(in: NSRange(location: 8, length: 2), with: "30")
                        } else {
                            starTime = (starTime as NSString).replacingCharacters(in: NSRange(location: 8, length: 2), with: "01")
                            endTime = (starTime as NSString).replacingCharacters(in: NSRange(location: 8, length: 2), with: "30")
                        }
                        print("\(starTime)"+"\(endTime)")
                      self.requestMonthData(1, starDate: starTime, endDate: endTime)
                      self.dissDatePickerView()
                    }
                    
                }
                datePickerView.cancelBlock = {
                   self.dissDatePickerView()
                }
            })
            self.navigationController?.view.addSubview(coverView)
            self.navigationController?.view.addSubview(datePickerView)
            self.datePickerView = datePickerView
            checked = false
        }

    }
    
    func getDate(_ notification: Notification) {
        guard let date = notification.userInfo?["date"] else {return}
        self.date = date as? Date
    }
    
    func dissDatePickerView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.datePickerView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 215)
            }, completion: { (true) in
                self.coverView.removeFromSuperview()
                self.datePickerView.removeFromSuperview()
        })
        checked = true
    }
    
    func nodataBgView() -> UIView {
        let bgView = UIView(frame: tableView.bounds)
        let descLbl = UILabel(frame: CGRect(x: 0, y: 100, width: bgView.frame.width, height: 60))
        descLbl.center = CGPoint(x: bgView.center.x, y: descLbl.center.y)
        descLbl.textAlignment = NSTextAlignment.center
        descLbl.numberOfLines = 2
        descLbl.text = "当前没有收单"
        descLbl.textColor = UIColor.lightGray
        bgView.addSubview(descLbl)
        return bgView
    }
}

extension MyCollectViewController {

    func requestListWithReload() {
        requestData(1)
    }
    func requestData(_ page: Int) {
        let params: [String: AnyObject] = ["page": page as AnyObject]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.privilegeList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else {return}
                  self.dataArray = tempArray.flatMap({PrivilegeInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                if self.dataArray.isEmpty {
                    self.tableView.backgroundView = self.nodataBgView()
                } else {
                    self.tableView.tableFooterView = UIView()
                }
                
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
//                self.tableView.mj_footer.endRefreshing()
            } else {
                self.tableView.mj_header.endRefreshing()
//                self.tableView.mj_footer.endRefreshing()
            }
        }
    }
    func requestMonthData(_ page: Int, starDate: String, endDate: String) {
        let startTime = ("\(starDate)" as NSString).substring(to: 10)
        let endTime = ("\(endDate)" as NSString).substring(to: 10)
        let params: [String: AnyObject] = [
            "page": page as AnyObject,
            "start_time": "\(startTime)" as AnyObject,
            "end_time": "\(endTime)" as AnyObject
        ]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.privilegeList(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: AnyObject] {
                guard let tempArray = result["items"] as? [AnyObject] else {return}
                let dataArray = tempArray.flatMap({PrivilegeInfo(JSON: ($0 as? [String: AnyObject]) ?? [String: AnyObject]() )})
                    let vc = QueryResultsViewController()
                    vc.dataArray = dataArray
                    let monthString = ("\(starDate)" as NSString).substring(with: NSRange(location: 5, length: 2))
                    guard let month = Int(monthString) else {return}
                    vc.monthIndex = month
                    self.navigationController?.pushViewController(vc, animated: true)
            } else {

            }
        }
    }
}

extension MyCollectViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCollectTableViewCell", for: indexPath) as? MyCollectTableViewCell else {
            return UITableViewCell() }
        cell.config(dataArray[indexPath.section])
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
