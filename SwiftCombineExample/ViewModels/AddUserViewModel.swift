//
//  AddUserViewModel.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/06/02.
//

import Foundation
import Combine

class AddUserViewModel {
    
    @Published private(set) var isSuccess: Bool = false
    @Published private(set) var isLoading: Bool = false
    
    weak var delegate: AddUserViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    func addUser(userId: String, name: String, comment: String) {
        let api = ApiManager()
        let url = URL(string: BASE_URL + API_URL + UserApi.store.rawValue)!
        
        let parameter = [
            User.Key.userId.rawValue: userId,
            User.Key.name.rawValue: name,
            User.Key.comment.rawValue: comment,
        ]

        IndicatorView.shared.startIndicator()
        
        // 通常版リクエスト
//        api.request(param: parameter as [String : Any], url: url) { (success, result, error) in
//            guard success else {
//                IndicatorView.shared.stopIndicator()
//                self.addUserFailedAlert()
//                return
//            }
//            IndicatorView.shared.stopIndicator()
//            self.delegate?.didEndSaveUserAction()
//            DispatchQueue.main.async{
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
        
        // Swift 5.5 Concurrency async/await
        Task {
            do {
                let result = try await api.requestAsync(param: parameter as [String : Any], url: url)
                print(result)
                IndicatorView.shared.stopIndicator()
//                self.delegate?.didSuccessAddUserApi()
            } catch ApiManager.ApiError.httpError(let error) {
                IndicatorView.shared.stopIndicator()
                print("\(error.statusCode) : \(error.message)")
                self.delegate?.addUserApiFailed()
            } catch {
                IndicatorView.shared.stopIndicator()
                print(error.localizedDescription)
                self.delegate?.addUserApiFailed()
            }
        }
    }
    
    func addUserCombine(userId: String, name: String, comment: String) {
        self.isLoading = true
        
        let url = URL(string: BASE_URL + API_URL + UserApi.store.rawValue)!
        
        let parameter = [
            User.Key.userId.rawValue: userId,
            User.Key.name.rawValue: name,
            User.Key.comment.rawValue: comment,
        ]
        
        ApiManager.postRequestCombine(param: parameter, url: url)
            .sink { completion in
                self.isLoading = false
                
                switch completion {
                case let .failure(error):
                    print(error)
                    self.delegate?.addUserApiFailed()
                case .finished:
                    print("finished.")
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // POSTリクエストが成功した場合
                self.isSuccess = true
            }
            .store(in: &cancellables)
    }
    
}

protocol AddUserViewModelDelegate: AnyObject {
//    func didSuccessAddUserApi()
    func addUserApiFailed()
}
