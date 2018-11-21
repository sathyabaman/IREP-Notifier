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
  
  init(viewController: AccountLoginViewController) {
    self.items = Observable.of(self.categories)
    let info = LoginInfo(category: 0, company: "", username: "", password: "")
    self.loginInfo = BehaviorRelay<LoginInfo>(value: info)
    self.viewController = viewController
    // data observable bindings
    self.bindCompanyIdFrom(viewController.companyIdTextField)
    self.bindUsernameFrom(viewController.usernameTextField)
    self.bindPasswordFrom(viewController.passwordTextField)
    self.bindAddAccountButton(viewController.addAccountButton)
    self.bindCategoryButton(viewController.categoryButton)
    self.bindDataSourceTo(self.viewController.pickerView)
    self.bindOnSelctionHandlerTo(self.viewController.pickerView)
    // initial setup
//    let i = LoginInfo(
//      category: 1,
//      company: "SEN0001",
//      username: "aaronlee",
//      password: "6628"
//    )
//    AccountManager.insertAccountBy(info: i)?
//      .subscribe(
//        onNext: { (result) in
//          if result.statusCode == 1 {
//            viewController.alert(
//              title: "OK", message: result.statusMessage, completion: nil
//            )
//          } else {
//            viewController.alert(
//              title: "Error(?)", message: result.statusMessage, completion: nil
//            )
//          }
//        },
//        onError: { (err) in
//          viewController.alert(
//            title: err.localizedDescription, message: nil, completion: nil
//          )
//        },
//        onCompleted: nil,
//        onDisposed: nil
//      )
//      .disposed(by: self.disposeBag)
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
          AccountManager.insertAccountBy(info: self.loginInfo.value)?
            .subscribe(
              onNext: { (result) in
                if result.statusCode == 1 {
                  self.viewController.alert(
                    title: "Added account successfully",
                    message: result.statusMessage
                  ) { _ in
                    self.viewController.dismiss(animated: true, completion: nil)
                  }
                } else {
                  self.viewController.alert(
                    title: "Failed to add account",
                    message: result.statusMessage
                  ) { _ in
                    self.viewController.dismiss(animated: true, completion: nil)
                  }
                }
              },
              onError: { (error) in
                self.viewController.alert(
                  title: "Failed to add account",
                  message: error.localizedDescription
                ) { _ in
                  self.viewController.dismiss(animated: true, completion: nil)
                }
              },
              onCompleted: nil,
              onDisposed: nil
            )
            .disposed(by: self.disposeBag)
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
  
  private func bindOnSelctionHandlerTo(_ picker: UIPickerView) {
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
  
}
