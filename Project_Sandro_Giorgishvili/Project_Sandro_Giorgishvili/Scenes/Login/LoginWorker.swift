//
//  LoginWorker.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 16.09.22.

import UIKit
import FirebaseAuth

protocol LoginWorkerLogic {
    func authorizeUser(userCredentials: Login.AuthorizeLogin.Request) async throws -> AuthDataResult
}

final class LoginWorker {
    // MARK: - Fields
    
    private var api: APIManager
    
    init(apiManager: APIManager) {
        self.api = apiManager
    }
}

extension LoginWorker: LoginWorkerLogic {
    func authorizeUser(userCredentials: Login.AuthorizeLogin.Request) async throws -> AuthDataResult {
        try await Auth.auth().signIn(withEmail: userCredentials.email, password: userCredentials.password)
    }
}
