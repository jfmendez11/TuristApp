//
//  PointInfoViewController.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit

class PointInfoViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placePhoto: UIImageView!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var ratingControl: UIStackView!
    
    var ratingImages = [UIImageView]()
    
    var selectedPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = selectedPlace?.name
        phoneNumber.text = selectedPlace?.phone
        website.text = selectedPlace?.website
        //ratingControl.rating = selectedPlace?.rating
        if let data = selectedPlace?.photo as Data? {
            placePhoto.image = UIImage(data: data)
        } else {
             placePhoto.image = UIImage(named: "no-image-icon.png")
        }
        // Do any additional setup after loading the view.
        let starSize: CGSize = CGSize(width: 44.0, height: 44.0)
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        for image in ratingImages {
            ratingControl.removeArrangedSubview(image)
            image.removeFromSuperview()
        }
        
        for i in 0..<5 {
            let image = UIImageView()
            image.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            image.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            image.image = emptyStar
            if Float(i+1) <= selectedPlace!.rating {
                image.image = filledStar
            } else if Float(i) < selectedPlace!.rating && Float(i+1) > selectedPlace!.rating {
                image.image = filledStar
                let maskLayer = CALayer()
                let maskWidth = CGFloat(selectedPlace!.rating - Float(i)) * image.frame.size.width
                let maskHeight = image.frame.size.height
                maskLayer.frame = CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight)
                maskLayer.backgroundColor = UIColor.black.cgColor
                image.layer.contents = emptyStar?.cgImage
                image.layer.mask = maskLayer
                //image.isHidden = false
            }
            ratingControl.addArrangedSubview(image)
            ratingImages.append(image)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
