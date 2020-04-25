//
//  ExploreVC.swift
//  LikeATwitter
//
//  Created by Murat Baykor on 22.04.2020.
//  Copyright © 2020 Murat Baykor. All rights reserved.
//

import UIKit

class ExploreVC: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    private var filteredUsers = [User]() {
        didSet{ tableView.reloadData() }
    }
    
    private var inSearchMode: Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        fetchUsers()
    }
    
    func configureTableView() {
        tableView.rowHeight = 54
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserSearchCell", bundle: nil), forCellReuseIdentifier: "UserSearchCell")
    }
    
    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    func fetchUsers() {
        UserManager.shared.fetchUsers { (users) in
            self.users = users
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchCell", for: indexPath) as! UserSearchCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.set(user: user)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUserProfile"{
            guard let destVC = segue.destination as? UserProfileVC else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
            destVC.user = user
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToUserProfile", sender: self)
    }
}

extension ExploreVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({ $0.username.contains(searchText) })
    }
}
