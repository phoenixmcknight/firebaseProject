//
//  FeedCollectionViewCell.swift
//  FireBaseProject
//
//  Created by Phoenix McKnight on 11/25/19.
//  Copyright © 2019 Phoenix McKnight. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
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
                feedNameLabel.topAnchor.constraint(equalTo: feedImageView.topAnchor,constant: 20),
                feedNameLabel.leadingAnchor.constraint(equalTo: feedImageView.leadingAnchor,constant: 10),
                feedNameLabel.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor,constant: -10),
                feedNameLabel.bottomAnchor.constraint(equalTo: feedImageView.centerYAnchor,constant: 10)
                //set label to bottom of imageview
                //reuse detailVC for listVC
                
            ])
        }
        
        
    }

    

