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
  private let categories = ["IREP Security", "IREP Workforce", "M2 Sense"]
  private let disposeBag = DisposeBag()
  // data observables
  private let items: Observable<[String]>
  private let loginInfo: BehaviorRelay<LoginInfo>
  // UI elements
  private let viewController: AccountLoginViewController
  
  var isFormFilled: Bool {
    let x = self.viewController.companyIdTextField.text?.isEmpty ?? false
    let y = self.viewController.usernameTextField.text?.isEmpty ?? false
    let z = self.viewController.passwordTextField.text?.isEmpty ?? false
    return !x && !y && !z
  }
  
  init(viewController: AccountLoginViewController) {
    self.items = Observable.of(self.categories)
    let info = LoginInfo(category: 1, company: "", username: "", password: "")
    self.loginInfo = BehaviorRelay<LoginInfo>(value: info)
    self.viewController = viewController
    // data observable bindings
    self.bindCompanyIdFrom(viewController.companyIdTextField)
    self.bindUsernameFrom(viewController.usernameTextField)
    self.bindPasswordFrom(viewController.passwordTextField)
    self.bindAddAccountButton(viewController.addAccountButton)
    self.bindCategoryButton(viewController.categoryButton)
    self.bindDataSourceTo(self.viewController.pickerView)
    self.bindOnSelectionHandlerTo(self.viewController.pickerView)
  }
  
  private func bindCompanyIdFrom(_ textfield: UITextField) {
    textfield.rx.text
      .distinctUntilChanged()
      .filter { (text) -> Bool in
        return text != nil && !text!.isEmpty
      }
      .flatMapLatest { (text) -> Observable<LoginInfo> in
        var info = self.loginInfo.value
        info.company = text!
        return Observable.of(info)
      }
      .bind(to: self.loginInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func bindUsernameFrom(_ textfield: UITextField) {
    textfield.rx.text
      .distinctUntilChanged()
      .filter { (text) -> Bool in
        return text != nil && !text!.isEmpty
      }
      .flatMapLatest { (text) -> Observable<LoginInfo> in
        var info = self.loginInfo.value
        info.username = text!
        return Observable.of(info)
      }
      .bind(to: self.loginInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func bindPasswordFrom(_ textfield: UITextField) {
    textfield.rx.text
      .distinctUntilChanged()
      .filter { (text) -> Bool in
        return text != nil && !text!.isEmpty
      }
      .flatMapLatest { (text) -> Observable<LoginInfo> in
        var info = self.loginInfo.value
        info.password = text!
        return Observable.of(info)
      }
      .bind(to: self.loginInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func bindAddAccountButton(_ button: UIButton) {
    button.rx.tap.asDriver()
      .drive(
        onNext: {
          DispatchQueue.main.async {
            self.viewController.view.endEditing(false)
            guard self.isFormFilled else {
              self.viewController.alert(
                title: "Missing login information",
                message: "Please fill all text fields before login",
                completion: nil
              )
              return
            }
            self.addAccount()
          }
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
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
      .bind(to: picker.rx.itemTitles) { (row, element) in
        return element
      }
      .disposed(by: self.disposeBag)
  }
  
  private func bindOnSelectionHandlerTo(_ picker: UIPickerView) {
    picker.rx.itemSelected
      .flatMapLatest({ (row, component) -> Observable<LoginInfo> in
        let opt = self.categories[row]
        self.viewController.categoryButton.setTitle(opt, for: .normal)
        self.viewController.pickerView.isHidden = true
        var info = self.loginInfo.value
        info.category = row + 1
        return Observable.of(info)
      })
      .bind(to: self.loginInfo)
      .disposed(by: self.disposeBag)
  }
  
  private func addAccount() {
    AccountManager.insertAccountBy(info: self.loginInfo.value)?
      .subscribe(
        onNext: { (result) in
          DispatchQueue.main.async {
            self.viewController.alert(
              title: "Added account successfully",
              message: result.statusMessage
            ) { _ in
              self.viewController.navigationController?
                .popViewController(animated: true)
            }
          }
        },
        onError: { (error) in
          DispatchQueue.main.async {
            self.viewController.alert(
              title: "Failed to add account",
              message: error.localizedDescription
            ) { _ in
              self.viewController.navigationController?
                .popViewController(animated: true)
            }
          }
        },
        onCompleted: nil,
        onDisposed: nil
      )
      .disposed(by: self.disposeBag)
  }
}
