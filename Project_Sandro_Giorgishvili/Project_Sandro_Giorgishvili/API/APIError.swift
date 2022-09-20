//
//  APIError.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 04.09.22.
//

import Foundation

enum ApiError: Error {
    case invalidUrl
    case httpError
    case decodingError
}
