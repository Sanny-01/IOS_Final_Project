//
//  SignUpViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.

import UIKit

protocol SignUpDisplayLogic: AnyObject {
    func displayEmptyErrorLabels(ViewModel: SignUp.EmptyErrorLabels.ViewModel)
    func displayEmptyEmail(ViewModel: SignUp.DisplayErrorLabel.ViewModel)
    func displayEmptyUsername(ViewModel: SignUp.DisplayErrorLabel.ViewModel)
    func displayEmptyPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel)
    func displayEmptyRepeatPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel)
    func displayPasswordsNotMatch(ViewModel: SignUp.DisplayErrorLabel.ViewModel)
    func displayAlert(ViewModel: SignUp.DisplayAlert.ViewModel)
    func displaySuccessfullRegistration(ViewModel: SignUp.Success.ViewModel)
}

class SignUpViewController: UIViewController {
    // MARK: - Outlests
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var repeatPasswordTextField: UITextField!

    @IBOutlet private weak var usernameErrorLabel: UILabel!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var repeatPasswordErrorLabel: UILabel!
    @IBOutlet private weak var signUpButton: UIButton!
    
    // MARK: - Clean Components
    
    var interactor: SignUpBusinessLogic?
    var router: (NSObjectProtocol & SignUpRoutingLogic)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = SignUpInteractor()
        let presenter = SignUpPresenter()
        let router = SignUpRouter()
        let worker = SignUpWorker()
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
        interactor?.registerNewUser(request: SignUp.Registration.Request(username: usernameTextField.text, email: emailTextField.text, password: passwordTextField.text, repeatPassword: repeatPasswordTextField.text))
    }
    
    // MARK: - Private Methods
    
    private func makeElementCornersRounded() {
        usernameTextField.layer.cornerRadius = 20
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        repeatPasswordTextField.layer.cornerRadius = 20
        signUpButton.layer.cornerRadius = 20
    }
}

// MARK: - SignUpDisplayLogic

extension SignUpViewController: SignUpDisplayLogic {
    func displaySuccessfullRegistration(ViewModel: SignUp.Success.ViewModel) {
        router?.popToHome()
    }
    
    func displayEmptyErrorLabels(ViewModel: SignUp.EmptyErrorLabels.ViewModel) {
        usernameErrorLabel.text = ""
        emailErrorLabel.text = ""
        passwordErrorLabel.text = ""
        repeatPasswordErrorLabel.text = ""
    }
    
    func displayAlert(ViewModel: SignUp.DisplayAlert.ViewModel) {
        AlertWorker.showAlertWithOkButton(title: ViewModel.title, message: ViewModel.errorMessage, forViewController: self)
    }
    
    func displayEmptyEmail(ViewModel: SignUp.DisplayErrorLabel.ViewModel) {
        emailErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayEmptyUsername(ViewModel: SignUp.DisplayErrorLabel.ViewModel) {
        usernameErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayEmptyPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel) {
        passwordErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayEmptyRepeatPassword(ViewModel: SignUp.DisplayErrorLabel.ViewModel) {
        repeatPasswordErrorLabel.text = ViewModel.errorMessage
    }
    
    func displayPasswordsNotMatch(ViewModel: SignUp.DisplayErrorLabel.ViewModel) {
        repeatPasswordErrorLabel.text = ViewModel.errorMessage
    }
}
