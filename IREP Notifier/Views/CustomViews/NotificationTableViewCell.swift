//
//  NotificationTableViewCell.swift
//  IREP Notifier
//
//  Created by Kerk Chin Wee on 6/11/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
  static let identifier = "NotificationTableViewCell"

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
}
