//
//  BaseViewController.swift
//  FPTrade
//
//  Created by Koh Ryu on 29/9/15.
//  Copyright © 2015年 Windward. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    lazy var bBtn: UIButton = {
        let btn = UIButton(backgroundImage: "CommonBlueBg")
        btn.addTarget(self, action: #selector(self.bottomButtonAction), for: .touchUpInside)
        btn.setTitle("确定", for: UIControlState())
        return btn
    }()
    
    lazy var backCover: UIView = {
        let backCover = UIView()
        backCover.backgroundColor = UIColor.clear
        backCover.isUserInteractionEnabled = true
        backCover.frame = CGRect(x: 35, y: 0, width: 100, height: 44)
        return backCover
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBarItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func bottomButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}

class BaseTableViewController: UITableViewController {
    lazy var bBtn: UIButton = {
        let btn = UIButton(backgroundImage: "CommonBlueBg")
        btn.addTarget(self, action: #selector(self.bottomButtonAction), for: .touchUpInside)
        btn.setTitle("确定", for: UIControlState())
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBarItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarItem
        
        let coverView = UIView()
        coverView.backgroundColor = UIColor.clear
        coverView.frame = CGRect(x: 35, y: 0, width: 100, height: 44)
        self.navigationController?.navigationBar.addSubview(coverView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func bottomButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}
