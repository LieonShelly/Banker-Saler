//
//  QRViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/26/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate var session: AVCaptureSession?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var tipTitleConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var qrViewConstraintTop: NSLayoutConstraint!
    @IBOutlet weak fileprivate var inputButton: UIButton!
    
    fileprivate var canScan: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        initialSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if iphone5 {
            qrViewConstraintTop.constant = 155
            tipTitleConstraintTop.constant = 86
        }
    }
    
    func initialSession() {
        
        // Create a new AVCaptureSession
        session = AVCaptureSession()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
//        let error: NSError?
        
        // Want the normal device
        let input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }
        
        session?.addInput(input)
        
        canScan = true
        
        let output = AVCaptureMetadataOutput()
        // Have to add the output before setting metadata types
        
        session?.addOutput(output)
        // What different things can we register to recognise?
        //        NSLog(@"%@", [output availableMetadataObjectTypes]);
        // We're only interested in QR Codes
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        // This VC is the delegate. Please call us on the main queue
        //        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Display on screen
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.bounds = self.view.bounds
        previewLayer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        view.layer.addSublayer(previewLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == .denied || status == .restricted {
            Utility.showAlert(self, message: "请在iPhone的“设置－隐私－相机”选项中，允许本应用访问你的相机")
        }
        view.backgroundColor = UIColor.clear
        startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func manuallyInputAction(_ btn: UIButton) {
        guard  let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ManuallyInputQR@Main") as? ManuallyInputQRViewController else {  return }
        modalViewController.transitioningDelegate = self
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: nil)
        
    }
    
}

extension QRViewController {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if !metadataObjects.isEmpty {
            guard let obj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
                return
            }
            if obj.type == AVMetadataObjectTypeQRCode {
                guard  let result = obj.stringValue else { return }
                
                if canScan {
                    canScan = false
                    requestQRCodeConfirm(result)
                }
            }
        }
    }
    
    func startRunning() {
        if session == nil {
            initialSession()
        }
        
        self.canScan = true
        session?.startRunning()
    }
    
    func stopRunning() {
        self.canScan = false
        session?.stopRunning()
    }
    
    func requestQRCodeConfirm(_ qrCode: String) {
        let parameters: [String: Any] = [
            "code": qrCode,
            "scan_type": QRCodeType.scan.rawValue
        ]
        session?.stopRunning()
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.qrCodeConfirm(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                guard let result = object as? [String: Any] else {   return   }
                guard let tips = result["tip"] as? String else {   return   }
                Utility.hideMBProgressHUD()
                
                Utility.showConfirmAlert(self, title: "提示", cancelButtonTitle: "取消", confirmButtonTitle: "确认", message: tips, cancelCompletion: { () in
                    self.canScan = true
                    self.session?.startRunning()
                    
                }, confirmCompletion: { () in
                    self.requestUseQRCode(qrCode)
                })
            } else {
                if let msg = message {
                    Utility.showAlert(self, message: msg, dismissCompletion: { () in
                        self.canScan = true
                        self.session?.startRunning()
                    })
                    Utility.hideMBProgressHUD()
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
    
    func requestUseQRCode(_ qrCode: String) {
        let parameters: [String: Any] = [
            "code": qrCode,
            "scan_type": QRCodeType.scan.rawValue
        ]
        
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.qrCodeScan(parameters, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, _, message) -> Void in
            if (object) != nil {
                Utility.hideMBProgressHUD()
                guard let msg = message else {  return  }
                Utility.showAlert(self, message: msg.isEmpty ? "使用二维码成功": msg, dismissCompletion: { () in
                    self.canScan = true
                    self.session?.startRunning()
                })
            } else {
                
                if let msg = message {
                    Utility.showAlert(self, message: msg, dismissCompletion: { () in
                        self.canScan = true
                    })
                    Utility.hideMBProgressHUD()
                } else {
                    Utility.hideMBProgressHUD()
                }
            }
        }
    }
}

extension QRViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //        return AlertPresentingAnimator()
        if presented.isKind(of: ManuallyInputQRViewController.self) {
            return MoveFromRightPresentingAnimator(block: {
                self.canScan = false
                self.session?.stopRunning()
            })
        }
        return MoveFromRightPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed.isKind(of: ManuallyInputQRViewController.self) {
            return MoveFromRightDismissingAnimator(block: {
                self.canScan = true
                self.session?.startRunning()
            })
        }
        return MoveFromRightDismissingAnimator()
    }
    
}
