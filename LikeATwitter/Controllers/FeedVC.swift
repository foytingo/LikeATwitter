//
//  FeedVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class FeedVC: DataLoadingVC {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String? {
        didSet {
            fetchUser(uid: uid)
            fetchTweets()
        }
    }
    
    var tweetUser: User?
    
    var user: User? {
        didSet { configureNavBarAvatar() }
    }
    
    var tweets = [Tweet]() {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func configureNavBarAvatar() {
        guard let user = user else { return }
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        avatarImage.layer.masksToBounds = true
        avatarImage.sd_setImage(with: user.profileImageUrl, completed: nil)
        
    }
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    func fetchTweets() {
        showLoadingView()
        TweetManager.shared.fetchTweets { (tweets) in
            self.tableView.refreshControl?.endRefreshing()
            self.dismissLoadingView()
            self.tweets = tweets
            self.checkIfUserLikedTweet()
            
        }
    }
    
    func checkIfUserLikedTweet(){
        self.tweets.forEach { (tweet) in
            TweetManager.shared.checkIfUserLikedTweet(tweet) { (didLike) in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: {$0.tweetID == tweet.tweetID}){
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    func fetchUser(uid: String?) {
        guard let uid = uid else { return }
        UserManager.shared.fetchUser(uid: uid) { (user) in
            self.user = user
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserProfile" {
            guard let destVC = segue.destination as? UserProfileVC else { return }
            destVC.user = tweetUser
        }
    }
    
    @IBAction func logOutButtonAction(_ sender: UIBarButtonItem) {
        
        handleLogout()
    }
    
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            avatarImage.image = nil
            tweets.removeAll()
            tableView.reloadData()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToAuth", sender: nil)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
}

extension FeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let sortedArray = tweets.sorted(by: {$0.timestamp > $1.timestamp})
        let tweet = sortedArray[indexPath.row]
        cell.tweetCellDelegate = self
        cell.tweet = tweet
        cell.avatarImage.isUserInteractionEnabled = true
        return cell
    }
}

extension FeedVC: TweetCellDelegate {
    func didTapLikeButton(cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        TweetManager.shared.likeTweet(tweet: tweet) { (error, ref) in
            cell.tweet?.didLike.toggle()
        }
        
    }
    
    
    func didTapAvatarImage(_ user: User) {
        self.tweetUser = user
        performSegue(withIdentifier: "goToUserProfile", sender: self)
    }
    
}
