//
//  UserProfileVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 23.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class UserProfileVC: DataLoadingVC {

    
    @IBOutlet weak var userProfileHeaderView: UserProfileHeaderView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    
    var tweets = [Tweet]() {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    var likedTweets = [Tweet]() {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    var showedSegmentArray = [Tweet]() {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchTweets()
        fetchLikedTweets()
        userProfileHeaderView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserStats()
        checkIfUserIsFollowed()
        userProfileHeaderView.user = user
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
    }
    
    func fetchTweets() {
        showLoadingView()
        guard let user = user else { return }
        TweetManager.shared.fetchTweets(forUser: user) { (tweets) in
            self.dismissLoadingView()
            self.tweets = tweets
            self.showedSegmentArray = self.tweets
            self.checkIfUserLikedTweet()
            
        }
    }
    
    func fetchLikedTweets() {
        guard let user = user else { return }
        guard let uid = user.uid else { return }
        TweetManager.shared.fetchLikedTweets(uid: uid) { (tweets) in
            self.likedTweets = tweets
        }
    }
    
    func checkIfUserLikedTweet(){
        self.showedSegmentArray.forEach { (tweet) in
            TweetManager.shared.checkIfUserLikedTweet(tweet) { (didLike) in
                guard didLike == true else { return }
                
                if let index = self.showedSegmentArray.firstIndex(where: {$0.tweetID == tweet.tweetID}){
                    self.showedSegmentArray[index].didLike = true
                }
            }
        }
    }
    
    func checkIfUserIsFollowed() {
        guard let user = user else { return }
        guard let uid = user.uid else { return }
        UserManager.shared.checkIfUserFollowed(uid: uid) { (isFollowed) in
            self.userProfileHeaderView.user?.isFollowed = isFollowed
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func fetchUserStats() {
        guard let user = user else { return }
        guard let uid = user.uid else { return }
        UserManager.shared.fetchUserStats(uid: uid) { (stats) in
            self.userProfileHeaderView.user?.stats = stats
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
 
}

extension UserProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showedSegmentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let sortedArray = showedSegmentArray.sorted(by: {$0.timestamp > $1.timestamp})
        let tweet = sortedArray[indexPath.row]
        cell.tweet = tweet
        cell.avatarImage.isUserInteractionEnabled = false
        return cell
    }
    
    
}

extension UserProfileVC: UserProfileHeaderDelegate {
    func showTweets() {
        showedSegmentArray = tweets
        checkIfUserLikedTweet()
        tableView.reloadData()
    }
    
    func showLikes() {
        showedSegmentArray = likedTweets
        checkIfUserLikedTweet()
        tableView.reloadData()
    }
    
    func handleProfileActionButton(_ header: UserProfileHeaderView) {
        guard let user = user else { return }
        guard let uid = user.uid else { return }
        if user.isCurrentUser {
            print("Show edit profile screen")
            return
        }
        
        if user.isFollowed {
            UserManager.shared.unfollowUser(uid: uid) { (error, ref) in
                self.user?.isFollowed = false
                DispatchQueue.main.async {
                    header.actionButton.setTitle("Follow", for: .normal)
                    self.tableView.reloadData()
                }
            }
        } else {
            UserManager.shared.followUser(uid: uid) { (error, ref) in
                self.user?.isFollowed = true
                DispatchQueue.main.async {
                    header.actionButton.setTitle("Unfollow", for: .normal)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
}
