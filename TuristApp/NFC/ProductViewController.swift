//
//  ProdcuctViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 26/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit

class ProductViewController: UITableViewController {
    class ProductViewController: UITableViewController {
    
    var product: Product!
    
    
    @IBAction func closeTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = product.name
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
            let imageView = cell.viewWithTag(1001) as? UIImageView
            //imageView?.image = product.image
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = product.name
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Price"
            cell.detailTextLabel?.text = product.price
            return cell
         
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Availability"
            cell.detailTextLabel?.text = product.inStock ? "In stock" : "Out of stock"
            return cell
            
            
        case 4:
          
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "SKU"
            cell.detailTextLabel?.text = product.id
            return cell
            
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = product.description
            return cell
            
            
            
        default: fatalError()
            
            
        }
    }
}
}
