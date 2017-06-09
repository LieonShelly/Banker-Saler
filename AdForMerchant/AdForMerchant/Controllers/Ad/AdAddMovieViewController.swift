//
//  AdAddMovieViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class AdAddMovieViewController: BaseViewController {
    @IBOutlet fileprivate weak var placeholderTv: UITextView!
    @IBOutlet fileprivate weak var videoAddrTv: UITextView!
    
    @IBOutlet fileprivate weak var seePreviewButton: UIButton!
    
    var adType: AdType = .picture
    var resoure: String = ""
    var completionBlock: ((String) -> Void)?
    var videoStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.seePreviewButton.adjustsImageWhenHighlighted = false
        
//        let leftBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backAction))
//        navigationItem.leftBarButtonItem = leftBarItem
        let rightBarItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.confirmAction))
        navigationItem.rightBarButtonItem = rightBarItem
        
        seePreviewButton.addTarget(self, action: #selector(self.seePreviewAction), for: .touchUpInside)
        
        videoAddrTv.keyboardType = .URL
        videoAddrTv.delegate = self
        videoAddrTv.text = resoure
        if !videoStr.isEmpty {
            self.videoAddrTv.text = videoStr
        }
        baseSetting()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewResignFirstResponder)))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            destVC.requestURL = Utility.getTextByTrim(videoAddrTv.text)
            destVC.naviTitle = "生成预览"
        }
    }
}

extension AdAddMovieViewController {
    func baseSetting() {
        
        switch adType {
        case .movie:
            navigationItem.title = "添加视频"
            if videoAddrTv.text.isEmpty {
                placeholderTv.text = "请输入有效视频地址"
            } else {
                placeholderTv.text = ""
            }
        case .webpage:
            
            navigationItem.title = "添加网页地址"
            if videoAddrTv.text.isEmpty {
                placeholderTv.text = "请输入有效网页地址"
            } else {
                placeholderTv.text = ""
            }
            
        default:
            break
        }
    }
    
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func viewResignFirstResponder() {
        view.endEditing(true)
    }
    
    func confirmAction() {
        //TODO: - 检测前后空格
        let requestUrl = Utility.getTextByTrim(videoAddrTv.text)
        
        if !requestUrl.isEmpty {
            var msg = ""
            switch adType {
            case .movie:
                msg = "请输入有效视频地址"
            case .webpage:
                msg = "请输入有效网页地址"
            default:
                break
            }
            if requestUrl.characters.count > 512 {                
                Utility.showAlert(self, message: "链接地址过长，请重新输入")
                return
            }
            guard Utility.isValidURL(requestUrl) else {
                Utility.showAlert(self, message: msg)
                return
            }
            
            if let block = completionBlock {
                block(videoAddrTv.text)
            }
            _ = navigationController?.popViewController(animated: true)
        } else {
            Utility.showAlert(self, message: "URL地址不能为空")
        }
    }
    
    func seePreviewAction() {
        //TODO: - 检测前后空格
        let requestUrl = Utility.getTextByTrim(videoAddrTv.text)
        
        var msg = ""
        switch adType {
        case .movie:
            msg = "请输入有效视频地址"
        case .webpage:
            msg = "请输入有效网页地址"
        default:
            break
        }
        guard Utility.isValidURL(requestUrl) else {
            Utility.showAlert(self, message: msg)
            return
        }
        
        AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: nil)
    }
}

extension AdAddMovieViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

        if textView.text.isEmpty {
            
            switch adType {
            case .movie:
                placeholderTv.text = "输入视频地址"
            case .webpage:
                placeholderTv.text = "输入网页地址"
            default:
                break
            }
        } else {
            placeholderTv.text = ""
        }
    }
}
