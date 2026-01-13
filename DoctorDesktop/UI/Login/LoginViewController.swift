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
import NVActivityIndicatorView

class LoginViewController: UIViewController, NVActivityIndicatorViewable {
  
  private var presenter: LoginPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?
  
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
    
    userName.text = "khabeer"
    passWord.text = "920250270"
  }
  
  func configure(with presenter: LoginPresenter,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }
  
  @IBAction func loginPress(_ sender: Any) {
    guard let username = self.userName.text,
      let password = self.passWord.text else { return }
    startAnimating(message: "Login...")
    let params = ["USER_ID":username, "USERPASSWORD":password]
    presenter.login(with: params) { [weak self] in
      self?.stopAnimating()
      let args = ["components": self!.presenter.components, "user": self!.presenter.user] as [String : Any]
        print(self?.presenter.user)
        
      self?.navigationCoordinator?.next(arguments: args)
    }
  }
  
}
