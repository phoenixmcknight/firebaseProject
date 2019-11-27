//
//  Post.swift
//  firebae-reddit-clone
//
//  Created by David Rifkin on 11/12/19.
//  Copyright © 2019 David Rifkin. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Post {
    let feedImage:String
    let creatorID: String
    let dateCreated: Date?
    let id:String
    let title:String
    let body:String
    let username:String
    init(feedImage:String, creatorID: String, dateCreated: Date? = nil, title:String,body:String,username:String) {
        self.feedImage = feedImage
        self.creatorID = creatorID
        self.username = username
        self.id = UUID().description
        self.dateCreated = dateCreated
        self.title = title
        self.body = body
    }
    
    init?(from dict: [String: Any], id: String) {
        guard let feedImage = dict["feedImage"] as? String, let userID = dict["creatorID"] as? String,
            let dateCreated = (dict["dateCreated"] as? Timestamp)?.dateValue(), let title = dict["title"] as? String, let body = dict["body"] as? String, let username = dict["username"] as? String else { return nil }
        
        self.feedImage = feedImage
        self.creatorID = userID
        self.id = id
        self.dateCreated = dateCreated
        self.title = title
        self.body = body
        self.username = username
    }
    
    var fieldsDict: [String: Any] {
        return [
            "feedImage": self.feedImage,
            "creatorID": self.creatorID,
            "title":self.title,
            "body":self.body,
            "username":self.username
        ]
    }
}
