//
//  Constants.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 01.08.22.
//

import Foundation

class Constants {
    
    static let emptyFieldErrorMessage = "This field should not be left empty"
    static let passwordsDoNotMatchMessage = "Passwords do not match"
    
    struct Placeholder {
        static let currentPassword = "Current Password"
        static let newPassword = "New Password"
        static let repeatPassword = "Repeat Password"
    }
    
    struct StoryBoard {
        static let homePageVC = "home_page_VC"
    }
    
    static var changed = 0
    
    static var selectedIndex: IndexPath = [1,0]
}
