//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit

class InternalTransfersViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var gelToUsd: Double = 0.00
    var gelToEur: Double = 0.00
    var usdToEur: Double = 0.00
    
    var balanceInGel = 0.00
    var balanceInUsd = 0.00
    var balanceInEur = 0.00
    
    var availableCurrencies = ["GEL", "USD", "EUR"]
    
    @IBOutlet private weak var sellTextField: UITextField!
    @IBOutlet private weak var buyTextField: UITextField!
    
    @IBOutlet private weak var fromTextField: UITextField!
    @IBOutlet private weak var toTextField: UITextField!
    
    
    
    var sellCurrencyPicker = UIPickerView()
    var buyCurrencyPicker = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserBalance()
        getExchangeValues()
        setUpPickers()
    }
    
    func getUserBalance() {
        let defaults = UserDefaults.standard
        
        balanceInGel = round(defaults.double(forKey: userDefaultKeyNames.GEL.rawValue) * 100) / 100
        balanceInUsd = round(defaults.double(forKey: userDefaultKeyNames.USD.rawValue) * 100) / 100
        balanceInEur = round(defaults.double(forKey: userDefaultKeyNames.EUR.rawValue) * 100) / 100
        
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
        do {
            let fetchedExchangeRates = try context.fetch(ExchangeRates.fetchRequest())
            guard let firstValueOfExchangeRates = fetchedExchangeRates.first else { return }
            
            gelToUsd = firstValueOfExchangeRates.gelToUsd
            gelToEur = firstValueOfExchangeRates.gelToEur
            usdToEur = firstValueOfExchangeRates.usdToEur
        } catch {
            print("Could not load data")
        }
    }
    
    @IBAction func sellValueEditing(_ sender: UITextField) {
        setBuyAmount()
    }
    
    @IBAction func buyValueEditing(_ sender: UITextField) {
        setSellAmount()
    }
    
    func returnDesiredCurrency() -> Double? {
        guard let toTextFieldText = toTextField.text else { return nil }
        guard let fromTextFieldText = fromTextField.text else { return nil }
        
        if !fromTextFieldText.isEmpty  && !toTextFieldText.isEmpty {
            if fromTextFieldText == "GEL" {
                switch toTextFieldText {
                case "USD":
                    return 1 / gelToUsd
                case "EUR":
                    return 1 / gelToEur
                default:
                    return nil
                }
            } else if toTextFieldText == "GEL" {
                switch fromTextFieldText {
                case "USD":
                    return gelToUsd
                case "EUR":
                    return gelToEur
                default:
                    return nil
                }
            } else {
                switch fromTextFieldText {
                case "USD":
                    return usdToEur
                case "EUR":
                    return 1 / usdToEur
                default:
                    return nil
                }
            }
        }
        return nil
    }
    
    func getDesiredCurrencyBalance() -> Double? {
        switch fromTextField.text {
        case "GEL":
            return balanceInGel
        case "USD":
            return balanceInUsd
        case "EUR":
            return balanceInUsd
        default:
            return nil
        }
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        if validateForEmptiness() {
            guard let sellText = sellTextField.text else { return }
            guard let sellAmount = Double(sellText) else { return }
            
            guard let buyText = buyTextField.text else { return }
            guard let buyAmount = Double(buyText) else { return }
            
            guard let fromCurrencyBalance = getDesiredCurrencyBalance() else { return }
            
            if fromCurrencyBalance >= sellAmount {
                print(buyAmount)
            }
            else {
                showAlertWithOkButton(title: nil, message: "You do not have enough money on balance.")
                
            }
        }
    }
    
    func validateForEmptiness() -> Bool {
        if fromTextField.text?.isEmpty ?? true || toTextField.text?.isEmpty ?? true {
            clearBuyAndSell()
            showAlertWithOkButton(title: nil, message: "Please select currencies")
            return false
        } else if buyTextField.text?.isEmpty ?? true || sellTextField.text?.isEmpty ?? true {
            clearBuyAndSell()
            showAlertWithOkButton(title: nil, message: "Please select amount to sell")
            return false
        }
        // if validations are successfull and user has enered amount already refresh it
        setBuyAmount()
        
        return true
    }
    
    func clearBuyAndSell() {
        buyTextField.text = ""
        sellTextField.text = ""
    }
    
    private func setBuyAmount() {
        guard let desiredCurrency = returnDesiredCurrency() else { return }
        guard let sellAmountText = sellTextField.text else { return }
        // if value becomes zero
        guard let sellAmount = Double(sellAmountText) else {
            buyTextField.text = ""
            return
        }
        
        buyTextField.text = "\(round(sellAmount * desiredCurrency * 100.0) / 100.0)"
    }
    
    private func setSellAmount() {
        guard let desiredCurrency = returnDesiredCurrency() else { return }
        guard let buyAmountTExt = buyTextField.text else { return }
        guard let buyAmount = Double(buyAmountTExt) else {
            sellTextField.text = ""
            return
        }
        
        sellTextField.text = "\(round(buyAmount / desiredCurrency * 100.0) / 100.0)"
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
