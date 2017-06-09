//
//  PaySuccessViewController.swift
//  AdForMerchant
//
//  Created by 糖otk on 2017/2/28.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit

class PaySuccessViewController: BaseViewController {

    @IBOutlet fileprivate weak var autoBackLabel: UILabel!
    fileprivate var timer: Timer?
    fileprivate var time: Int = 3
    var dismissHandleBlock: (() -> Void)?
    var timeEndBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        timerStart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerStart() {
        autoBackLabel.text = "\(time)秒后自动返回..."
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    func timerAction() {
        time -= 1
        if time == -1 {
            timerEnd()
            return
        }
        autoBackLabel.text = "\(time)秒后自动返回..."
    }
    
    func timerEnd() {
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true, completion: nil)
        if let block = timeEndBlock {
            block()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismissHandle()
    }
    
    fileprivate func dismissHandle() {
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true, completion: nil)
        if let block = dismissHandleBlock {
            block()
        }
    }
}
