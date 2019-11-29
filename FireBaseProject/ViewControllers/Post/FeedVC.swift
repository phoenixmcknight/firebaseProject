

import Foundation
import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {
    
    //MARK: Enums
    
    enum collectionIdentifiers:String{
        case collectionCell
    }
    
    //MARK:Variables
    
    var feeds = [Post](){
        didSet{
            collectionView.reloadData()
        }
    }
    //MARK: UI Objects
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 150, height: 150)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: collectionIdentifiers.collectionCell.rawValue)
        cv.delegate = self
        cv.dataSource = self
        
        return cv
    }()
    
    lazy var feedLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        label.font = UIFont(name: "Verdana-Bold", size: 30)
        label.text = "Feed"
        return label
    }()
    
    //MARK:Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    
    //MARK: Private Constraints function
    
    private func setupView(){
        CustomLayer.shared.setGradientBackground(colorTop: .white, colorBottom: .lightGray, newView: view)
        configureFeedLabelConstraints()
        configureCollectionViewConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogoutButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Edit Profile",style:UIBarButtonItem.Style.plain,target:self,action:#selector(editProfile))
    }
    private func configureFeedLabelConstraints(){
        self.view.addSubview(feedLabel)
        feedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([feedLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor), feedLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor), feedLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor), feedLabel.heightAnchor.constraint(equalToConstant: 100)])
    }
    
    private func configureCollectionViewConstraints(){
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor), collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5), collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),collectionView.topAnchor.constraint(equalTo: self.feedLabel.bottomAnchor)])
    }
    
    //MARK: Private Functions
    private func loadData() {
        FirestoreService.manager.getAllPosts(sortingCriteria: .fromNewestToOldest) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let images):
                self.feeds = images
            }
        }
    }
    
    //MARK: Objc functions
    
    @objc func handleLogoutButton(){
        try?  Auth.auth().signOut()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
            else {
                //MARK: TODO - handle could not swap root view controller
                return
        }
        
        
        
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
}
extension FeedViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentFeed = feeds[indexPath.item]
        let feedDetailedVc = FeedDetailVC()
        feedDetailedVc.post = currentFeed
        navigationController?.pushViewController(feedDetailedVc, animated: true)
    }
}
extension FeedViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionIdentifiers.collectionCell.rawValue, for: indexPath) as? FeedCollectionViewCell else {return UICollectionViewCell()}
        let currentFeed = feeds[indexPath.item]
        cell.feedNameLabel.text = "User: \(currentFeed.username)"
        imageHandler(images: currentFeed.feedImage, currentCell: cell.feedImageView)
        
        CustomLayer.shared.createCustomlayer(layer: cell.layer, shadowOpacity: 0.5, borderWidth: 0)
        print(currentFeed.id)
        return cell
    }
    private func imageHandler(images:String,currentCell:UIImageView) {
        ImageHelper.shared.getImage(urlStr: images) { [weak self] (result) in
            DispatchQueue.main.async {
                
                
                switch result {
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    currentCell.image = UIImage(systemName: "photo")
                case .success(let uiImage):
                    currentCell.image = uiImage
                }
            }
        }
        
    }
}





