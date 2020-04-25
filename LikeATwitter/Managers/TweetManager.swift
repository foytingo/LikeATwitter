//
//  TweetManager.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 23.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import Firebase

struct TweetManager {
    static let shared = TweetManager()
    
    func uploadTweet(caption: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "likes": 0, "retweets": 0, "caption" : caption] as [String : Any]
        
        Refs.tweets.childByAutoId().updateChildValues(values) { (error, ref) in
            guard let tweetID = ref.key else { return }
            Refs.userTweets.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
        }
    }
    
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Refs.userFollowing.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            
            Refs.userTweets.child(followingUid).observe(.childAdded) { (snapshot) in
                let tweetID = snapshot.key
                
                self.fetchTweet(withTweetID: tweetID) { (tweet) in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        Refs.userTweets.child(currentUid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { (tweet) in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID: String, completion: @escaping(Tweet) -> Void) {
        Refs.tweets.child(withTweetID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserManager.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: withTweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        Refs.userTweets.child(user.uid!).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            Refs.tweets.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserManager.shared.fetchUser(uid: uid) { (user) in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    
    func fetchLikedTweets(uid: String,completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        Refs.userLikes.child(uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            Refs.tweets.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserManager.shared.fetchUser(uid: uid) { (user) in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        Refs.tweets.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            Refs.userLikes.child(uid).child(tweet.tweetID).removeValue { (error, ref) in
                Refs.tweetLikes.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            Refs.userLikes.child(uid).updateChildValues([tweet.tweetID:1]) { (error, ref) in
                Refs.tweetLikes.child(tweet.tweetID).updateChildValues([uid:1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Refs.userLikes.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
}
