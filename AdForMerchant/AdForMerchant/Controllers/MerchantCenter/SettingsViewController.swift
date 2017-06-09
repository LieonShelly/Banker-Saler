//
//  SettingsViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/22/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "设置"
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            label.text = "Build " + text
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommonWebViewScene@AccountSession" {
            guard let destVC = segue.destination as? CommonWebViewController else {return}
            if let indexPath = sender as? IndexPath {
                switch (indexPath.section, indexPath.row) {
                case (1, 0)://帮助
                    destVC.requestURL = "https://content." + domainURL + "/help/index?platform=2"
                    destVC.title = "帮助"
                case (2, 0)://about us
                    let url = "https://content." + domainURL + "/webview/about_us/merchant.html"
                    destVC.requestURL = url
                    destVC.title = "关于我们"
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Button Action
    
    @IBAction func modifyMerchantInfoAction(_ btn: UIButton) {
        AOLinkedStoryboardSegue.performWithIdentifier("MerchantCenterInfo@MerchantCenter", source: self, sender: nil)
        
    }
    
    // MARK: - Methods
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellId") else {
                return UITableViewCell(style: .default, reuseIdentifier: "DefaultCellId")
            }
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.textLabel?.textColor = UIColor.colorWithHex("#393939")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.imageView?.image = UIImage(named: "SettingsIconSecurity")
            cell.textLabel?.text = "安全中心"
        case (1, 0):
            cell.imageView?.image = UIImage(named: "SettingsIconHelp")
            cell.textLabel?.text = "帮助"
        case (1, 1):
            cell.imageView?.image = UIImage(named: "SettingsIconFeedback")
            cell.textLabel?.text = "反馈"
        case (2, 0):
            cell.imageView?.image = UIImage(named: "SettingsIconAbout")
            cell.textLabel?.text = "关于我们"
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("SecurityCenter@CenterSettings", source: self, sender: nil)
        case (1, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath)
        case (1, 1):
            AOLinkedStoryboardSegue.performWithIdentifier("Feedback@CenterSettings", source: self, sender: nil)
        case (2, 0):
            AOLinkedStoryboardSegue.performWithIdentifier("CommonWebViewScene@AccountSession", source: self, sender: indexPath)
        default:
            break
        }
    }
    
}
