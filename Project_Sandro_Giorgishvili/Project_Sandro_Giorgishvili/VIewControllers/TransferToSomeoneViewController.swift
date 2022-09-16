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
    @IBOutlet weak var receiversIbanTextField: UITextField!
    
    @IBOutlet weak var receiverUiView: UIView!
    @IBOutlet weak var receiversUsernameLabel: UILabel!
    
    
    let transferFromTextFieldBottomLine = CALayer()
    let transferAmountTextFieldBottomLine = CALayer()
    let receiversIbanBottomLine = CALayer()
    
    let transferFromUiPicker = UIPickerView()
    
    var availableCurrencies = ["GEL", "USD", "EUR"]
    
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
        guard let transferCurrency = transferFromTextField.text else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // move emptiness check to transfer button tap !!!!!
        if validateForEmptiness(receiversId: receiversId, transferCurrency: transferCurrency)  && checkIbanSimilarity(receiversIbanText: receiversId, currentUsersIbanText: currentUserId) {
            Task {
                do {
                    
                    guard let receiversDataSnapshot = try await getReceiversDataSnapshot(id: receiversId) else { return }
//                    guard let receiversData = receiversDataSnapshot.data() else { return }
//                    var receiversBalance: Double = 0.00
//
//                    guard let currentUserDataSnapshot = try await getUserDataSnapshot(id: currentUserId) else { return }
//                    guard let currentUserData = currentUserDataSnapshot.data() else { return }
//                    var currentUsersBalance: Double = 0.00
//
//                    switch transferCurrency {
//                    case firebaseDataKeys.balanceInGel.rawValue:
//                        receiversBalance = receiversData[firebaseDataKeys.balanceInGel.rawValue] as? Double ?? 0.00
//                        currentUsersBalance = currentUserData[firebaseDataKeys.balanceInGel.rawValue] as? Double ?? 0.00
//                    case firebaseDataKeys.balanceInUsd.rawValue:
//                        receiversBalance = receiversData[firebaseDataKeys.balanceInUsd.rawValue] as? Double ?? 0.00
//                        currentUsersBalance = currentUserData[firebaseDataKeys.balanceInUsd.rawValue] as? Double ?? 0.00
//                    case firebaseDataKeys.balanceInUsd.rawValue:
//                        receiversBalance = receiversData[firebaseDataKeys.balanceInEur.rawValue] as? Double ?? 0.00
//                        currentUsersBalance = currentUserData[firebaseDataKeys.balanceInEur.rawValue] as? Double ?? 0.00
//                    default:
//                        print("Error occured")
//                    }
//
//                    if validateBalance(userBalance: currentUsersBalance, receiverBalance: receiversBalance){
//
//                    }
                    
                    print("YESS VALIDATION SUCCEEDEED")
                } catch {
                    print("Error occured")
                }
            }
        }
    }
    
    private func getReceiversDataSnapshot(id: String) async throws -> DocumentSnapshot? {
        let snapshot =  try await Firestore.firestore().collection("users").document(id).getDocument()
        
        guard let snapshotData = snapshot.data()  else {
            hideReceiverView()
            showAlertWithOkButton(title: nil, message: "Could not find a user with given IBAN code")
            return nil
        }
        
        let userData = UserInfo.init(with: snapshotData)
        showReceiver(username: userData.username)
        
        return snapshot
    }
    
    private func getUserDataSnapshot(id: String) async throws -> DocumentSnapshot? {
       try await Firestore.firestore().collection("users").document(id).getDocument()
    }
    
    private func validateForEmptiness(receiversId: String, transferCurrency: String) -> Bool {
        if receiversId.isEmpty || transferCurrency.isEmpty {
            showAlertWithOkButton(title: nil, message: "Please fill all the fields")
            return false
        }
        
        return true
    }
    
    private func checkIbanSimilarity(receiversIbanText: String, currentUsersIbanText: String) -> Bool {
        if receiversIbanText == currentUsersIbanText {
            showAlertWithOkButton(title: nil, message: "You can not add your account as receiver.")
            
            return false
        }
        
        return true
    }
    
    func validateBalance(userBalance: Double, receiverBalance: Double) -> Bool {
        if userBalance < receiverBalance {
            showAlertWithOkButton(title: nil, message: "You do not have enough money on account.")
            return false
        }
        
        return true
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
        transferFromTextField.resignFirstResponder()
    }
}
