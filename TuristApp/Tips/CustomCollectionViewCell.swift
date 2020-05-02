//
//  CustomCollectionViewCell.swift
//  TuristApp
//
//  Created by Diana Cepeda on 26/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import GooglePlaces



class CustomCollectionViewCell: UICollectionViewCell {
    
    
    // An array to hold the list of possible locations.
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var id: String!
    
    var imageView: UIImageView?
    var label: UILabel?
    var tips = TipsViewController()



override init(frame: CGRect) {
    
    
    super.init(frame: frame)
    imageView = UIImageView(frame: self.bounds)
    
    //customise imageview
    imageView?.backgroundColor = UIColor.red
    contentView.addSubview(imageView!)
    label = UILabel(frame: CGRect(x: 20, y: 20, width: self.bounds.width - 20, height: 20))
    //Customsize label
    
    label?.text = "Hello"
    label?.textColor = UIColor.white
    contentView.addSubview(label!)
}
    

required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

override var bounds: CGRect {
    didSet {
        contentView.frame = bounds
    }
}
}
