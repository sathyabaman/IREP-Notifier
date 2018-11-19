//
//  SideMenuTableViewController.swift
//  
//
//  Created by Chin Wee Kerk on 17/11/2018.
//

import UIKit

class SideMenuTableViewController: UITableViewController {
  
  private let segues: [SideMenu] = [
    SideMenu(title: "Add Account", segue: "addAccount"),
    SideMenu(title: "Show Accounts", segue: "listAccounts")
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return segues.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: SideMenuTableViewCell.identifier,
      for: indexPath
    ) as? SideMenuTableViewCell else {
      return UITableViewCell()
    }
    cell.titleLabel.text = self.segues[indexPath.row].title
    return cell
  }
  
  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    self.performSegue(
      withIdentifier: self.segues[indexPath.row].segue,
      sender: nil
    )
  }
  
  override func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    return 50.0
  }

  override func tableView(
    _ tableView: UITableView,
    canEditRowAt indexPath: IndexPath
  ) -> Bool {
    return false
  }
  
  override func tableView(
    _ tableView: UITableView,
    canMoveRowAt indexPath: IndexPath
  ) -> Bool {
    return false
  }
}
