//
//  LoginViewController.swift
//  FavoritePlaces
//
//  Created by C4Q on 11/20/19.
//  Copyright © 2019 Iram Fattah. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    //MARK: UI Objects
       
       lazy var logoLabel: UILabel = {
              let label = UILabel()
              label.numberOfLines = 0
              label.text = "Fave Spots"
              label.font = UIFont(name: "Verdana-Bold", size: 60)
              label.textColor = UIColor(red: 255/255, green: 86/255, blue: 0/255, alpha: 1.0)
              label.backgroundColor = .clear
              label.textAlignment = .center
              return label
          }()
          
          lazy var emailTextField: UITextField = {
              let textField = UITextField()
              textField.placeholder = "Enter Email"
              textField.font = UIFont(name: "Verdana", size: 14)
              textField.backgroundColor = .white
              textField.borderStyle = .bezel
              textField.autocorrectionType = .no
              textField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
              return textField
          }()
          
          lazy var passwordTextField: UITextField = {
              let textField = UITextField()
              textField.placeholder = "Enter Password"
              textField.font = UIFont(name: "Verdana", size: 14)
              textField.backgroundColor = .white
              textField.borderStyle = .bezel
              textField.autocorrectionType = .no
              textField.isSecureTextEntry = true
              textField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
              return textField
          }()
          
          lazy var loginButton: UIButton = {
              let button = UIButton(type: .system)
              button.setTitle("Login", for: .normal)
              button.setTitleColor(.white, for: .normal)
              button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
              button.backgroundColor = UIColor(red: 255/255, green: 67/255, blue: 0/255, alpha: 1)
              button.layer.cornerRadius = 5
              button.addTarget(self, action: #selector(tryLogin), for: .touchUpInside)
              button.isEnabled = false
              return button
          }()
          
          lazy var createAccountButton: UIButton = {
              let button = UIButton(type: .system)
              let attributedTitle = NSMutableAttributedString(string: "Dont have an account?  ",
                                                              attributes: [
                                                                  NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)!,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.white])
              attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                        attributes: [NSAttributedString.Key.font: UIFont(name: "Verdana-Bold", size: 14)!,
                                                                     NSAttributedString.Key.foregroundColor:  UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
              button.setAttributedTitle(attributedTitle, for: .normal)
              button.addTarget(self, action: #selector(showSignUp), for: .touchUpInside)
              return button
          }()
       
       
       //MARK: Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
            view.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
           setupSubViews()

           // Do any additional setup after loading the view.
       }
       
       
       //MARK: Objc C methods
       
       @objc func validateFields() {
              guard emailTextField.hasText, passwordTextField.hasText else {
                  loginButton.backgroundColor = UIColor(red: 255/255, green: 67/255, blue: 0/255, alpha: 0.5)
                  loginButton.isEnabled = false
                  return
              }
              loginButton.isEnabled = true
              loginButton.backgroundColor = UIColor(red: 255/255, green: 67/255, blue: 0/255, alpha: 1)
          }
       
       @objc func showSignUp() {
              let signupVC = SignUpViewController()
              signupVC.modalPresentationStyle = .formSheet
              present(signupVC, animated: true, completion: nil)
          }
       
       @objc func tryLogin() {
           guard let email = emailTextField.text, let password = passwordTextField.text else {
               showAlert(with: "Error", and: "Please fill out all fields.")
               return
           }
           
           //MARK: TODO - remove whitespace (if any) from email/password
           
           guard email.isValidEmail else {
               showAlert(with: "Error", and: "Please enter a valid email")
               return
           }
           
           guard password.isValidPassword else {
               showAlert(with: "Error", and: "Please enter a valid password. Passwords must have at least 8 characters.")
               return
           }
           
           FirebaseAuthService.manager.loginUser(email: email.lowercased(), password: password) { (result) in
               self.handleLoginResponse(with: result)
           }
       }
       
       
       //MARK: Private methods
       
       private func handleLoginResponse(with result: Result<(), Error>) {
           switch result {
               
           case .success:
               guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
                   else {
                       //MARK: TODO - handle could not swap root view controller
                       return
               }
               
               UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                   if FirebaseAuthService.manager.currentUser != nil {
//                       window.rootViewController = MainMapViewController()
//
                   } else {
                       print("No current user")
                   }
               }, completion: nil)
          case .failure(let error):
           self.showAlert(with: "Error Creating User", and: error.localizedDescription)
           }
       }
       
       
       
       private func showAlert(with title: String, and message: String) {
           let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           present(alertVC, animated: true, completion: nil)
       }
       
       
       
       
       
       //MARK: UI Setup
       
        private func setupSubViews() {
               setupLogoLabel()
               setupCreateAccountButton()
               setupLoginStackView()
           }
           
           private func setupLogoLabel() {
               view.addSubview(logoLabel)
               
               logoLabel.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   logoLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 60),
                   logoLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                   logoLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16)])
           }
           
           private func setupLoginStackView() {
               let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,loginButton])
               stackView.axis = .vertical
               stackView.spacing = 15
               stackView.distribution = .fillEqually
               self.view.addSubview(stackView)
               
               stackView.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   stackView.bottomAnchor.constraint(equalTo: createAccountButton.topAnchor, constant: -50),
                   stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                   stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                   stackView.heightAnchor.constraint(equalToConstant: 130)])
           }
           
           private func setupCreateAccountButton() {
               view.addSubview(createAccountButton)
               
               createAccountButton.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                   createAccountButton.heightAnchor.constraint(equalToConstant: 50)])
           }
       

}
