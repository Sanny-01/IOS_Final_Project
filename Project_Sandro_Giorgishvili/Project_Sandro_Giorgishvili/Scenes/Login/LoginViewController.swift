//
//  LoginViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 16.09.22.


import UIKit

protocol LoginDisplayLogic: AnyObject {
    func displayEmptyErrorLabels(ViewModel: Login.EmptyErrorLabels.ViewModel)
    func displayRegisterNewUser(ViewModel: Login.ShowRegisterPage.ViewModel)
    func displayEmptyEmail(ViewModel: Login.DisplayErrorLabel.ViewModel)
    func displayEmptyPassword(ViewModel: Login.DisplayErrorLabel.ViewModel)
    func displaySuccessfullLogin(ViewModel: Login.Success.ViewModel)
    func displayLoginFailed(ViewModel: Login.Fail.ViewModel)
}

final class LoginViewController: UIViewController {
    
    // MARK: - Clean Components
    
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?
    
    
    // MARK: - Outlets
    
    @IBOutlet private var backgroundView: UIView!
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    
    
    // MARK: - Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
        hideKeyboardWhenTappedAround()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        let viewController = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        let worker = LoginWorker(apiManager: APIManager())
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        makeElementCornersRounded()
    }
    
    // MARK: - Registration
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        router?.navigateToRegisterNewUsername()
    }
    
    // MARK: - Login
    
    @IBAction func logInTapped(_ sender: UIButton) {
        interactor?.processLogin(request: Login.ProcessLogin.Request(email: emailTextField.text, password: passwordTextField.text))
    }
    
    // MARK: - Private Methods
    
    private func makeElementCornersRounded() {
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
    }
}

// MARK: - LoginDisplayLogic

extension LoginViewController: LoginDisplayLogic {
    func displayLoginFailed(ViewModel: Login.Fail.ViewModel) {
        AlertWorker.showAlertWithOkButton(title: ViewModel.title, message: ViewModel.errorMessage , forViewController: self)
    }
    
    func displayEmptyErrorLabels(ViewModel: Login.EmptyErrorLabels.ViewModel) {
        emailErrorLabel.text = ""
        passwordErrorLabel.text = ""
    }
    
    func displaySuccessfullLogin(ViewModel: Login.Success.ViewModel) {
        router?.navigateToHomeMakingItRootViewController()
    }
    
    func displayEmptyEmail(ViewModel: Login.DisplayErrorLabel.ViewModel) {
        emailErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayEmptyPassword(ViewModel: Login.DisplayErrorLabel.ViewModel) {
        passwordErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayRegisterNewUser(ViewModel: Login.ShowRegisterPage.ViewModel) {
        router?.navigateToRegisterNewUsername()
    }
}
