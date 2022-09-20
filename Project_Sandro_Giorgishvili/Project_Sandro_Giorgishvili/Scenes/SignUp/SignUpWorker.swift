//
//  SignUpWorker.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol SignUpWorkerLogic {
    func registerUser(userCredentials: SignUp.RegisterUser.Request) async throws -> AuthDataResult
}

final class SignUpWorker: SignUpWorkerLogic {
    
    
    // MARK: - SignUpWorkerLogic
    
    func registerUser(userCredentials: SignUp.RegisterUser.Request) async throws -> AuthDataResult {
       try await Auth.auth().createUser(withEmail: userCredentials.email, password: userCredentials.password)
    }
}
