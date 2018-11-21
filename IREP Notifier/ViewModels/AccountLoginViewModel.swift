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
  private var selectedCategory: Int = 0
  // data observables
  private let items: Observable<[String]>
  private let companyId: BehaviorRelay<String?>
  private let username: BehaviorRelay<String?>
  private let password: BehaviorRelay<String?>
  // UI elements
  private let viewController: AccountLoginViewController
  
  init(viewController: AccountLoginViewController) {
    self.items = Observable.of(self.categories)
    self.companyId = BehaviorRelay<String?>(value: nil)
    self.username = BehaviorRelay<String?>(value: nil)
    self.password = BehaviorRelay<String?>(value: nil)
    self.viewController = viewController
    self.bindTextField(viewController.companyIdTextField, source: self.companyId)
    self.bindTextField(viewController.usernameTextField, source: self.username)
    self.bindTextField(viewController.passwordTextField, source: self.password)
    self.bindAddAccountButton(viewController.addAccountButton)
    self.bindCategoryButton(viewController.categoryButton)
    self.bindDataSourceTo(self.viewController.pickerView)
    self.bindOnSelctionHandlerTo(self.viewController.pickerView)
    // initial setup
    self.viewController.pickerView.isHidden = true
    let info = LoginInfo(
      category: 1,
      company: "SEN0001",
      username: "aaronlee",
      password: "6628"
    )
    AccountManager.insertAccountBy(info: info)?
      .subscribe(
        onNext: { (result) in
          if result.statusCode == 1 {
            viewController.alert(
              title: "OK", message: result.statusMessage, completion: nil
            )
          } else {
            viewController.alert(
              title: "Error(?)", message: result.statusMessage, completion: nil
            )
          }
        },
        onError: { (err) in
          viewController.alert(
            title: err.localizedDescription, message: nil, completion: nil
          )
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  private func bindTextField(
    _ textfield: UITextField,
    source: BehaviorRelay<String?>
  ) {
    textfield.rx.text
      .distinctUntilChanged()
      .bind(to: source)
      .disposed(by: self.disposeBag)
  }
  
  private func bindAddAccountButton(_ button: UIButton) {
    
  }
  
  private func bindCategoryButton(_ button: UIButton) {
    button.rx.tap.asDriver()
      .drive(
        onNext: {
          self.viewController.pickerView.isHidden = false
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
  private func bindDataSourceTo(_ picker: UIPickerView) {
    self.items
      .bind(to: picker.rx.itemTitles) { (row, component) in
        return component
      }
      .disposed(by: self.disposeBag)
  }
  
  private func bindOnSelctionHandlerTo(_ picker: UIPickerView) {
    picker.rx.itemSelected
      .subscribe(
        onNext: { (row, component) in
          self.selectedCategory = row
          let opt = self.categories[row]
          self.viewController.categoryButton.setTitle(opt, for: .normal)
          self.viewController.pickerView.isHidden = true
        },
        onError: nil,
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
  
}
