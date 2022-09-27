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
       let result = try await Auth.auth().createUser(withEmail: userCredentials.email, password: userCredentials.password)
        
        let db = Firestore.firestore()
        
        let gel = Int.random(in: 1...1000)
        let usd = Int.random(in: 1...100)
        let eur = Int.random(in: 1...50)
        
        let data: [String : Any] = [
            UserInformation.firestoreDataKeys.username.rawValue: userCredentials.username,
            UserInformation.firestoreDataKeys.email.rawValue: userCredentials.email,
            UserInformation.firestoreDataKeys.userId.rawValue: result.user.uid,
            UserInformation.firestoreDataKeys.GEL.rawValue: gel,
            UserInformation.firestoreDataKeys.USD.rawValue: usd,
            UserInformation.firestoreDataKeys.EUR.rawValue: eur
        ]
        
        try await db.collection("users").document(result.user.uid).setData(data)
        
        return result
    }
}
