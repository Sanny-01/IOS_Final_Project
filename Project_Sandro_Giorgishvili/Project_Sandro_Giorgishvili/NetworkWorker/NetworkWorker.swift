//
//  NetworkWorker.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 04.09.22.
//

import Foundation

enum NetworkError: Error {
    case wrongResponse
    case wrongStatusCode(code: Int)
}


class NetworkService {
    func fetchExchangeRate<T: Decodable>(to: String, from: String, amount: Double, decodingType: T.Type) async throws -> T {
        
        let baseUrl = "https://api.apilayer.com/exchangerates_data/convert?"
        let apiKey = "FTumYxcUxcYkQKgDyq9GWBmt9CbjOHB5"
        
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
