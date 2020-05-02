//
//  CalculatorViewController.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import CountryPickerView
import Foundation
import SwiftyJSON
import Network

class CalculatorViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Properties
    let userDefaults = UserDefaults.standard
    var baseURL = "http://data.fixer.io/api/latest?access_key="
    
    @IBOutlet weak var coFlagImage: UIImageView!
    @IBOutlet weak var colombiaLabel: UILabel!
    @IBOutlet weak var copLabel: UILabel!
    @IBOutlet weak var valueTxtFld: UITextField!
    @IBOutlet weak var addCurrencyButton: UIButton!
    @IBOutlet weak var calculatorTableView: UITableView!
    
    let cpvInternal = CountryPickerView()
    var connected: Bool?
    
    let monitor = NWPathMonitor()
    
    //var currencies = [String:Double]()
    
    let cellReuseIdentifier = "CalculatorTableViewCell"
    
    let refreshControl = UIRefreshControl()
    
    // MARK: -Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set currency data
        /*if userDefaults.object(forKey: "currencies") != nil {
            currencies = userDefaults.object(forKey: "currencies") as! [String:Double]
        } else {
            currencies = ["USD": 4000.00, "EUR": 4400.00]
            userDefaults.set(currencies, forKey: "currencies")
        }*/
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied {
                self.connected = true
            } else {
                self.connected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        //calculatorTableView.rowHeight = 56.0
        calculatorTableView.delegate = self
        calculatorTableView.dataSource = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        calculatorTableView.addSubview(refreshControl)
        calculatorTableView.separatorColor = UIColor.white
        
        if userDefaults.object(forKey: "currenciesSaved") == nil {
            updateCurrencies()
        } else {
            calculatorTableView.reloadData()
        }
        
        cpvInternal.dataSource = self
        cpvInternal.delegate = self
        addCurrencyButton.addTarget(self, action: #selector(addCurrencyAction(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
        //Load COL info.
        let colombia = CountryPickerView().getCountryByCode("CO")
        coFlagImage.image = colombia?.flag
        colombiaLabel.text = colombia?.name
        getCountryCurrencyCode(countryCode: "CO", label: copLabel)
        
        valueTxtFld.delegate = self
        valueTxtFld.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        //valueTxtFld.layer.borderColor = UIColor(red: CGFloat(99)/255.0, green: CGFloat(94)/255.0, blue: CGFloat(225)/255.0, alpha: CGFloat(1.0)).cgColor
        valueTxtFld.adjustsFontSizeToFitWidth = true
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 2
        //currencyFormatter.locale = Locale(identifier: "co_CO")
        valueTxtFld.text = currencyFormatter.string(from: 1000.00)
        setUpTexField()
        
        colombiaLabel.adjustsFontSizeToFitWidth = true
        colombiaLabel.minimumScaleFactor = 0.2
        colombiaLabel.numberOfLines = 0 // or 1
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        calculatorTableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        if connected! {
            updateCurrencies()
        } else {
            showAlert(title: "Couldn't Update Currencies", message: "Check your internet connection to get the latest rates.")
        }
    }
    
    func showAlert(title: String, message: String) {
        refreshControl.endRefreshing()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setUpTexField() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        toolbar.sizeToFit()
        
        valueTxtFld.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    private func updateCurrencies() {
        var dictToSave = userDefaults.object(forKey: "currenciesSaved") as? [String:Double] ?? [:]
        guard let key = ProcessInfo.processInfo.environment["FIXER_API_KEY"] else {
            fatalError("Problems with Fixer API Key")
        }
        baseURL += key
        let url = URL(string: baseURL)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            let json = try! JSON(data: data!)
            let rates = json["rates"].dictionaryObject as! [String:Double]
            let EURCOP = rates["COP"]!
            let COPEUR = 1/EURCOP
            dictToSave["EUR"] = COPEUR
            if let path = Bundle.main.path(forResource: "codeToCurrency", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, String> {
                              // do stuff
                        jsonResult.values.forEach {currency in
                            if rates[currency] != nil {
                                dictToSave[currency] = COPEUR*rates[currency]!
                            } else {
                                dictToSave[currency] = -1.0
                            }
                        }
                    }
                } catch {
                     // handle error
                }
            }
            self.userDefaults.set(dictToSave, forKey: "currenciesSaved")
            if self.userDefaults.object(forKey: "countriesShown") == nil {
                let arrayToShow = ["ES","US"]
                self.userDefaults.set(arrayToShow, forKey: "countriesShown")
            }
            
            DispatchQueue.main.async {
                self.calculatorTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
        task.resume()
    }
    
    @objc func addCurrencyAction(_ sender: Any) {
        cpvInternal.showCountriesList(from: self)
    }
    
    func getCountryCurrencyCode(countryCode: String, label: UILabel) {
        if let path = Bundle.main.path(forResource: "codeToCurrency", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, String>, let currencyCode = jsonResult[countryCode] {
                          // do stuff
                    label.text = currencyCode
                }
            } catch {
                 // handle error
            }
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
    //MARK: -UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //updateSaveButtonState()
        //navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.isEnabled = false
        valueTxtFld.text = ""
    }

}

//MARK: -Extensions - Country picker delegate
extension CalculatorViewController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        // Only countryPickerInternal has it's delegate set
        //countryLabel.text = country.name
        //getCountryCurrencyCode(countryCode: country.code)
        //colombianFlag.image = country.flag
        //showAlert(title: title, message: message)
        var countriesShown = userDefaults.object(forKey: "countriesShown") as! [String]
        let newIndexPath = IndexPath(row: countriesShown.count, section: 0)
        countriesShown.append(country.code)
        userDefaults.set(countriesShown, forKey: "countriesShown")
        calculatorTableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

extension CalculatorViewController: CountryPickerViewDataSource {
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country to Convert Currenncy"
    }
    
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }
}

//MARK: -Extensions - Table view delegate
extension CalculatorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*selectedPoint = plan!.pointsOfInterest[indexPath.row]
        performSegue(withIdentifier: "pointToInfo", sender: self)*/
    }
}

extension CalculatorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currenciesToShow = userDefaults.object(forKey: "countriesShown") as? [String] else {return 0}
        return (currenciesToShow.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CalculatorTableViewCell else {
             fatalError("The dequeued cell is not an instance of PlanTableViewCell.")
        }
        let countriesShown = userDefaults.object(forKey: "countriesShown") as? [String]
        let currencies = userDefaults.object(forKey: "currenciesSaved") as? [String:Double]
        let countryCode = countriesShown![indexPath.row]
        
        let country = CountryPickerView().getCountryByCode(countryCode)
        cell.countryFlagImage.image = country?.flag
        cell.countryName.text = country?.name
        getCountryCurrencyCode(countryCode: countryCode, label: cell.currencyCode)
        let amountCOP = valueTxtFld.text! as NSString
        let cellValue = currencies![cell.currencyCode.text!]!*Double(amountCOP.doubleValue)
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 2
        //currencyFormatter.locale = Locale(identifier: countryCode.lowercased() + "_" + countryCode.uppercased())
        cell.calculatedValue.text =  currencyFormatter.string(from: cellValue as NSNumber)

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var currenciesToShow = userDefaults.object(forKey: "countriesShown") as? [String] else {return}
        if editingStyle == .delete {
            // Delete the row from the data source
            currenciesToShow.remove(at: indexPath.row)
            userDefaults.set(currenciesToShow, forKey: "countriesShown")
            calculatorTableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
