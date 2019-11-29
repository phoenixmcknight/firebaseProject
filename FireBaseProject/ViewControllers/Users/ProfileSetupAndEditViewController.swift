
import UIKit
import Photos
import FirebaseAuth
enum ProfileStatus {
    case creating
    case editing
}
class CreateProfileVC: UIViewController {
    
    //MARK: Variables
    
    var currentUser:Result<User,Error>? = nil
    
    var currentProfileStatus:ProfileStatus!
    
    var currentProfile:User?
    
    var emailAndPassword = ("","")
    
    
    var imageURL: URL? = nil {
        didSet {
            print("got url")
        }
    }
    
    //MARK: UIObjects
    
    lazy var postCount:UILabel = {
        let pc = UILabel(font: UIFont(name: "Verdana-Bold", size: 36.0)!)
        pc.isHidden = true
        return pc
    }()
    
    lazy var emailAddress:UILabel = {
        let ea = UILabel(font: UIFont(name: "Verdana-Bold", size: 24)!)
        
        return ea
    }()
    
    lazy var displayName:UILabel = {
        let dn = UILabel(font: UIFont(name: "Verdana-Bold", size: 36.0)!)
        
        dn.text = "User Name"
        return dn
    }()
    
    lazy var displayNameButton:UIButton = {
        let db = UIButton(type: UIButton.ButtonType.contactAdd)
        db.addTarget(self, action: #selector(enterDisplayName), for: .touchUpInside)
        return db
    }()
    
    lazy var profileImageView: UIImageView = {
        let guesture = UITapGestureRecognizer(target: self, action: #selector(imageAlert))
        
        //        guesture.numberOfTapsRequired = 1
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width / 2, height: self.view.bounds.width / 2))
        imageView.backgroundColor = .black
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(guesture)
        return imageView
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        return button
    }()
    lazy var viewArray = [self.emailAddress,self.postCount,self.profileImageView,self.displayName,self.saveButton,self.displayNameButton]
    
    
    //MARK:Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLayer.shared.setGradientBackground(colorTop: .white, colorBottom: .lightGray, newView: view)
        addSubviews()
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        editingProfile()
    }
    
    //MARK: Private Functions
    
    private func editingProfile() {
        if currentProfileStatus == .editing {
            
            guard let user = currentProfile else {return}
            getPostsForThisUser()
            displayName.text = user.displayName
            imageHelperFunction(photoURL: user.photoURL?.absoluteString)
            imageURL = user.photoURL
            postCount.isHidden = false
            saveButton.setTitle("Save Edits", for: .normal)
            emailAddress.text = Auth.auth().currentUser?.email
        }
    }
    
    private func getPostsForThisUser() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            FirestoreService.manager.getPosts(forUserID: self?.currentProfile?.uid ?? "") { (result) in
                switch result {
                case .success(let posts):
                    self?.postCount.text = "Post Count : \(posts.count)"
                case .failure(let error):
                    print(":( \(error)")
                }
            }
        }
    }
    
    private func handleUpdateAccountResponse(username:String, photoURL:URL) {
        FirestoreService.manager.updateCurrentUser(userName: username, photoURL: photoURL) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.showAlert(with: "Error Updating Account Information", and: error.localizedDescription)
            case .success():
                FirebaseAuthService.manager.updateUserFields(userName: username, photoURL: photoURL) {  [weak self](nextResult) in
                    switch nextResult {
                    case .failure(let error):
                        print(error)
                    case .success():
                        self?.successfulProfileAlert(title: "Successfully Saved Profile Changes", message: "", profileStatus: .editing)
                    }
                    
                }
            }
        }
    }
    
    
    private func handleCreateAccountResponse(with result: Result<User, Error>) {
        //    DispatchQueue.main.async { [weak self] in
        switch result {
        case .success(let user):
            FirestoreService.manager.createAppUser(user: AppUser(from: user)) { [weak self] newResult in
                guard FirebaseAuthService.manager.currentUser != nil else {
                    self?.showAlert(with: "Error Creating User", and: "")
                    return
                }
                
                
                FirestoreService.manager.updateCurrentUser(userName: self?.displayName.text, photoURL: self?.imageURL) { [weak self] (nextResult) in
                    switch nextResult {
                    case .success():
                        FirebaseAuthService.manager.updateUserFields(userName: self?.displayName.text, photoURL: self?.imageURL) { (updateUser) in
                            
                            switch updateUser{
                            case .failure(let error):
                                self?.showAlert(with: "Error", and: error.localizedDescription)
                            case .success():
                                self?.successfulProfileAlert(title: "Success", message: "Your Profile Information has Saved Successfully", profileStatus: self?.currentProfileStatus)
                            }
                        }
                        
                        print(self?.imageURL?.absoluteString)
                    case .failure(let error):
                        self?.showAlert(with: "Error", and: "Error Creating User. Please Try Again")
                        
                        print(error)
                        return
                    }
                }
                print(newResult)
            }
        case .failure(let error):
            self.showAlert(with: "Error creating user", and: "An Error Occured While Creating a New Account: \(error)")
        }
    }
    
    
    
    
    
    
    
    
    
    private func imageHelperFunction(photoURL:String?) {
        guard let url = photoURL else {return}
        ImageHelper.shared.getImage(urlStr: url) { [weak self](result) in
            DispatchQueue.main.async {
                
                
                switch result {
                case .failure(let error):
                    self?.showAlert(with: "Could Not Load Photo", and: "\(error)")
                    self?.profileImageView.image = UIImage(systemName: "photo")
                case .success(let image):
                    self?.profileImageView.image = image
                    
                }
            }
        }
    }
    @objc private func savePressed(){
        
        
        guard let username = displayName.text else {showAlert(with: "Invalid Username", and: "")
            return }
        
        guard username != "User Name" else {showAlert(with: "Invalid Username", and: "")
            return }
        
        guard let imageData = profileImageView.image?.jpegData(compressionQuality: 0.7), let photoURL = imageURL else {
            showAlert(with: "Invalid Profile Picture", and: "")
            return
        }
        
        
        switch currentProfileStatus {
        case .creating:
            FirebaseAuthService.manager.createNewUser(email: emailAndPassword.0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), password: emailAndPassword.1.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) { [weak self] (result) in
                
                self?.currentUser = result
                
                guard self?.currentUser != nil else {self?.showAlert(with: "Could Not Create Account", and: "")
                    return}
                
                self?.handleCreateAccountResponse(with: result)
                
            }
        case .editing:
            handleUpdateAccountResponse(username: username, photoURL: photoURL)
        case .none:
            print("error")
        }
        self.storeImage(image: imageData, destination: .profileImages)
    }
    
    private func presentPhotoPickerController() {
        DispatchQueue.main.async{
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = .photoLibrary
            imagePickerViewController.allowsEditing = true
            imagePickerViewController.mediaTypes = ["public.image"]
            self.present(imagePickerViewController, animated: true, completion: nil)
        }
    }
    
    //MARK: Alerts
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func showErrorAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func successfulProfileAlert(title:String,message:String,profileStatus:ProfileStatus?) {
        guard let status = profileStatus else {return}
        let alert = UIAlertController(title:title , message: message, preferredStyle: .alert)
        
        let response = UIAlertAction(title: "Ok", style: .default) { [weak self](action) in
            switch status {
                
            case .creating:
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
                    else {
                        //MARK: TODO - handle could not swap root view controller
                        return
                }
                
                UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                    
                    window.rootViewController = TabBarController()
                    
                }, completion: nil)
                
            case .editing:
                self?.dismiss(animated: true, completion: nil)
                
            }
        }
        alert.addAction(response)
        present(alert,animated: true)
    }
    
    //MARK: Objc functions
    
    @objc private func imageAlert() {
        let alertVC = UIAlertController(title: "Profile Image", message: "", preferredStyle: .actionSheet)
        
        let useDefaultImage = UIAlertAction(title: "Use Generic Image", style: .default) { [weak self] (default) in
            guard let image = UIImage(systemName: "person.fill")?.jpegData(compressionQuality: 0.7) else {return}
            self?.profileImageView.image = UIImage(data: image)
            
            self?.storeImage(image: image, destination: .tempImages)
        }
        
        let useCustomImage = UIAlertAction(title: "Use Custom Image", style: .default) { (custom) in
            //self.dismiss(animated: true) {
            self.presentPhotoPickerController()
            //  }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(useDefaultImage)
        alertVC.addAction(useCustomImage)
        alertVC.addAction(cancel)
        present(alertVC,animated: true)
        
    }
    
    @objc private func enterDisplayName() {
        let alert = UIAlertController(title: "Display Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Display Name"
            textField.textAlignment = .center
            textField.backgroundColor = .clear
            textField.borderStyle = .bezel
            textField.layer.cornerRadius = 5
            textField.autocorrectionType = .no
        }
        let enter = UIAlertAction(title: "Enter", style: .default) { (action) in
            guard let text = alert.textFields?[0] else {return}
            guard text.hasText else {return}
            
            self.displayName.text = text.text
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(enter)
        alert.addAction(cancel)
        present(alert,animated: true)
    }
    
    
    //MARK:  UIObjects Constraints
    
    private func addSubviews() {
        for newView in viewArray {
            self.view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    private func setupViews() {
        setupImageView()
        setupSaveButton()
        setUpPostCount()
        setUpEmailAddress()
        displayNameConstraints()
        displayNameButtonConstraints()
    }
    
    private func setUpEmailAddress() {
        NSLayoutConstraint.activate([
            emailAddress.topAnchor.constraint(equalTo: postCount.bottomAnchor, constant:  20),
            emailAddress.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            emailAddress.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setUpPostCount() {
        NSLayoutConstraint.activate([
            postCount.topAnchor.constraint(equalTo: view.topAnchor,constant: 20),
            postCount.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            postCount.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupImageView() {
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: self.view.bounds.width / 1.5),
            profileImageView.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 1.5)
        ])
    }
    
    
    
    private func setupSaveButton() {
        
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(UIScreen.main.bounds.height * 0.1)),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    private func displayNameConstraints() {
        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor,constant: 10),
            displayName.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            displayName.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.6),
            
            displayName.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    private func displayNameButtonConstraints() {
        NSLayoutConstraint.activate([
            displayNameButton.centerYAnchor.constraint(equalTo: displayName.centerYAnchor),
            displayNameButton.leadingAnchor.constraint(equalTo: displayName.trailingAnchor),
        ])
    }
    
}


extension CreateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            //MARK: TODO - handle couldn't get image :(
            return
        }
        self.profileImageView.image = image
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            //MARK: TODO - gracefully fail out without interrupting UX
            return
        }
        
        storeImage(image: imageData, destination: .tempImages)
        
        dismiss(animated: true, completion: nil)
    }
    private func storeImage(image:Data,destination:imageFolders) {
        FirebaseStorageService.manager.storeImage(image: image, destination: destination) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.showAlert(with: "Error", and: "\(error)")
            case .success(let url):
                self?.imageURL = url
            }
        }
    }
}
