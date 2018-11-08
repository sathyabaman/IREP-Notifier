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
  
  override func awakeFromNib() {
    self.contentView.frame = self.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    super.layoutSubviews()
    self.contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
    self.layer.cornerRadius = 10.0
  }
}
