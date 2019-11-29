

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: UI Objects
    
    private var containerViewBottomConstraint = NSLayoutConstraint()
    private var containerViewTopConstraint = NSLayoutConstraint()
    
    lazy var containerView:UIView = {
        let container = UIView()
        return container
    }()
    
    lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Pursuitgram"
        label.font = UIFont(name: "Verdana-Bold", size: 45)
        label.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
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
        textField.delegate = self
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
        textField.delegate = self
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tryLogin), for: .touchUpInside)
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
        CustomLayer.shared.setGradientBackground(colorTop: .white, colorBottom: .lightGray, newView: view)
        setupSubViews()
        addKeyBoardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: Objc C methods
    
    @objc func keyBoardAppears(sender notification:Notification){
        guard let infoDict = notification.userInfo else {return}
        guard let keyboardFreme = infoDict[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
        guard let duration = infoDict[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        
        self.containerViewBottomConstraint.constant = -10 - (keyboardFreme.height)
        self.containerViewTopConstraint.constant = 500 - (keyboardFreme.height)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyBoardHiding(sender notification:Notification){
        guard let infoDict = notification.userInfo else {return}
        guard let duration = infoDict[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        
        self.containerViewBottomConstraint.constant = -10
        self.containerViewTopConstraint.constant = 500
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func validateFields() {
        guard emailTextField.hasText, passwordTextField.hasText else {
            loginButton.backgroundColor = #colorLiteral(red: 0.3949317038, green: 0.5039875507, blue: 1, alpha: 1)
            loginButton.isEnabled = false
            return
        }
        loginButton.isEnabled = true
        loginButton.backgroundColor = #colorLiteral(red: 0.2334540784, green: 0.2368975878, blue: 0.8274126649, alpha: 1)
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
    
    private func addKeyBoardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppears(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardHiding(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
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
                    window.rootViewController = TabBarController()
                    
                } else {
                    print("No current user")
                }
            }, completion: nil)
        case .failure(let error):
            self.showAlert(with: "Error Creating User", and: error.localizedDescription)
        }
    }
    
    //MARK:Alerts
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    
    
    
    //MARK: UI Setup
    
    private func setupSubViews() {
        configureContainerviewConstraints()
        setupLogoLabel()
        setupCreateAccountButton()
        setupLoginStackView()
    }
    
    private func configureContainerviewConstraints(){
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor), containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor), containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor), containerView.heightAnchor.constraint(equalToConstant: 400)])
        
        self.containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -10)
        containerViewBottomConstraint.isActive = true
        
        self.containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 500)
        containerViewTopConstraint.isActive = true
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
        self.containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: createAccountButton.topAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 130)])
    }
    
    private func setupCreateAccountButton() {
        containerView.addSubview(createAccountButton)
        
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createAccountButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            createAccountButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            createAccountButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
}

extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
