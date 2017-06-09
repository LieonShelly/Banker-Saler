//
//  StatusDetailViewController.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/21.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class StatusDetailViewController: BaseViewController {
    var param: StatusDetailParameter?
    fileprivate var statusDetail: StatusDetail?
    fileprivate lazy var statusView: StatusView = {
        let view = StatusView.detailView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
}

extension StatusDetailViewController {
    fileprivate  func setupUI() {
        view.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    fileprivate  func loadData() {
        guard let param = param else { return  }
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        Utility.showMBProgressHUDWithTxt()
        RequestManager.request(AFMRequest.exception(param.toJSON(), aesKey, aesIV), aesKeyAndIv: (key: aesKey, iv: aesIV)) { (_, _, json, error, msg) in
            Utility.hideMBProgressHUD()
            if let result = json as? [String: Any] {
                self.statusDetail = Mapper<StatusDetail>().map(JSON: result)
                if let status = self.statusDetail {
                    self.statusView.congfig(status: status)
                }
            } else {
                Utility.showAlert(self, message: msg ?? "")
            }
        }
    }
}
