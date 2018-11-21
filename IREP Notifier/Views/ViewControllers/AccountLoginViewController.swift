//
//  AccountLoginViewController.swift
//  IREP Notifier
//
//  Created by Chin Wee Kerk on 17/11/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import FontAwesome_swift

class AccountLoginViewController: UIViewController {
  private var accountViewModel: AccountLoginViewModel!
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var loginFormView: UIView!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var companyIdTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var addAccountButton: UIButton!
  @IBOutlet weak var pickerView: UIPickerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.accountViewModel = AccountLoginViewModel(viewController: self)
    self.addAccountButton.layer.cornerRadius = 5.0
    let buttonText = "IREP Security \(String.fontAwesomeIcon(name: .plane))"
    self.categoryButton.setTitle(buttonText, for: .normal)
    self.navigationController?.navigationBar.tintColor = UIColor.white
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.view.endEditing(false)
    self.pickerView.isHidden = true
  }
  
}
