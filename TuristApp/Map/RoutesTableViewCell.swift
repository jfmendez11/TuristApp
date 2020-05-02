//
//  RoutesTableViewCell.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit

class RoutesTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    /*let cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()*/
    
    /*override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.layer.cornerRadius = 10
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            self.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            self.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            self.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        nameLabel.textColor = UIColor.white
        countLabel.textColor = UIColor.white
        createdAtLabel.textColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        countLabel.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        createdAtLabel.textColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        
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
