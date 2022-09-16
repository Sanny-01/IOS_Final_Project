//
//  LogInPageVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 31.07.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInPageVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var networService = NetworkService.shared
    
    var countryCurrency = ["EUR", "USD", "GBP"]
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    
    var exchangeRate = [String]()
    
    var emptyFields = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    func setUpRootViewController() {
        let controller = LogInPageVC()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }
    @IBAction func signUpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInVc = storyboard.instantiateViewController(withIdentifier: "sign_up_VC")
        self.navigationController?.pushViewController(logInVc, animated: true)
    }
    
    //    func setUpTextFields() {
    //        emailTextField.removeAutoCapitalizeAndCorrection()
    //        passwordTextField.removeAutoCapitalizeAndCorrection()
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func logInTapped(_ sender: UIButton) {
        emptyFields = 0
        
        if validateFields() {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] (result, error ) in
                
                if error  != nil {
                    self?.showAlertWithOkButton(title: nil, message: "Email or password is incorrect. Please, try again.")
                } else {
                    
                    let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "home_page_vc") as? HomePageVC
                    guard let homeVC = homeVC else { return }
//
//                    Task {
//                        do {
//                        } catch {
//                            print("Could not load user balance")
//                        }
//                    }
                    
                    Task {
                        do {
                            try await self?.setUserDefaultValues()
                            
                            let gelToUsd = try await NetworkService().fetchExchangeRate(to: "GEL", from: "USD", amount: 1.00, decodingType: CurrencyAmount.self)
                            let gelToEur = try await NetworkService().fetchExchangeRate(to: "GEL", from: "EUR", amount: 1.00, decodingType: CurrencyAmount.self)
                            let gelToGbp = try await NetworkService().fetchExchangeRate(to: "GEL", from: "GBP", amount: 1.00, decodingType: CurrencyAmount.self)
                            let usdToEur = try await NetworkService().fetchExchangeRate(to: "USD", from: "EUR", amount: 1.00, decodingType: CurrencyAmount.self)
                            
                            // If new API did not give us new data old core data will not be erased and will be used for current user
                            self?.deleteExchangeCoreData()
                            self?.setExchangeValues(gelToUsd: gelToUsd.result, gelToEur: gelToEur.result, gelToGbp: gelToGbp.result, usdToEur: usdToEur.result)
                        } catch {
                            print(error)
                        }
                        DispatchQueue.main.async { [weak self] in
                            self?.navigationController?.pushViewController(homeVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func setUserDefaultValues() async throws {
        guard  let userUID = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await Firestore.firestore().collection("users").document(userUID).getDocument()
        guard let snapshotData = snapshot.data()  else { return }
        let userData = UserInfo.init(with: snapshotData)
        
        let defaults = UserDefaults.standard
        
        defaults.set(userData.username, forKey: userDefaultKeyNames.username.rawValue)
        defaults.set(userData.email, forKey: userDefaultKeyNames.email.rawValue)
        defaults.set(userData.id, forKey: userDefaultKeyNames.userId.rawValue)
        
        defaults.set(userData.GEL, forKey: userDefaultKeyNames.GEL.rawValue)
        defaults.set(userData.USD, forKey: userDefaultKeyNames.USD.rawValue)
        defaults.set(userData.EUR, forKey: userDefaultKeyNames.EUR.rawValue)
    }
    
    func deleteExchangeCoreData() {
        do {
            let fetchedExchangeRates = try context.fetch(ExchangeRates.fetchRequest())
            
            fetchedExchangeRates.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Could not load and delete data")
        }
    }
    
    func setExchangeValues(gelToUsd: Double, gelToEur: Double, gelToGbp : Double, usdToEur: Double) {
        
        let newItems = ExchangeRates(context: context)
        
        newItems.gelToUsd = gelToUsd
        newItems.gelToEur = gelToEur
        newItems.gelToGbp = gelToGbp
        newItems.usdToEur = usdToEur
        
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    func validateFields() -> Bool {
        
        emptyFields += emailTextField.validateForEmptiness(errorLabel: emailLabel)
        emptyFields += passwordTextField.validateForEmptiness(errorLabel: passwordLabel)
        
        if emptyFields != 0 {
            return false
        }
        
        return true
    }
    
    func validateForEmptiness(field: UITextField, errorLabel: UILabel) {
        let textFieldText = field.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // if textfield is empty
        if textFieldText == "" {
            errorLabel.alpha = 1
            errorLabel.text = Constants.emptyFieldErrorMessage
            emptyFields += 1
        } else {
            // if textfield is not empty check that there is no passwords do not match error
            if errorLabel.text != Constants.passwordsDoNotMatchMessage {
                errorLabel.alpha = 0
            }
        }
    }
}
