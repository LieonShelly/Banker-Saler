//
//  ProductAddedResultViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/29/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class ObjectReleaseSucceedViewController: BaseViewController {
    @IBOutlet fileprivate weak var resultLabel: UILabel!
    @IBOutlet fileprivate weak var continueButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var navTitle: String = ""
    var desc: String = ""
    var productType = ""
    var completionBlock: ((Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle
        navigationItem.hidesBackButton = true
        
        resultLabel.text = desc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if navTitle == "编辑活动" || navTitle == "发布广告" || navTitle == "发布活动" || navTitle == "编辑商品" || navTitle == "编辑广告" || productType == "发布服务商品"{
            continueButton.isHidden = true
            confirmButton.setBackgroundImage(UIImage(named: "CommonBlueBg"), for: UIControlState())
            confirmButton.backgroundColor = UIColor.clear
        } else {
            continueButton.isHidden = false
        }
    }
    
    @IBAction func completeAction() {
        completionBlock?()
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func continueAction(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
}
