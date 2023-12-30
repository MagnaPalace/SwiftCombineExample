//
//  AddUserViewController.swift
//  SwiftAsyncExample
//
//  Created by Takeshi Kayahashi on 2022/05/23.
//

import UIKit
import Combine

class AddUserViewController: UIViewController {

    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var commentTextField: UITextField!
    
    weak var delegate: AddUserViewControllerDelegate?
    
    private let viewModel =  AddUserViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = String.Localize.addUserViewTitle.text
        
        userIdTextField.delegate = self
        nameTextField.delegate = self
        commentTextField.delegate = self
        
        self.setNumberKeyboardDoneButton()
        
        self.viewModel.delegate = self
        
        self.bind()
    }
    
    func bind() {
        self.viewModel.$isSuccess
            .receive(on: DispatchQueue.main)
            .sink { isSuccess in
                if isSuccess {
                    self.delegate?.didEndAddUser()
                }
            }.store(in: &cancellables)
        
        self.viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                isLoading ? IndicatorView.shared.startIndicator() : IndicatorView.shared.stopIndicator()
            }
            .store(in: &cancellables)
    }

    @IBAction func addUserButtonTapped(_ sender: Any) {
        guard userIdTextField.text?.count ?? 0 > 0, nameTextField.text?.count ?? 0 > 0, commentTextField.text?.count ?? 0 > 0 else {
            self.notCompletedInputFieldAlert()
            return
        }
        self.viewModel.addUserCombine(userId: userIdTextField.text!, name: nameTextField.text!, comment: commentTextField.text!)
    }
    
    /// ナンバーキーボードに完了ボタン追加
    private func setNumberKeyboardDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneButtonTapped(_:)))
        toolBar.items = [spacer, doneButton]
        userIdTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        userIdTextField.resignFirstResponder()
    }
    
    private func storeUserApiFailedAlert() {
        let alert = UIAlertController(title: String.Localize.errorAlertTitle.text, message: String.Localize.networkCommunicationFailedMessage.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String.Localize.closeAlertButtonTitle.text, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addUserFailedAlert() {
        let alert = UIAlertController(title: String.Localize.errorAlertTitle.text, message: String.Localize.addUserFailedMessage.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String.Localize.closeAlertButtonTitle.text, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func notCompletedInputFieldAlert() {
        let alert = UIAlertController(title: String.Localize.confirmAlertTitle.text, message: String.Localize.notCompletedInputFieldMessage.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String.Localize.closeAlertButtonTitle.text, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension AddUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

extension AddUserViewController: AddUserViewModelDelegate {
    
//    func didSuccessAddUserApi() {
//        DispatchQueue.main.async{
//            self.navigationController?.popViewController(animated: true)
//        }
//        self.delegate?.didEndAddUser()
//    }
    
    func addUserApiFailed() {
        self.addUserFailedAlert()
    }
    
}

protocol AddUserViewControllerDelegate: AnyObject {
    func didEndAddUser()
}
