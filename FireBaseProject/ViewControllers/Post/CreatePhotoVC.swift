//
//  CreatePhotoVC.swift
//  FireBaseProject
//
//  Created by Phoenix McKnight on 11/25/19.
//  Copyright © 2019 Phoenix McKnight. All rights reserved.
//

import Foundation
import UIKit
import Photos
import FirebaseAuth
class CreatePhotoVC: UIViewController {
    
    //MARK: Variables
    
    var image = UIImage() {
        didSet {
            self.uploadImage.image = image
        }
    }
    
    var imageURL:URL? = nil
    
    
    //MARK:-- UIObjects
    lazy var uploadImage:UIImageView = {
        let image = UIImageView()
        CustomLayer.shared.createCustomlayer(layer: image.layer, shadowOpacity: 0.5,borderWidth:0)
        let guesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(sender:)))
        guesture.numberOfTapsRequired = 1
        image.image = UIImage(systemName: "photo")
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(guesture)
        return image
    }()
    
    lazy var descriptionTextView:UITextView = {
        
        let dtv = UITextView()
        dtv.textColor = .black
        dtv.backgroundColor = .clear
        dtv.textAlignment = .center
        dtv.font = UIFont(name: "Verdana-Bold", size: 16.0)!
        CustomLayer.shared.createCustomlayer(layer: dtv.layer, shadowOpacity: 0.5, borderWidth: 1.0)
    
        return dtv
    }()
    lazy var titleTextField:UITextField = {
        let ttf = UITextField()
        ttf.placeholder = "Enter Title"
        ttf.textAlignment = .center
        ttf.textColor = .black
        ttf.borderStyle = .roundedRect
        ttf.backgroundColor = .clear
        return ttf
    }()
    lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)
        button.backgroundColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        button.layer.cornerRadius = 5
        CustomLayer.shared.createCustomlayer(layer: button.layer, shadowOpacity: 0.5, borderWidth: 1.5)
        button.addTarget(self, action: #selector(handleUpdateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Upload An Image"
        label.font = UIFont(name: "Verdana-Bold", size: 35)
        label.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.hidesWhenStopped = true
        activityView.color = .white
        activityView.stopAnimating()
        return activityView
    }()
    
    lazy var viewArray = [self.titleLabel,self.titleTextField,self.uploadImage,self.descriptionTextView,self.uploadButton,self.activityIndicator]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: Objc function
    @objc func handleUpdateButton() {
        
        guard let user = FirebaseAuthService.manager.currentUser, let displayName = user.displayName else {
            showAlert(with: "Warning", and: "You Must Have a Profile and Username to Create a Post")
            return
        }
        
        guard let title = titleTextField.text, title != "", let body = descriptionTextView.text, body != "" else {
            showAlert(with: "Error", and: "All fields must be filled")
            return
        }
        
        guard uploadImage.image != UIImage(systemName: "photo") else {
            showAlert(with: "Warning", and: "Please Add a New Image")
            return
        }
        
        guard let image = uploadImage.image?.jpegData(compressionQuality: 0.7) else {
            showAlert(with: "Error", and: "Error Adding Picture, Please Try Again")
            return
        }
        storeImage(image: image, destination: .postImages)
        
        
        
        guard let url = self.imageURL else {
            self.showAlert(with: "Error", and: "Error Adding Picture, Please Try Again")
            return
        }
        
        let newPost = Post(feedImage: url.absoluteString, creatorID: user.uid, title: title, body: body, username: displayName)
        
        
        FirestoreService.manager.createPost(post: newPost) { (result) in
            self.handlePostResponse(withResult: result)
        }
    }
    
    @objc private func imageViewTapped(sender:UITapGestureRecognizer) {
        print("pressed")
        //MARK: TODO - action sheet with multiple media options
        activityIndicator.startAnimating()
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined, .denied, .restricted:
            PHPhotoLibrary.requestAuthorization({[weak self] status in
                switch status {
                case .authorized:
                    self?.presentPhotoPickerController()
                case .denied:
                    //MARK: TODO - set up more intuitive UI interaction
                    print("Denied photo library permissions")
                default:
                    //MARK: TODO - set up more intuitive UI interaction
                    print("No usable status")
                }
            })
        default:
            presentPhotoPickerController()
        }
    }
    
    @objc func handleLogoutButton(){
        try?  Auth.auth().signOut()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
            else {
                //MARK: TODO - handle could not swap root view controller
                return
        }
        
        //MARK: TODO - refactor this logic into scene delegate
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
            
            window.rootViewController = LoginViewController()
            
        }, completion: nil)
    }
    
    @objc public func editProfile() {
        let profile = CreateProfileVC()
        profile.currentProfile = Auth.auth().currentUser
        profile.currentProfileStatus = .editing
        present(profile,animated: true)
    }
    
    //MARK: Private Functions
    
    private func handlePostResponse(withResult result: Result<Void, Error>)  {
        switch result {
        case .success:
           
successfulImageSaved(with: "Success!", and: "Saved Photo")
        case .failure(let error):
            showAlert(with: "Error Posting Image", and: "\(error)")
            
        }
    }
    
    
    //MARK: Private Functions
    
    private func setupView(){
        CustomLayer.shared.setGradientBackground(colorTop: .white, colorBottom: .lightGray, newView: view)
        addSubviewsToView()
        configureTitleLabelConstraints()
        configureTitleTextFieldConstraints()
        configureUploadImageConstraints()
        configureTextViewConstraints()
        configureUploadButtonConstraints()
        configureActivityIndicatorConstraints()
        
        showAlert(with: "Tap Photo To Set Image", and: "")
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
    
    private func presentPhotoPickerController() {
        DispatchQueue.main.async{
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            imagePickerViewController.sourceType = .photoLibrary
            imagePickerViewController.allowsEditing = true
            imagePickerViewController.mediaTypes = ["public.image", "public.movie"]
            self.present(imagePickerViewController, animated: true,completion: nil)
        }
    }
    //MARK: Alerts
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func successfulImageSaved(with title: String, and message: String) {
           let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.navigationController?.pushViewController(FeedViewController(), animated: true)
        }))
           
           present(alertVC, animated: true, completion: nil)
       }
    
    //MARK:UIObject Constraints
    
    private func configureTitleLabelConstraints(){
        
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor), titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor), titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor), titleLabel.heightAnchor.constraint(equalToConstant: 100)])
    }
    
    private func configureTitleTextFieldConstraints() {
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo:titleLabel.bottomAnchor,constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            titleTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
   
    
    private func configureUploadImageConstraints(){
        
        NSLayoutConstraint.activate([uploadImage.topAnchor.constraint(equalTo: self.titleTextField.bottomAnchor), uploadImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30), uploadImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30), uploadImage.heightAnchor.constraint(equalToConstant: 300)])
    }
    
    private func configureTextViewConstraints() {
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: uploadImage.bottomAnchor,constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            descriptionTextView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor,constant: -10)
        ])
    }
    
    private func configureUploadButtonConstraints(){
        
        NSLayoutConstraint.activate([uploadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20), uploadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50), uploadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -50), uploadButton.heightAnchor.constraint(equalToConstant: 40)])
    }
    
    private func configureActivityIndicatorConstraints(){
        self.uploadImage.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.topAnchor.constraint(equalTo: self.uploadImage.topAnchor) , activityIndicator.leadingAnchor.constraint(equalTo: self.uploadImage.leadingAnchor) ,activityIndicator.trailingAnchor.constraint(equalTo: self.uploadImage.trailingAnchor) ,activityIndicator.bottomAnchor.constraint(equalTo: self.uploadImage.bottomAnchor)])
    }
    
    private func addSubviewsToView() {
        for newView in viewArray {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogoutButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Edit Profile",style:UIBarButtonItem.Style.plain,target:self,action:#selector(editProfile))
    }
    
    
    
}
extension CreatePhotoVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        self.image = selectedImage
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {return}
        storeImage(image: imageData, destination: .tempImages)
        self.activityIndicator.stopAnimating()
        picker.dismiss(animated: true, completion: nil)
    }
    
}



