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
    static var shared = NetworkService()
    
    var session = URLSession()
    
    init() {
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        self.session = urlSession
    }
    // TODO: try to add weak self
//    func convertCurrency<T: Decodable>(to: String, from: String, amount: Double, completion: @escaping (T?, Error?)->(Void)) {
//
////        let baseUrl = "https://api.apilayer.com/exchangerates_data/convert?"
////        let apiKey = "1"
//
//        var urlComponent = URLComponents(string: baseUrl)
//
//        urlComponent?.queryItems =  [
//            URLQueryItem(name: "to", value: "\(to)"),
//            URLQueryItem(name: "from", value: "\(from)"),
//            URLQueryItem(name: "amount", value: "\(amount)")
//
//        ]
//
//        var request = URLRequest(url: (urlComponent?.url!)!)
//        request.httpMethod = "GET"
//
//        request.addValue(apiKey, forHTTPHeaderField: "apikey")
//
//        print(request)
//
//        session.dataTask(with: request) { data, response, error in
//
//            if let error = error {
//                print(error.localizedDescription)
//                completion(nil, error)
//            }
//
//            guard let response = response as? HTTPURLResponse else {
//                completion(nil, NetworkError.wrongResponse)
//                return
//            }
//
//            guard (200...299).contains(response.statusCode) else {
//                completion(nil, NetworkError.wrongStatusCode(code: response.statusCode))
//                return
//            }
//
//            guard let data = data else { return }
//
//            do {
//                let decoder = JSONDecoder()
//                let object = try decoder.decode(T.self, from: data)
//
//                DispatchQueue.main.async {
//                    completion(object, nil)
//                }
//            } catch {
//                print("decoding error")
//            }
//        }.resume()
//    }
    
    func fetchExchangeRate<T: Decodable>(to: String, from: String, amount: Double, decodingType: T.Type) async throws -> T {
        
        let baseUrl = "https://api.apilayer.com/exchangerates_data/convert?"
//        let apiKey = "3kJamQMdmqGI76HLOM6zGxWvOSgwWXnx"
        let apiKey = "1"
        
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
