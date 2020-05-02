//
//  CalculatorTableViewCell.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//
import Foundation
import UIKit

class CalculatorTableViewCell: UITableViewCell {
    @IBOutlet weak var countryFlagImage: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var calculatedValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        countryName.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        currencyCode.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        calculatedValue.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        
        countryName.adjustsFontSizeToFitWidth = true
        countryName.minimumScaleFactor = 0.2
        countryName.numberOfLines = 0 // or 1
        
        calculatedValue.adjustsFontSizeToFitWidth = true
        calculatedValue.minimumScaleFactor = 0.2
        calculatedValue.numberOfLines = 0 // or 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 10
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5))
        contentView.backgroundColor = UIColor(red: CGFloat(37)/255.0, green: CGFloat(56)/255.0, blue: CGFloat(110)/255.0, alpha: CGFloat(1.0))
    }

}
