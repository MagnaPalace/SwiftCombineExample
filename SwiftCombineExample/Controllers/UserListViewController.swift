//
//  ViewController.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/21.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private let viewModel =  UserListViewModel()
    
    private var cancellables = Set<AnyCancellable>() // 購読キャンセル
    
    private typealias DataSource = UITableViewDiffableDataSource<Int, User>
    private lazy var dataSource = configureDataSource() // Lazy Stored Property(遅延格納プロパティ)
    
    private func configureDataSource() -> DataSource {
        return UITableViewDiffableDataSource(tableView: tableView,
                                             cellProvider: { table, index, user in
            let cell = table.dequeueReusableCell(withIdentifier: "UserListTableViewCell",
                                                 for: index) as? UserListTableViewCell
            cell?.initialize(model: .init(userNo: user.userId, name: user.name, comment: user.comment))
            return cell
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "SwiftCombineExample"
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
        
        self.setNavigationBar()
        
        self.viewModel.delegate = self
        
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.fetchUsers()
    }
    
    func bind() {
        // combine
        self.viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
//                self?.tableView.reloadData()
                var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
                snapshot.appendSections([0])
                snapshot.appendItems(users)
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        // APIリクエスト中の進捗を監視してIndicatorを制御
        self.viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                isLoading ? IndicatorView.shared.startIndicator() : IndicatorView.shared.stopIndicator()
            }
            .store(in: &cancellables)
    }
    
    /// エラーアラート表示
    private func showErrorAlert(with message: String) {
        let alertVC = UIAlertController(title: String.Localize.errorAlertTitle.text, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: String.Localize.closeAlertButtonTitle.text, style: .default))
        present(alertVC, animated: true)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    @objc func addBarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "AddUserViewController", bundle: nil)
        let addUserViewController = storyboard.instantiateViewController(withIdentifier: "AddUserViewController") as! AddUserViewController
        addUserViewController.delegate = self
        self.navigationController?.pushViewController(addUserViewController, animated: true)
    }

}

//extension ViewController: UITableViewDelegate {
//
//}
//
//extension ViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.users.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let user = self.viewModel.users[indexPath.row]
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as? UserListTableViewCell
//        cell?.initialize(model: .init(userNo: user.userId, name: user.name, comment: user.comment))
//        return cell!
//    }
//
//}

extension ViewController: UserListViewModelDelegate {

//    func dataUpdated() {
//        DispatchQueue.main.async{
//            self.tableView.reloadData()
//        }
//    }
    
    func getUsersApiFailed() {
        DispatchQueue.main.async{
            let alert = UIAlertController(title: String.Localize.errorAlertTitle.text, message: String.Localize.networkCommunicationFailedMessage.text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String.Localize.closeAlertButtonTitle.text, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension ViewController: AddUserViewControllerDelegate {
    
    func didEndAddUser() {
//        self.viewModel.fetchUsers()
        self.navigationController?.popViewController(animated: true)
    }
    
}
