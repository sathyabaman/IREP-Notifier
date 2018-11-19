//
//  AccountLoginViewController.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 17/11/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

class AccountLoginViewController: UIViewController {
  private lazy var accountViewModel: AccountLoginViewModel = {
    return AccountLoginViewModel(viewController: self)
  }()
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var loginFormView: UIView!
  @IBOutlet weak var companyIdTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var addAccountButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addAccountButton.layer.cornerRadius = 5.0
  }
  
}
