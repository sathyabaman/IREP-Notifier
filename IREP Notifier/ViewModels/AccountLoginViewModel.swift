//
//  AccountLoginViewModel.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 19/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON

struct AccountLoginViewModel {
  private let disposeBag = DisposeBag()
  // data observables
  private let companyId: BehaviorRelay<String?>
  private let username: BehaviorRelay<String?>
  private let password: BehaviorRelay<String?>
  
  init(viewController: AccountLoginViewController) {
    self.companyId = BehaviorRelay<String?>(value: nil)
    self.username = BehaviorRelay<String?>(value: nil)
    self.password = BehaviorRelay<String?>(value: nil)
    self.bindTextField(viewController.companyIdTextField, source: self.companyId)
    self.bindTextField(viewController.usernameTextField, source: self.username)
    self.bindTextField(viewController.passwordTextField, source: self.password)
    self.bindAddAccountButton(viewController.addAccountButton)
  }
  
  private func bindTextField(
    _ textfield: UITextField,
    source: BehaviorRelay<String?>
  ) {
    textfield.rx.text
      .asObservable()
      .distinctUntilChanged()
      .bind(to: source)
      .disposed(by: self.disposeBag)
  }
  
  private func bindAddAccountButton(_ button: UIButton) {
    button.rx.tap
      .asDriver()
      .drive(
        onNext: {
          
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
}
