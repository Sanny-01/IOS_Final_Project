//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit

class InternalTransfersViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    var GELToUSD = 0.00
    var GELToEUR = 0.00
    
    var availableCurrencies = ["GEL", "USD", "EUR"]
    
    @IBOutlet weak var sellTextField: UITextField!
    @IBOutlet weak var buyTextField: UITextField!
    
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    
    
    var sellCurrencyPicker = UIPickerView()
    var buyCurrencyPicker = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getExchangeValues()
        setUpPickers()

        // Do any additional setup after loading the view.
    }

    func setUpPickers() {
        fromTextField.inputView = sellCurrencyPicker
        toTextField.inputView = buyCurrencyPicker
        
        sellCurrencyPicker.delegate = self
        sellCurrencyPicker.dataSource = self
        
        buyCurrencyPicker.delegate = self
        buyCurrencyPicker.dataSource = self
        
        sellCurrencyPicker.tag = 0
        buyCurrencyPicker.tag = 1
    }
    
    func getExchangeValues() {
        GELToUSD = defaults.double(forKey: exchangeRateNames.GELToUSD.rawValue)
        GELToEUR = defaults.double(forKey: exchangeRateNames.GELToEUR.rawValue)
    }
    
    @IBAction func sellValueEditing(_ sender: UITextField) {
        
        guard let sell = sellTextField.text else { return }
        
        if !sell.isEmpty {
            let sellAmount = Double(sell)
            buyTextField.text = "\(round(sellAmount! / GELToUSD * 100.0) / 100.0)"
        } else
        {
            buyTextField.text = ""
        }
    }
    
    
    func returnDesiredCurrency() {
        
    }
}

extension InternalTransfersViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        availableCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return availableCurrencies[row]
        case 1:
            return availableCurrencies[row]
        default:
            return "Error occured"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            fromTextField.text = availableCurrencies[row]
            fromTextField.resignFirstResponder()
            
            if fromTextField.text == toTextField.text { toTextField.text = ""}
        case 1:
            toTextField.text = availableCurrencies[row]
            toTextField.resignFirstResponder()
            
            if fromTextField.text == toTextField.text { fromTextField.text = ""}
        default:
            print("Error occured")
        }
    }
}
