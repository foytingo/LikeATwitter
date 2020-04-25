//
//  LikeVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class LikeVC: DataLoadingVC {
    
    var uid: String? {
        didSet {
            fetchTweets()
        }
    }
    
    var tweets = [Tweet]() {
        didSet {
            DispatchQueue.main.async { self.likesTableView.reloadData() }
        }
    }
    
    var tweetUser: User?
    
    @IBOutlet weak var likesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        likesTableView.tableFooterView = UIView()
        likesTableView.dataSource = self
        likesTableView.register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        likesTableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    
    
    func fetchTweets() {
       showLoadingView()
        guard let uid = uid else { return }
        TweetManager.shared.fetchLikedTweets(uid: uid) { (tweets) in
            self.likesTableView.refreshControl?.endRefreshing()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserProfile" {
            guard let destVC = segue.destination as? UserProfileVC else { return }
            destVC.user = tweetUser
        }
    }
    
}

extension LikeVC: UITableViewDataSource {
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

extension LikeVC: TweetCellDelegate {
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
