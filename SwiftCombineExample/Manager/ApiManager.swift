//
//  ApiManager.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/21.
//

import Foundation
import Combine

struct GetUserResponse: Decodable {
    let users: [User]
}

class ApiManager {
    
    /// APIエラー構造体
    struct HttpResponseError: Error {
        /// ステータスコード
        private (set) var statusCode: Int
        
        /// エラーメッセージ
        private (set) var message: String
    }
    
    /// APIエラー
    enum ApiError: Error {
        case noResponse
        case httpError(HttpResponseError)
    }
    
    private var cancellables: [AnyCancellable] = []
    
    /// 通常版
    func request(param: [String: Any]?, url: URL, completion: @escaping (_ success: Bool, _ result: Any?, _ error: NSError?) -> ()) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        print("-----url-----\n\(url)")
        print("-----param-----\n\(String(describing: param))")
        
        guard let postBody = try? JSONSerialization.data(withJSONObject: param as Any, options: []) else { return }
        request.httpBody = postBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                
                print("-----result-----\n\(result)")
                completion(true, result, error as NSError?)
            } catch let error {
                print(error)
                completion(false, nil, error as NSError)
            }
        }
        task.resume()
    }
    
    /// Swift 5.5 Concurrency async/await
    func requestAsync(param: [String: Any]?, url: URL) async throws -> Any {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        if param != nil {
            let postBody = try? JSONSerialization.data(withJSONObject: param as Any, options: [])
            request.httpBody = postBody
        }
        
        print("-----url-----\n\(url)")
        print("-----param-----\n\(String(describing: param))")
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let httpStatus = urlResponse as? HTTPURLResponse else {
            throw ApiError.noResponse
        }
        print("statusCode: \(httpStatus.statusCode)")
        guard httpStatus.statusCode == 200 else {
            throw ApiError.httpError(HttpResponseError(statusCode: httpStatus.statusCode, message: "\(HTTPURLResponse.localizedString(forStatusCode: httpStatus.statusCode))"))
        }
        
        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        print("-----result-----\n\(result)")
        return result
    }
    
    static func getRequestCombine(param: [String: Any]?, url: URL) -> AnyPublisher<[User], Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        if param != nil {
            let postBody = try? JSONSerialization.data(withJSONObject: param as Any, options: [])
            request.httpBody = postBody
        }
        
        print("-----url-----\n\(url)")
        print("-----param-----\n\(String(describing: param))")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GetUserResponse.self, decoder: JSONDecoder())
//            .print()
            .map(\.users) // usersキーの中の配列を取り出す
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // 末尾に追加することで、CombineチェーンをAnyPublisher型に変換して終了させます。これにより、関連するメソッドやプロパティの型を非公開にでき、外部で変更されないようにすることができます。
    }
    
    static func postRequestCombine(param: [String: Any]?, url: URL) -> AnyPublisher<Data, URLError> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        if param != nil {
            let postBody = try? JSONSerialization.data(withJSONObject: param as Any, options: [])
            request.httpBody = postBody
        }
        
        print("-----url-----\n\(url)")
        print("-----param-----\n\(String(describing: param))")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
