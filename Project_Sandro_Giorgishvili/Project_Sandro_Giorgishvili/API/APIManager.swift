//
//  APIManager.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 17.09.22.
//

import Foundation

final class APIManager {
    func fetchExchangeRate<T: Decodable>(to: String, from: String, amount: Double, decodingType: T.Type) async throws -> T {
        
        let baseUrl = "https://api.apilayer.com/exchangerates_data/convert?"
        let apiKey = "3kJamQMdmqGI76HLOM6zGxWvOSgwWXnx"
//        let apiKey = "1"
        
        var urlComponent = URLComponents(string: baseUrl)
        
        urlComponent?.queryItems =  [
            URLQueryItem(name: "to", value: "\(to)"),
            URLQueryItem(name: "from", value: "\(from)"),
            URLQueryItem(name: "amount", value: "\(amount)")
            
        ]
        
        var request = URLRequest(url: (urlComponent?.url!)!)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
        let session = URLSession.shared
        
        let urlString = "\(request)"
        guard URL(string: urlString) != nil else { throw ApiError.invalidUrl }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else { throw ApiError.httpError }
        
        do {
           return try JSONDecoder().decode(decodingType.self, from: data)
        } catch {
            throw ApiError.decodingError
        }
    }
}
