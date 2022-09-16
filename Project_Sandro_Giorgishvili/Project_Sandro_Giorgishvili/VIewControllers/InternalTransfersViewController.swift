//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    
    @IBOutlet private weak var balanceForFromLbl: UILabel!
    @IBOutlet private weak var balanceForToLbl: UILabel!
    
    @IBOutlet weak var toLabel: UIView!
    
    var sellCurrencyPicker = UIPickerView()
    var buyCurrencyPicker = UIPickerView()
    
    let sellTextFieldBottomLine = CALayer()
    let buyTextFieldBottomLine = CALayer()
    let fromTextFieldBottomLine = CALayer()
    let toTextFIeldBottomLine = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFields()
        getUserBalance()
        getExchangeValues()
        setUpPickers()
    }
    
    func setUpTextFields() {
        setUpTextFieldBottomLine(textField: sellTextField, bottomLine: sellTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: buyTextField, bottomLine: buyTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: fromTextField, bottomLine: fromTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: toTextField, bottomLine: toTextFIeldBottomLine)
        
        guard let chevronDonwImage = UIImage(systemName: "chevron.down") else { return }
        
        fromTextField.setUpRightViewImage(image: chevronDonwImage)
        toTextField.setUpRightViewImage(image: chevronDonwImage)
    }
    
    func setUpTextFieldBottomLine(textField: UITextField, bottomLine: CALayer) {
        textField.borderStyle = .none
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2 , width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        textField.layer.addSublayer(bottomLine)
    }
    
    func getUserBalance() {
        balanceInGel = defaults.double(forKey: userDefaultKeyNames.GEL.rawValue)
        balanceInUsd = defaults.double(forKey: userDefaultKeyNames.USD.rawValue)
        balanceInEur = defaults.double(forKey: userDefaultKeyNames.EUR.rawValue)
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
    
    func getFromCurrencyBalance() -> Double? {
        switch fromTextField.text {
        case "GEL":
            return balanceInGel
        case "USD":
            return balanceInUsd
        case "EUR":
            return balanceInEur
        default:
            return nil
        }
    }
    
    func getToCurrencyBalance() -> Double? {
        switch toTextField.text {
        case "GEL":
            return balanceInGel
        case "USD":
            return balanceInUsd
        case "EUR":
            return balanceInEur
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
            
            guard let fromCurrencyBalance = getFromCurrencyBalance() else { return }
            guard let toCurrencyBalance = getToCurrencyBalance() else { return }
            
            if fromCurrencyBalance >= sellAmount {
                
                guard let fromBalanceKeyInFirestore = fromTextField.text else { return }
                guard let toBalanceKeyinFirestore = toTextField.text else { return }
                
                guard  let userUID = Auth.auth().currentUser?.uid else { return }
                
                Firestore.firestore().collection("users").document(userUID).getDocument { [weak self] snapshot, error in
                    
                    if error == nil {
                        
                        snapshot?.reference.updateData([fromBalanceKeyInFirestore: "\(round( (fromCurrencyBalance - sellAmount) * 100) / 100 )"])
                        snapshot?.reference.updateData([toBalanceKeyinFirestore: "\(round ( (toCurrencyBalance + buyAmount) * 100 ) / 100)"])
                        
                        self?.updateUserDefaultValuesForBalance(key1: fromBalanceKeyInFirestore, value1: fromCurrencyBalance - sellAmount, key2: toBalanceKeyinFirestore, value2: toCurrencyBalance + buyAmount)
                        
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
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
        // if value becomes zero
        guard let sellAmount = Double(sellTextField.text ?? "") else {
            buyTextField.text = ""
            return
        }
        
        buyTextField.text = "\(round(sellAmount * desiredCurrency * 100.0) / 100.0)"
    }
    
    private func setSellAmount() {
        guard let desiredCurrency = returnDesiredCurrency() else { return }
        guard let buyAmount = Double(buyTextField.text ?? "") else {
            sellTextField.text = ""
            return
        }
        
        sellTextField.text = "\(round(buyAmount / desiredCurrency * 100.0) / 100.0)"
    }
    
    private func updateUserDefaultValuesForBalance(key1: String, value1: Double, key2: String, value2: Double) {
        defaults.set(value1, forKey:key1)
        defaults.set(value2, forKey: key2)
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
            
            if fromTextField.text == toTextField.text {
                toTextField.text = ""
                balanceForToLbl.text = ""
                
            }
            balanceForFromLbl.text = "\(defaults.double(forKey:availableCurrencies[row]))"
        case 1:
            toTextField.text = availableCurrencies[row]
            toTextField.resignFirstResponder()
            
            if fromTextField.text == toTextField.text {
                fromTextField.text = ""
                balanceForFromLbl.text = ""
            }
            balanceForToLbl.text = "\(defaults.double(forKey:availableCurrencies[row]))"

        default:
            print("Error occured")
        }
    }
}

extension UITextField {
    func setUpRightViewImage(image: UIImage) {
        self.rightViewMode = .always
        
        let rightView = UIImageView()
        let imageView = UIImageView(frame: CGRect(x: -15, y: 0, width: 15, height: 8))
        
        imageView.image = image
        rightView.addSubview(imageView)
        rightView.tintColor = .lightGray
        
        self.rightView = rightView
    }
}
