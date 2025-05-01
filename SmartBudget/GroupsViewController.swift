//
//  GroupsViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/24.
//

import UIKit
import Supabase

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupCell else{
            return UITableViewCell()
        }
        
        let group = groups[indexPath.row]
        cell.groupNameLabel.text = group.groupName
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(groups[indexPath.row])
        performSegue(withIdentifier: "ShowGroupDetailsSegue", sender: groups[indexPath.row])
    }
    
    var groups: [Group] = []
    var currentUserId: String = ""
    var currentUserName: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // Get current user ID when view loads
        Task {
            await fetchCurrentUser()
            await loadGroups()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await loadGroups()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing for segue: \(String(describing: segue.identifier))")
        print("Sender: \(String(describing: sender))")
        
        if segue.identifier == "ShowGroupDetailsSegue",
           let groupDetailsVC = segue.destination as? GroupDetailsViewController {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            let selectedGroup = groups[selectedIndexPath.row]
            print("Setting group: \(selectedGroup)")
            groupDetailsVC.group = selectedGroup
        } else {
            print("Failed to set group - conditions not met")
            
            // Debug what's failing
            if segue.identifier != "ShowGroupDetailsSegue" {
                print("Wrong segue identifier: \(String(describing: segue.identifier))")
            }
            
            if !(segue.destination is GroupDetailsViewController) {
                print("Destination is not GroupDetailsViewController: \(type(of: segue.destination))")
            }
            
            if !(sender is Group) {
                print("Sender is not Group: \(type(of: sender))")
            }
        }
    }
    
    func fetchCurrentUser() async {
        if let user = await SupabaseManager.shared.getCurrentUser() {
            currentUserId = user.id.uuidString.lowercased()
            currentUserName = await SupabaseManager.shared.getCurrentUserName()
            print(currentUserId)
        } else {
            // Handle case where user is not logged in
            // You might want to redirect to login screen
            print("User not logged in")
        }
    }
    
    func loadGroups() async {
        do {
            if !currentUserId.isEmpty {
                groups = try await Group.fetchGroupsForUser(userId: currentUserId)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error fetching groups: \(error)")
            // Show error alert to user
        }
    }
    
    
    @IBAction func didTapAddGroupButton(_ sender: Any) {
        // Create alert with text field for group name
        let alert = UIAlertController(title: "New Group", message: "Enter group name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Group name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let groupName = textField.text, !groupName.isEmpty else { return }
            
            // Create new group with current user as a member
            print("my id in groups view controller page: \(self.currentUserId)")
            let newGroup = Group(name: groupName, members: [self.currentUserId], member_names: [self.currentUserName])
            
            // Save group asynchronously
            Task {
                do {
                    try await newGroup.save()
                    await self.loadGroups()
                } catch {
                    print("Error saving group: \(error)")
                    // Show error alert to user
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        present(alert, animated: true)
    }
    
}
