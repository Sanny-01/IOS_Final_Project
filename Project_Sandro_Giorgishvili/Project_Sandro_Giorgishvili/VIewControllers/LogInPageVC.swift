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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
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
        
        let checkError =  validateFields()
        
        if checkError != nil {
            
        } else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] (result, error ) in
                
                if error  != nil {
                    self?.showAlertWithOkButton(title: nil, message: "Email or password is incorrect. Please, try again.")
                } else {
                    
                    self?.setUserDefaultValues()
                    
                    let storyboard = UIStoryboard(name: "HomePageBoard", bundle: nil)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "home_page_vc") as? HomePageVC
                    guard let homeVC = homeVC else { return }
                    
                    Task {
                        do {
                            let gelToUsd = try await NetworkService().fetchData(to: "GEL", from: "USD", amount: 1.00, decodingType: CurrencyAmount.self)
                            let gelToEur = try await NetworkService().fetchData(to: "GEL", from: "EUR", amount: 1.00, decodingType: CurrencyAmount.self)
                            let gelToGbp = try await NetworkService().fetchData(to: "GEL", from: "GBP", amount: 1.00, decodingType: CurrencyAmount.self)
                            let usdToEur = try await NetworkService().fetchData(to: "USD", from: "EUR", amount: 1.00, decodingType: CurrencyAmount.self)
                            
                            print(gelToUsd)
                            print(gelToEur)
                            print(gelToGbp)
                            
                            self?.setExchangeValues(gelToUsd: gelToUsd.result, gelToEur: gelToEur.result, gelToGbp: gelToGbp.result, usdToEur: usdToEur.result)
                            
                            print("GOTTEN ALL VALUES !!!!!!!!!")
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
    
    func setUserDefaultValues() {
        guard  let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userUID).getDocument { snapshot, error in
            if error == nil {
                guard let snapshot = snapshot?.data()  else { return }
                let userData = UserInfo.init(with: snapshot)
                
                let defaults = UserDefaults.standard
                
                defaults.set(userData.username, forKey: userDefaultKeyNames.username.rawValue)
                defaults.set(userData.email, forKey: userDefaultKeyNames.email.rawValue)
                defaults.set(userData.id, forKey: userDefaultKeyNames.userId.rawValue)
                
                defaults.set(userData.GEL, forKey: userDefaultKeyNames.GEL.rawValue)
                defaults.set(userData.USD, forKey: userDefaultKeyNames.USD.rawValue)
                defaults.set(userData.EUR, forKey: userDefaultKeyNames.EUR.rawValue)
                
            } else {
                print("Error appeared while getting user info")
            }
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
    
    func validateFields() -> String? {
        
        emptyFields += emailTextField.validateForEmptiness(errorLabel: emailLabel)
        emptyFields += passwordTextField.validateForEmptiness(errorLabel: passwordLabel)
        
        if emptyFields != 0 {
            return "Empty field found"
        }
        
        return nil
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
