//
//  UserListViewModel.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/22.
//

import Foundation
import UIKit
import Combine

class UserListViewModel {
    
    @Published private(set) var users: [User] = [] // @Publishedを付けたプロパティの値が変わると、Viewの再レンダリングが行われる
    @Published private(set) var isLoading: Bool = false
    
    weak var delegate: UserListViewModelDelegate?

    private var cancellables = Set<AnyCancellable>()

    func fetchUsers() {
        self.isLoading = true
        
        let url = URL(string: BASE_URL + API_URL + UserApi.all.rawValue)!
        ApiManager.getRequestCombine(param: nil, url: url)
            .sink { completion in
                self.isLoading = false
                
                switch completion {
                case let .failure(error):
                    print(error)
                    self.delegate?.getUsersApiFailed()
                case .finished:
                    print("finished.")
                }
            } receiveValue: { [weak self] users in
                guard let self = self else { return }
                self.users = users
            }
            .store(in: &cancellables)
    }
    
}

protocol UserListViewModelDelegate: AnyObject {
//    func dataUpdated()
    func getUsersApiFailed()
}
