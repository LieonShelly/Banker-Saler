//
//  SignInHomeViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 2/26/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class SignInHomeViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(animated)
    }
    
    @IBAction func signinHandle() {
        performSegue(withIdentifier: "SigninSegue", sender: self)
    }
    
    @IBAction func signupHandle() {
        performSegue(withIdentifier: "SignupSegue", sender: self)
    }

}
