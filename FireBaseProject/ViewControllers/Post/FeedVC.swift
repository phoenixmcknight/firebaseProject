//
//  FeedVC.swift
//  FireBaseProject
//
//  Created by Phoenix McKnight on 11/25/19.
//  Copyright © 2019 Phoenix McKnight. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {
    // enum
    enum collectionIdentifiers:String{
        case collectionCell
    }
    
    var feeds = [Post](){
        didSet{
            collectionView.reloadData()
        }
    }
    //MARK: UI Objects
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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
        label.textColor = .black
        label.font = UIFont(name: "Zapf Dingbats", size: 30)
        label.text = "Feed"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        configureFeedLabelConstraints()
        configureCollectionViewConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogoutButton))
    }
    //MARK: Private Constraints function
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
        cell.feedNameLabel.text = currentFeed.username
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
extension FeedViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let verticalCellCGSize = CGSize(width: 170, height: 170)
        return verticalCellCGSize
    }
}





