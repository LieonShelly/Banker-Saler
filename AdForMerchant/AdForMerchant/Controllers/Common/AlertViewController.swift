//
//  AlertViewController.swift
//  提示探矿
//
//  Created by 糖otk on 2017/4/27.
//  Copyright © 2017年 Burining. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    var confirmBlock: ((_ price: String) -> Void)?
    var cancelBlock: (() -> Void)?
    @IBAction func confirmAction(_ sender: Any) {
        guard let block = confirmBlock else {return}
        block(textField.text ?? "")
    }
    @IBAction func cancelAction(_ sender: Any) {
        guard let block = cancelBlock else {return}
        block()
    }
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 5
        textField.addTarget(self, action: #selector(self.alertTextFieldChange(textFiled:)), for: .editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertTextFieldChange(textFiled: UITextField) {
        let tfString = textFiled.text ?? ""
        let stringCount = tfString.characters.count
        let nsTfString = tfString as NSString
        if tfString.contains(".") {
            if nsTfString.substring(from: stringCount-1) == "." {
            } else {
                let strlocation = nsTfString.range(of: ".")
                let decimalCount = nsTfString.substring(from: strlocation.location).characters.count
                if decimalCount >= 3 {
                    textFiled.text = nsTfString.substring(to: strlocation.location+3)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
