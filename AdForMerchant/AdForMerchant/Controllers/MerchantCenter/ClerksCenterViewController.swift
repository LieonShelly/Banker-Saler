//
//  ClerksCenterViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/23.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class ClerksCenterViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var staffId = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        iconImageView.layer.cornerRadius = 30
        iconImageView.layer.borderWidth = 2
        iconImageView.layer.borderColor = UIColor.white.cgColor
        iconImageView.layer.masksToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutHandle(_ sender: AnyObject) {
        Utility.showConfirmAlert(self, message: "是否确认退出登录？", confirmCompletion: {
            self.signOut()
        })
    }
    func signOut() {
        UserManager.sharedInstance.signedIn = false
        UserManager.sharedInstance.userInfo = nil
        kApp.needLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Utility.hideMBProgressHUD()
        navigationController?.navigationBar.isHidden = true
        let statusView = UIView()
        statusView.backgroundColor = UIColor.colorWithHex("#0B86EE")
        statusView.frame = CGRect(x: 0, y: -20, width: screenWidth, height: 20)
        view.addSubview(statusView)
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = false
        setBackBarButton()
    }
}

extension ClerksCenterViewController {
    
    func showQRScanPage() {
        guard let modalViewController = AOLinkedStoryboardSegue.sceneNamed("ScanQR@Main") as? QRViewController else {return}
        modalViewController.transitioningDelegate = modalViewController
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(modalViewController, animated: true, completion: { () -> Void in
            
        })
    }
    
    func setBackBarButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
    }
    
    func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func requestData() {
        Utility.showMBProgressHUDWithTxt()
        let params: [String: Any] = ["staff_id": UserManager.sharedInstance.staffId]

        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.detailsStaff(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            
            if let result = object as? [String: Any] {
                guard let info = Mapper<Staff>().map(JSON: result) else {return}
                guard let avatar = info.avatar else {return}
                self.nameLabel.text = info.name
                self.iconImageView.sd_setImage(with: URL(string: avatar))
                Utility.hideMBProgressHUD()
            } else {
                Utility.hideMBProgressHUD()

            }
        }
    }
}
extension ClerksCenterViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        tableView.deselectRow(at: indexPath, animated: false)
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            showQRScanPage()
            break
        case (0, 2):

            guard let vc = AOLinkedStoryboardSegue.sceneNamed("SaleCoupon@MerchantCenter") as? SaleCouponViewController else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case (1, 0):

            guard let vc = AOLinkedStoryboardSegue.sceneNamed("WantCollect@MerchantCenter") as? WantCollectViewController else {return}
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case (1, 1):

            guard let vc = AOLinkedStoryboardSegue.sceneNamed("MyCollect@MerchantCenter") as? MyCollectViewController else {return}
            vc.isEdge = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case (2, 0):
            guard let vc = AOLinkedStoryboardSegue.sceneNamed("ResetPassword@CenterSettings") as? MerchantCenterResetPasswordViewController else {return}
              self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
}
