//
//  ProfileVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 08.09.22.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileSettingsTableView: UITableView!
    
    let defaults = UserDefaults.standard
    
    var iconImageNames = ["person.fill", "envelope.fill", "lock.fill"]
    var settingNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpArrayOfUserInfo()
        setUpDelegates()
    }
    
    func setUpDelegates() {
        profileSettingsTableView.delegate = self
        profileSettingsTableView.dataSource = self
    }
    
    func setUpArrayOfUserInfo() {
        
        settingNames.append(defaults.string(forKey: userDefaultKeyNames.username.rawValue) ?? "Not found")
        settingNames.append(defaults.string(forKey: userDefaultKeyNames.email.rawValue) ?? "Not found")
        settingNames.append("Change Password")
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        let auth = Auth.auth()
        
        do {
            try auth.signOut()
         
            removeUserDefaults()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVc = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LogInPageVC
            guard let logInVC = logInVc else { return }
            self.navigationController?.pushViewController(logInVC, animated: true)
        } catch let signOutError {
            showAlertWithOkButton(title: nil, message: signOutError.localizedDescription)
        }
    }
    
    func removeUserDefaults() {
        defaults.removeObject(forKey: userDefaultKeyNames.username.rawValue)
        defaults.removeObject(forKey: userDefaultKeyNames.email.rawValue)
        defaults.removeObject(forKey: userDefaultKeyNames.userId.rawValue)
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        iconImageNames.count
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "PasswordChangeBoard", bundle: nil)
        
        let passwordChangeViewController = storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! PasswordChangeViewController
        
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
}
