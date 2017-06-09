//
//  PreferentialPaySettingViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/13.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class PreferentialPaySettingViewController: BaseViewController {

    fileprivate lazy var titleView: UIView = {
       let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 46)
        titleView.backgroundColor = UIColor.white
        return titleView
    }()
    fileprivate lazy var discountButton: UIButton = {
       let discountButton = UIButton()
        discountButton.tag = 0
        discountButton.frame = CGRect(x: 0, y: 0, width: screenWidth*0.5, height: 45)
        discountButton.setTitle("折扣", for: UIControlState())
        discountButton.setTitleColor(UIColor.colorWithHex("#0B86EE"), for: .selected)
        discountButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        discountButton.setTitleColor(UIColor.black, for: UIControlState())
        discountButton.addTarget(self, action: #selector(self.clickTitleButton(_ :)), for: .touchUpInside)
        return discountButton
    }()
    fileprivate lazy var reduceButton: UIButton = {
        let reduceButton = UIButton()
        reduceButton.tag = 1
        reduceButton.frame = CGRect(x: screenWidth*0.5, y: 0, width: screenWidth*0.5, height: 45)
        reduceButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        reduceButton.setTitle("满减", for: UIControlState())
        reduceButton.setTitleColor(UIColor.black, for: UIControlState())
        reduceButton.setTitleColor(UIColor.colorWithHex("#0B86EE"), for: .selected)
        reduceButton.addTarget(self, action: #selector(self.clickTitleButton(_ :)), for: .touchUpInside)
        return reduceButton
    }()
    fileprivate lazy var indexView: UIView = {
       let indexView = UIView()
        indexView.frame = CGRect(x: 0, y: 44, width: 60, height: 2)
        indexView.center = CGPoint(x: self.discountButton.frame.size.width*0.5, y: 45)
        indexView.backgroundColor = UIColor.colorWithHex("#0B86EE")
        return indexView
    }()
    fileprivate lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
//        scrollView.backgroundColor = UIColor.redColor()
        scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        scrollView.contentSize = CGSize(width: screenWidth*2, height: 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    var lastButton = UIButton()
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        addChirldControler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.index = UserDefaults.standard.integer(forKey: "index")
        clickTitleButton(self.index == 0 ? discountButton : reduceButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PreferentialPaySettingViewController {
    func setupUI() {
        title = "扫码支付设置"
        view.addSubview(titleView)
        titleView.addSubview(discountButton)
        titleView.addSubview(reduceButton)
        titleView.addSubview(indexView)
        view.insertSubview(scrollView, at: 0)
    }

    func addChirldControler() {
        let discountVC = DiscountViewController()
        let reduceVC = ReduceViewController()
        addChildViewController(discountVC)
        addChildViewController(reduceVC)
    }
    
}

extension PreferentialPaySettingViewController {
    
    // 新增
    @IBAction func addNew(_ sender: AnyObject) {
        self.index = UserDefaults.standard.integer(forKey: "index")
        NotificationCenter.default.post(name: Notification.Name(rawValue: dataSourceWhenRuleInfoFullThreeNotification), object: self, userInfo: nil)
        if self.index == 1 {
            pushController("AddReduce@MerchantCenter", title: "满减新增")
        } else {
            pushController("AddDiscount@MerchantCenter", title: "折扣新增")
        }
    }
    
    func pushController(_ name: String, title: String) {
        if name == "AddReduce@MerchantCenter" {
            guard let VC = AOLinkedStoryboardSegue.sceneNamed(name) as? AddReduceViewController else {return}
            VC.title = title
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            
            guard let VC = AOLinkedStoryboardSegue.sceneNamed(name) as? AddDiscountViewController else {return}
            VC.title = title
            self.navigationController?.pushViewController(VC, animated: true)
        }
        
    }
//    func pushAddDiscountController() {
//        let editDiscountVC = AOLinkedStoryboardSegue.sceneNamed("AddDiscount@MerchantCenter") as! AddDiscountViewController
//        editDiscountVC.title = "折扣新增"
//        self.navigationController?.pushViewController(editDiscountVC, animated: true)
//    }
    
    // 点击折扣或者满减
    func clickTitleButton(_ btn: UIButton) {
        UserDefaults.standard.set(btn.tag, forKey: "index")
        btn.isSelected = true
        lastButton.isSelected = false
        lastButton = btn
        UIView.animate(withDuration: 0.25, animations: {
           self.indexView.centerX = btn.centerX
            var offset: CGPoint = self.scrollView.contentOffset
            offset.x = CGFloat(btn.tag) * self.scrollView.width
            self.scrollView.contentOffset = offset
        }, completion: { (true) in
            self.addChildViewIndex(btn.tag)
        }) 
    }

    func addChildViewIndex(_ index: Int) {
        let vc = self.childViewControllers[index]
        vc.view.frame = self.scrollView.bounds
        self.scrollView.addSubview(vc.view)
    }
}
