//
//  TransferToSomeoneViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 14.09.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TransferToSomeoneViewController: UIViewController {
    
    @IBOutlet private weak var transferFromTextField: UITextField!
    @IBOutlet private weak var transferAmountTextField: UITextField!
    @IBOutlet private weak var receiversIbanTextField: UITextField!
    @IBOutlet private weak var receiverUiView: UIView!
    @IBOutlet private weak var receiversUsernameLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var currencyImageView: UIImageView!
    
    let transferFromTextFieldBottomLine = CALayer()
    let transferAmountTextFieldBottomLine = CALayer()
    let receiversIbanBottomLine = CALayer()
    let transferFromUiPicker = UIPickerView()
    
    var availableCurrencies = ["GEL", "USD", "EUR"]
    var receiversDataSnapshot: DocumentSnapshot?
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideReceiverView()
        setUpTextFields()
        setUpPicker()
    }
    
    // MARK: private functions
    
    private func setUpTextFields() {
        setUpTextFieldBottomLine(textField: transferFromTextField, bottomLine: transferFromTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: transferAmountTextField, bottomLine: transferAmountTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: receiversIbanTextField, bottomLine: receiversIbanBottomLine)
        
        guard let chevronDonwImage = UIImage(systemName: "chevron.down") else { return }
        
        transferFromTextField.setUpRightViewImage(image: chevronDonwImage)
    }
    
    private func setUpTextFieldBottomLine(textField: UITextField, bottomLine: CALayer) {
        
        print(textField.frame.width)
        
        textField.borderStyle = .none
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1 , width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        textField.layer.addSublayer(bottomLine)
        textField.clipsToBounds = true
        
    }
    
    private func setUpPicker() {
        transferFromTextField.inputView = transferFromUiPicker
        transferFromUiPicker.delegate = self
        transferFromUiPicker.delegate = self
        transferFromUiPicker.tag = 0
    }
    
    private func hideReceiverView() {
        receiverUiView.alpha = 0
    }

    @IBAction func checkTapped(_ sender: UIButton) {
        guard let receiversId = receiversIbanTextField.text else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if  validateForEmptiness(textField: receiversId) && checkIbanSimilarity(receiversIbanText: receiversId, currentUsersIbanText: currentUserId) {
            Task {
                do {
                    guard let _ = try await getReceiversDataSnapshot(id: receiversId) else { return }
                    print("VALIDATION SUCCEEDEED")
                } catch {
                    showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.generalError)
                }
            }
        }
    }
    
    @IBAction func transferButtonTapped(_ sender: UIButton) {
        guard let receiversId = receiversIbanTextField.text else { return }
        guard let transferCurrency = transferFromTextField.text else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let transferAmount = transferAmountTextField.text else { return }
        
        if validateForEmptiness(textField: receiversId) && validateForEmptiness(textField: transferCurrency) && validateForEmptiness(textField: transferAmount) {
            if checkIbanSimilarity(receiversIbanText: receiversId, currentUsersIbanText: currentUserId) {
                requestTransaction(fromUser: currentUserId , toUser: receiversId, currency: transferCurrency, amount: transferAmount)
            }
        }
    }
    
    private func getReceiversDataSnapshot(id: String) async throws -> DocumentSnapshot? {
        let snapshot =  try await Firestore.firestore().collection("users").document(id).getDocument()
        
        guard let snapshotData = snapshot.data()  else {
            hideReceiverView()
            showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.incorrectIbanCode)
            return nil
        }
        
        let userData = UserInfo.init(with: snapshotData)
        showReceiver(username: userData.username)
        
        return snapshot
    }
    
    private func getUserDataSnapshot(id: String) async throws -> DocumentSnapshot? {
       try await Firestore.firestore().collection("users").document(id).getDocument()
    }
    
    private func validateForEmptiness(textField: String) -> Bool {
        if textField.isEmpty {
            showAlertWithOkButton(title: nil, message: "Please fill required fields")
            
            return false
        }
        
        return true
    }
    
    private func checkIbanSimilarity(receiversIbanText: String, currentUsersIbanText: String) -> Bool {
        if receiversIbanText == currentUsersIbanText {
            showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.ownIbanCodeEntered)
            
            return false
        }
        
        return true
    }
    
    private func validateBalance(userBalance: Double, receiverBalance: Double) -> Bool {
        if userBalance < receiverBalance {
            showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.notEnoughMoney)
            
            return false
        }
        
        return true
    }
    
    private func requestTransaction(fromUser: String, toUser: String, currency: String, amount: String) {
        
        Task {
            do {
                
                guard let transferAmount = Double(amount) else { return }
                
                guard let receiversSnapshot = try await getReceiversDataSnapshot(id: toUser) else  { return }
                guard let receiversData = receiversSnapshot.data() else { return }
                let receiversBalance = Double(receiversData[currency] as? String ?? "") ?? 0.00
                
                
                guard let currentUserSnapshot = try await getUserDataSnapshot(id: fromUser) else { return }
                guard let currentUserData = currentUserSnapshot.data() else { return }
                let currentUsersBalance = Double(currentUserData[currency] as? String ?? "") ?? 0.00
                
                if !validateBalance(userBalance: currentUsersBalance, receiverBalance: transferAmount) {
                    throw TransactionError.notEnoughBalance
                }
                
                let currencyKeyForUserDefaults = Helper.returnUserDefaultsKey(forText: currency)
                let currrencyKeyForFirebase = Helper.returnFirebaseKey(forText: currency)
                        
                try await receiversSnapshot.reference.updateData([currrencyKeyForFirebase: "\(round( (receiversBalance + transferAmount ) * 100.0 ) / 100.0)"])
                try await currentUserSnapshot.reference.updateData([currrencyKeyForFirebase: "\(round( (currentUsersBalance - transferAmount ) * 100.0 ) / 100.0)"])
                
                defaults.removeObject(forKey: currencyKeyForUserDefaults)
                defaults.set(currentUsersBalance - transferAmount, forKey: currencyKeyForUserDefaults)
                
                dismiss(animated: true)
                showAlertWithOkButton(title: nil, message: Constants.SuccessMessages.TransferSuccess.successfullTransfer)
            } catch {
                    showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.transactionProccessFailed )
            }
        }
    }
    
    private func setCurrencyImage(currency: String) {
        switch currency {
        case "GEL":
            currencyImageView.image = UIImage(systemName: "larisign.circle")
        case "USD":
            currencyImageView.image = UIImage(systemName: "dollarsign.circle")
        case "EUR":
            currencyImageView.image = UIImage(systemName: "eurosign.circle")
        default:
            print("Did not assign any image")
        }
        
    }
    
    func showReceiver(username: String) {
        DispatchQueue.main.async { [weak self] in
            self?.receiversUsernameLabel.text = username
            self?.receiverUiView.alpha = 1
        }
    }
}

extension TransferToSomeoneViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        availableCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableCurrencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        transferFromTextField.text = availableCurrencies[row]
        balanceLabel.text = defaults.string(forKey: Helper.returnUserDefaultsKey(forText: availableCurrencies[row]))
        setCurrencyImage(currency: availableCurrencies[row])
        transferFromTextField.resignFirstResponder()
    }
}
