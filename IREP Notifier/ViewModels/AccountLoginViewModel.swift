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
  }
  
  private func bindCompanyIdTextField(_ textfield: UITextField) {
    textfield.rx.text
      .asObservable()
      .distinctUntilChanged()
      .bind(to: companyId)
      .disposed(by: self.disposeBag)
  }
}
