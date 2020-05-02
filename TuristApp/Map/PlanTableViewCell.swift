//
//  PlanTableViewCell.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit

class PlanTableViewCell: UITableViewCell {
    // MARK: -Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.numberOfLines = 0
        
        addressLabel.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.2
        addressLabel.numberOfLines = 0
        
        self.backgroundColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 10
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5))
        contentView.backgroundColor = UIColor(red: CGFloat(37)/255.0, green: CGFloat(56)/255.0, blue: CGFloat(110)/255.0, alpha: CGFloat(1.0))
    }
}
