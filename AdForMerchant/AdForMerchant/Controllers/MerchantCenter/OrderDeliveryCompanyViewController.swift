//
//  OrderDeliveryCompanyViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 4/20/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class OrderDeliveryCompanyTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var leftTxtLabel: UILabel!
    @IBOutlet internal var selectionButton: UIButton!
    
    internal var isCompanySelected: Bool = false {
        didSet {
            if isCompanySelected {
                leftTxtLabel.textColor = UIColor.commonBlueColor()
                selectionButton.isHidden = false
            } else {
                leftTxtLabel.textColor = UIColor.commonTxtColor()
                selectionButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftTxtLabel.textColor = UIColor.commonTxtColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func config(_ name: String) {
        leftTxtLabel.text = name
    }
}

class OrderDeliveryCompanyTableViewCell2: UITableViewCell {
    
    @IBOutlet internal var leftTxtLabel: UILabel!
    @IBOutlet internal var rightTxtField: UITextField!
    @IBOutlet internal var selectionButton: UIButton!
    var beginEditingBlock: ((Void) -> Void)?
    var endEditingBlock: ((String) -> Void)?
    
    internal var isCompanySelected: Bool = false {
        didSet {
            if isCompanySelected {
                leftTxtLabel.textColor = UIColor.commonBlueColor()
                selectionButton.isHidden = false
            } else {
                leftTxtLabel.textColor = UIColor.commonTxtColor()
                selectionButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftTxtLabel.textColor = UIColor.commonTxtColor()
        
        rightTxtField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

extension OrderDeliveryCompanyTableViewCell2: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let block = beginEditingBlock {
            block()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var str: String = textField.text else {return}
        if str.isEmpty == false {
            if let block = endEditingBlock {
                let char = str.characters[(str.characters.startIndex)]
                if  char == "￥"{
                    str.remove(at: str.characters.startIndex)
                }
                block(str)
            }
        }
    }
    
}

class OrderDeliveryCompanyViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate var bottomBtn: UIButton!
    
    fileprivate var companyNames: [DeliveryCompany] = []
    
    fileprivate var selectedIndex: Int = -1
    fileprivate var otherCompany: String = ""
    
//    var selectedName: String = ""
    var selectedCompany: DeliveryCompany?
    var completeBlock: ((DeliveryCompany) -> Void)?
    
    var txtFiledWillBecomeFirstResponder: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "物流公司"
        
        tableView.keyboardDismissMode = .onDrag
        
        bottomBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        requestDeliveryCompanyList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    func makeDefaultSelection() {
        
        if let selectedCompany = selectedCompany {
            if selectedCompany.shorthand == "OtherCompany" {
                selectedIndex = companyNames.count
                otherCompany = selectedCompany.name
            } else {
                for (index, company) in companyNames.enumerated() where company.shorthand == selectedCompany.shorthand {
                    selectedIndex = index
                    break
                }
            }
        }
        
    }
    
    // MARK: - Http request
    
    func requestDeliveryCompanyList() {
        Utility.showMBProgressHUDWithTxt()
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        RequestManager.request(AFMRequest.logisticsList(aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV), completionHandler: { (request, response, object, error, _) -> Void in
            Utility.hideMBProgressHUD()
            
            if (object) != nil {
                guard var result = object as? [String: AnyObject] else {return}
                if let array = result["logistics"] as? [AnyObject] {
//                    self.bankAccountArray.removeAll()
                    for item in array {
                        guard let model = item as? [String : AnyObject] else {return}
                        guard let modelArray  = DeliveryCompany(JSON: model) else {return}
                        self.companyNames.append(modelArray)
                    }
                    self.companyNames.append(DeliveryCompany(shorthand: "NoCompany", name: "无物流"))
                    
                    self.makeDefaultSelection()
                }
                self.tableView.reloadData()
            } else {
            }
            
        })

    }
    
    // MARK: - Button Action
    
    func confirmAction() {
        view.endEditing(true)
        
        if selectedIndex < 0 {
            Utility.showAlert(self, message: "请选择一家快递公司")
            return
        } else if selectedIndex == companyNames.count && otherCompany.isEmpty {
            Utility.showAlert(self, message: "请填写快递公司的名称")
            return
        }
        
        if let block = completeBlock {
            if selectedIndex < companyNames.count {
                block(companyNames[selectedIndex])
            } else {
                block(DeliveryCompany(shorthand: "OtherCompany", name: otherCompany))
            }
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: - Keyboard Notification
    
    func keyboardWillShow(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let keyboardSize = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillHide(_ notifi: Notification) {
        guard let keyboardInfo = notifi.userInfo as? [String: AnyObject] else {return}
        guard let duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {return}
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        }) 
    }
    
}

extension OrderDeliveryCompanyViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyNames.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < companyNames.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryCompanyTableViewCell") as? OrderDeliveryCompanyTableViewCell else {return UITableViewCell()}
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryCompanyTableViewCell2") as? OrderDeliveryCompanyTableViewCell2 else {return UITableViewCell()}
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row < companyNames.count {
            guard let _cell = cell as? OrderDeliveryCompanyTableViewCell else {return}
            _cell.config(companyNames[indexPath.row].name)
            
            _cell.isCompanySelected = (selectedIndex == indexPath.row)
        } else {
            guard let _cell = cell as? OrderDeliveryCompanyTableViewCell2 else {return}
            _cell.rightTxtField.text = otherCompany
            _cell.beginEditingBlock = {
                if self.selectedIndex == indexPath.row {
                } else {
                    self.selectedIndex = indexPath.row
                    self.txtFiledWillBecomeFirstResponder = true
                    self.tableView.reloadData()
                    
                }
            }
            
            _cell.endEditingBlock = {txt in self.otherCompany = txt}
            if txtFiledWillBecomeFirstResponder {
                txtFiledWillBecomeFirstResponder = false
                _cell.rightTxtField.becomeFirstResponder()
            }
            _cell.isCompanySelected = (selectedIndex == indexPath.row)

        }
    }
    
}

extension OrderDeliveryCompanyViewController: UITableViewDelegate {
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        tableView.reloadData()
        
    }
    
}
