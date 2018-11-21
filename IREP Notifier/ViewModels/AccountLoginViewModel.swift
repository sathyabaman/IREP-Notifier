//
//  AccountLoginViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 19/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import FontAwesome_swift
import RxCocoa
import RxSwift
import SwiftyJSON

struct AccountLoginViewModel {
  private let categories = ["IREP Security", "IREP Workforce", "M2 Sense"]
  private let disposeBag = DisposeBag()
  // data observables
  private let companyId: BehaviorRelay<String?>
  private let username: BehaviorRelay<String?>
  private let password: BehaviorRelay<String?>
  // UI elements
  private let viewController: AccountLoginViewController
  
  init(viewController: AccountLoginViewController) {
    self.companyId = BehaviorRelay<String?>(value: nil)
    self.username = BehaviorRelay<String?>(value: nil)
    self.password = BehaviorRelay<String?>(value: nil)
    self.viewController = viewController
    self.bindTextField(viewController.companyIdTextField, source: self.companyId)
    self.bindTextField(viewController.usernameTextField, source: self.username)
    self.bindTextField(viewController.passwordTextField, source: self.password)
    self.bindAddAccountButton(viewController.addAccountButton)
  }
  
  private func bindTextField(
    _ textfield: UITextField,
    source: BehaviorRelay<String?>
  ) {
    textfield.rx.text.asObservable()
      .distinctUntilChanged()
      .bind(to: source)
      .disposed(by: self.disposeBag)
  }
  
  private func bindAddAccountButton(_ button: UIButton) {
    button.rx.tap
      .asObservable()
      .filter({ _ -> Bool in
        let source = self.viewController
        let isCompanyIdEmpty = source.companyIdTextField.text?.isEmpty ?? false
        let isUsernameEmpty = source.usernameTextField.text?.isEmpty ?? false
        let isPasswordEmpty = source.passwordTextField.text?.isEmpty ?? false
        return !isCompanyIdEmpty && !isUsernameEmpty && !isPasswordEmpty
      })
      .subscribe(
        onNext: {
          AccountManager.registerAccountBy(
            type: 1,
            companyId: self.viewController.companyIdTextField.text ?? "",
            username: self.viewController.usernameTextField.text ?? "",
            password: self.viewController.passwordTextField.text ?? ""
          )?
          .subscribe({
            switch $0 {
              case .error(let error):
                self.viewController.alert(
                  title: "Failed to add account",
                  message: error.localizedDescription,
                  completion: { _ in
                    self.viewController.dismiss(animated: true, completion: nil)
                  }
                )
              case .next(let data):
                self.processAddAccountServerResponse(data)
              case .completed:
                break
              }
            })
            .disposed(by: self.disposeBag)
        },
        onError: nil,
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  private func bindCategoryButton(_ button: UIButton) {
    
  }
  
  private func processAddAccountServerResponse(_ data: Data) {
    do {
      let json = try JSON(data: data)
      let status = json["status"].intValue
      switch status {
        case 1: // success
          self.viewController.dismiss(animated: true, completion: nil)
        case 0: // failure
          if let errorMessage = json["ErrMsg"].string {
            self.viewController.alert(
              title: "IREP Notifier is rejected to add account",
              message: errorMessage,
              completion: { _ in
                self.viewController.dismiss(animated: true, completion: nil)
              }
            )
          }
        default: // unexpected encounter
          fatalError("Unexpected result from register account server request")
        }
    } catch {
      fatalError("JSON parse error: \(error)")
    }
  }
  
}
