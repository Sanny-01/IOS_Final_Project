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
    // MARK: - Outlets
    
    @IBOutlet private weak var transferFromTextField: UITextField!
    @IBOutlet private weak var transferAmountTextField: UITextField!
    @IBOutlet private weak var receiversIbanTextField: UITextField!
    @IBOutlet private weak var receiverUiView: UIView!
    @IBOutlet private weak var receiversUsernameLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var currencyImageView: UIImageView!
    
    // MARK: - Fields
    
    var balanceInGel = 0.00
    var balanceInUsd = 0.00
    var balanceInEur = 0.00
    
    let transferFromTextFieldBottomLine = CALayer()
    let transferAmountTextFieldBottomLine = CALayer()
    let receiversIbanBottomLine = CALayer()
    let transferFromUiPicker = UIPickerView()
    
    var availableCurrencies = ["GEL", "USD", "EUR"]
    var receiversDataSnapshot: DocumentSnapshot?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserBalance()
        hideReceiverView()
        setUpTextFields()
        setUpPicker()
    }
    
    // MARK: - Private Methods
    
    private func getUserBalance() {
        guard  let userId = Auth.auth().currentUser?.uid else { return }
        
        
        Firestore.firestore().collection("users").document(userId).getDocument { [weak self ] (snapshot, error) in
            
            if error == nil {
                guard let snapshotData = snapshot?.data()  else { return }
                
                let userData = UserBalance.init(with: snapshotData)
                
                self?.balanceInGel = userData.GEL
                self?.balanceInUsd = userData.USD
                self?.balanceInEur = userData.EUR
            } else {
                AlertWorker.showAlertWithOkButtonAndDismissPage(title: nil, message: Constants.ErrorMessages.TransferErrors.couldNotGetExchangeRates, forViewController: self ?? TransferToSomeoneViewController())
            }
        }
    }
    
    private func setUpTextFields() {
        setUpTextFieldBottomLine(textField: transferFromTextField, bottomLine: transferFromTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: transferAmountTextField, bottomLine: transferAmountTextFieldBottomLine)
        setUpTextFieldBottomLine(textField: receiversIbanTextField, bottomLine: receiversIbanBottomLine)
        
        guard let chevronDonwImage = UIImage(systemName: "chevron.down") else { return }
        
        transferFromTextField.setUpRightViewImage(image: chevronDonwImage)
    }
    
    private func setUpTextFieldBottomLine(textField: UITextField, bottomLine: CALayer) {
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
    
    private func getReceiversDataSnapshot(id: String) async throws -> DocumentSnapshot? {
        let snapshot =  try await Firestore.firestore().collection("users").document(id).getDocument()
        
        guard let snapshotData = snapshot.data()  else {
            hideReceiverView()
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.incorrectIbanCode, forViewController: self)
            return nil
        }
        
        let userData = UserCredentials.init(with: snapshotData)
        showReceiver(username: userData.username)
        
        return snapshot
    }
    
    private func getUserDataSnapshot(id: String) async throws -> DocumentSnapshot? {
       try await Firestore.firestore().collection("users").document(id).getDocument()
    }
    
    private func validateForEmptiness(textField: String) -> Bool {
        if textField.isEmpty {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.fillRequiredFields, forViewController: self)
            
            return false
        }
        
        return true
    }
    
    private func checkIbanSimilarity(receiversIbanText: String, currentUsersIbanText: String) -> Bool {
        if receiversIbanText == currentUsersIbanText {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.ownIbanCodeEntered, forViewController: self)
            
            return false
        }
        
        return true
    }
    
    private func validateBalance(userBalance: Double, receiverBalance: Double) -> Bool {
        if userBalance < receiverBalance {
            AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.notEnoughMoney, forViewController: self)
            
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
                guard let receiversBalance = receiversData[currency] as? Double else {
                    AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.transactionProccessFailed, forViewController: self)
                    return
                }
                
                guard let currentUserSnapshot = try await getUserDataSnapshot(id: fromUser) else { return }
                guard let currentUserData = currentUserSnapshot.data() else { return }
                guard let currentUsersBalance = currentUserData[currency] as? Double  else {
                    AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.transactionProccessFailed, forViewController: self)
                    return
                }
                
                if validateBalance(userBalance: currentUsersBalance, receiverBalance: transferAmount) {
                    let currrencyKeyForFirebase = Helper.returnFirebaseKey(forText: currency)
                            
                    try await receiversSnapshot.reference.updateData([currrencyKeyForFirebase: (round( (receiversBalance + transferAmount) * 100.00 ) / 100.00) ])
                    try await currentUserSnapshot.reference.updateData([currrencyKeyForFirebase: (round( (currentUsersBalance - transferAmount) * 100.00 ) / 100.00) ])
                    
                    AlertWorker.showAlertWithOkButtonAndDismissPage(title: nil, message: Constants.SuccessMessages.TransferSuccess.successfullTransfer, forViewController: self)
                }
            } catch {
                AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.transactionProccessFailed, forViewController: self )
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
    
    private func getSendersBalance() -> Double? {
        switch transferFromTextField.text {
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
    
    // MARK: - Actions

    @IBAction func checkTapped(_ sender: UIButton) {
        guard let receiversId = receiversIbanTextField.text else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if validateForEmptiness(textField: receiversId) && checkIbanSimilarity(receiversIbanText: receiversId, currentUsersIbanText: currentUserId) {
            Task {
                do {
                    guard let _ = try await getReceiversDataSnapshot(id: receiversId) else { return }                } catch {
                    AlertWorker.showAlertWithOkButton(title: nil, message: Constants.ErrorMessages.TransferErrors.generalError, forViewController: self)
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
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

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
        balanceLabel.text = "\(getSendersBalance() ?? 0.00)"
        setCurrencyImage(currency: availableCurrencies[row])
        transferFromTextField.resignFirstResponder()
    }
}
