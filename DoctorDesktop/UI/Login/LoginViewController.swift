//
//  Login.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/3/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import Alamofire
import Stuff
import Toastlity
import NVActivityIndicatorView

class LoginViewController: UIViewController, NVActivityIndicatorViewable {
  
  private var presenter: LoginPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?
  lazy var toastBar: ToastBar = .init(settings: .agent, in: parent?.view)

  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var passWord: UITextField!
  @IBOutlet weak var loginBtn: UIButton!
  @IBOutlet weak var userName: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loginView.layer.cornerRadius = 20
    self.loginView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    self.loginView.layer.borderWidth = 1
    self.loginBtn.layer.cornerRadius = 20
    
    userName.text = "KHABEER"
    passWord.text = "920250270"
  }
  
  func configure(with presenter: LoginPresenter,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }
  
  @IBAction func loginPress(_ sender: Any) {
      guard let username = self.userName.text else {
          self.toastBar.show(with: "Please Enter UserName")
          return
      }
      if username.isEmpty {
          self.toastBar.show(with: "Please Enter UserName")
          return
      }
     guard let password = self.passWord.text else {
         self.toastBar.show(with: "Please Enter Password")
         return }
      if password.isEmpty {
          self.toastBar.show(with: "Please Enter Password")
          return
      }
    startAnimating(message: "Login...")
    let params = ["USER_ID":username, "USERPASSWORD":password]
    presenter.login(with: params) { [weak self] in
      self?.stopAnimating()
        if self?.presenter.error != "" {
            self?.toastBar.show(with: self?.presenter.error ?? "")
        }else {
            let args = ["components": self?.presenter.components ?? [],
                        "user": self?.presenter.user ?? .init()] as [String : Any]
              print(self?.presenter.user ?? .init())
              
            self?.navigationCoordinator?.next(arguments: args)
        }
     
    }
  }
  
}
