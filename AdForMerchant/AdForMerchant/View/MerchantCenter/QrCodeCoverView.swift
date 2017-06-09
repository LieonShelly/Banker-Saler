//
//  QrCodeCoverView.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/19.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
typealias QrBlockClose = () -> Void
class QrCodeCoverView: UIView {

    @IBOutlet weak var codeImageView: UIImageView!
    var closeBlock: QrBlockClose?
 
    @IBAction func closeQrCoverViewHandle(_ sender: AnyObject) {
        self.dissmiss()
    }
    
    func createQrCode(_ code: String) {

        if let data = Data(base64Encoded: code, options: .ignoreUnknownCharacters) {
            codeImageView.image = UIImage(data: data)
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dissmiss()
    }
    
    func dissmiss() {
        removeFromSuperview()
        closeBlock?()
    }

}
