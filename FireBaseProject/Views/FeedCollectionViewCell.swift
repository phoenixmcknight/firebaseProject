//
//  FeedCollectionViewCell.swift
//  FireBaseProject
//
//  Created by Phoenix McKnight on 11/25/19.
//  Copyright © 2019 Phoenix McKnight. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
    //MARK: UIObjects
    
    lazy var feedImageView:UIImageView = {
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "photo")
        
        return iv
    }()
    
    lazy var activityIndicator:UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.contentMode = .center
        ai.hidesWhenStopped = true
        ai.style = .large
        ai.startAnimating()
        return ai
        
    }()
    
    lazy var feedNameLabel:UILabel = {
        let vnl = UILabel(font: UIFont(name: "Courier-Bold", size: 12.0)!)
        vnl.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
        return vnl
    }()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        configureConstraints()
    }
    //MARK: UIObject Constraints
    
    private func addViews(){
        contentView.addSubview(feedImageView)
        contentView.addSubview(feedNameLabel)
        
    }
    
    private func configureConstraints() {
        feedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        feedNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            feedImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            feedImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width * 1),
            
            feedImageView.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.8),
            feedNameLabel.topAnchor.constraint(equalTo: feedImageView.bottomAnchor,constant: 10),
            feedNameLabel.leadingAnchor.constraint(equalTo: feedImageView.leadingAnchor,constant: 10),
            feedNameLabel.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor,constant: -10),
            //set label to bottom of imageview
            //reuse detailVC for listVC
            
        ])
    }
    
    
}



