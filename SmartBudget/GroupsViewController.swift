//
//  GroupsViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/24.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupCell else{
            return UITableViewCell()
        }
        
        cell.groupNameLabel.text = groups[indexPath.row]
        return cell
    }
    
    private var groups = ["NY Travel", "Seattle", "Apt123"]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func didTapAddGroupButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Group", message: "Please enter a group name", preferredStyle: .alert)
        
        // Add text field to alert
        alertController.addTextField { textField in
            textField.placeholder = "Group Name"
        }
        
        // Create Add action
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let groupName = textField.text,
                  !groupName.isEmpty else {
                return
            }
            
            // Add new group to array
            self.groups.append(groupName)
            
            // Reload table view to display the new group
            self.tableView.reloadData()
        }
        
        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to alert controller
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // Present alert controller
        present(alertController, animated: true)
    }

}
