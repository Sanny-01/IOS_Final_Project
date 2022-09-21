//
//  ProfileVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 08.09.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    // MARK: - Outlests
    
    @IBOutlet private weak var profileSettingsTableView: UITableView!
    @IBOutlet private weak var signOutButton: UIButton!
    
    // MARK: - Fields
    
    var iconImageNames = ["person.fill", "envelope.fill", "lock.fill"]
    var settingNames = [String]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeElementCornersRounded()
        setUpDelegates()
        getUserData()
    }
    
    // MARK: - Private Methods
    
    private func makeElementCornersRounded() {
        signOutButton.layer.cornerRadius = 20
    }
    
    private func setUpDelegates() {
        profileSettingsTableView.delegate = self
        profileSettingsTableView.dataSource = self
    }
    
    private func getUserData() {
        guard  let userId = Auth.auth().currentUser?.uid else { return }

        
        Firestore.firestore().collection("users").document(userId).getDocument { [weak self ] (snapshot, error) in
            
            if error == nil {
                guard let snapshotData = snapshot?.data()  else { return }
                
                let userData = UserCredentials.init(with: snapshotData)
                
                self?.settingNames.append(userData.username)
                self?.settingNames.append(userData.email)
                self?.settingNames.append("Change Password")
                
                self?.profileSettingsTableView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        let auth = Auth.auth()
        
        do {
            try auth.signOut()
            
            let storyboard = UIStoryboard(name: Constants.StoryBoards.login, bundle: nil)
            guard let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.loginViewController) as? LoginViewController else { return }
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            guard let window = windowScene?.windows.first else { return }
            let navigationController = UINavigationController(rootViewController: loginViewController)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        } catch let signOutError {
            AlertWorker.showAlertWithOkButton(title: nil, message: signOutError.localizedDescription, forViewController: self)
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileSettingsTableView.dequeueReusableCell(withIdentifier: "ProfileSettingsCell", for: indexPath) as! ProfileSettingsCell
        cell.settingIconImage.image = UIImage(systemName: iconImageNames[indexPath.row])
        cell.settingNameLbl.text = settingNames[indexPath.row]
        
        if indexPath.row == 0 || indexPath.row == 1 {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileSettingsTableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: Constants.StoryBoards.passwordChange, bundle: nil)
        guard let passwordChangeViewController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.passwordChangeViewController) as? PasswordChangeViewController else { return }
        
        navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
}
