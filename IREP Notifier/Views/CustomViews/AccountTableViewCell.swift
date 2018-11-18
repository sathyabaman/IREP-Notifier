//
//  AccountTableViewCell.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 31/10/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
  static let identifier = "AccountTableViewCell"
  
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var loginIdLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
}
