//
//  GroupDetailsViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/24.
//

import UIKit
import Supabase

class GroupDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Adjust this value based on your design needs
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupExpenseCell", for: indexPath) as! GroupExpenseCell
        
        let expense = expenses[indexPath.row]
        
        // Set the title and amount
        cell.titleLabel.text = expense.title
        cell.amountLabel.text = String(format: "$%.2f", expense.amount)
        
        // Find the member name for the paidBy user ID
        let payerName = getMemberName(for: expense.paidBy) ?? expense.paidBy
        
        // Configure the circular avatar with initial
        configureAvatarImageView(cell.paidByImageView, with: payerName, color: getColorForPayer(expense.paidBy))
        
        return cell
    }
    
    
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var group: Group!
    var expenses: [GroupExpense] = []
    var pieChart: PieChartView!
    var currentUserId: String = ""
    var currentUserName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up the pie chart view
        pieChart = PieChartView(frame: pieChartView.bounds)
        pieChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pieChartView.addSubview(pieChart)
        
        // Guard against nil group
        guard let group = group else {
            print("Error: group is nil in GroupDetailsViewController")
            // Handle the error - perhaps show an alert and pop back
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load group details",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
            return
        }
        
        // Set up navigation title
        self.title = group.groupName
        
        // Get current user ID
        Task {
            await fetchCurrentUser()
            await loadExpenses()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh expenses when view appears
        Task {
            await loadExpenses()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("GroupDetailsViewController prepare...")
        
        // First check if the group is nil
        guard let group = self.group else {
            print("Error: group is nil in prepare for segue")
            return
        }
        
        if segue.identifier == "GroupExpenseComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,
               let composeVC = composeNavController.topViewController as? GroupExpenseComposeViewController {
                composeVC.group = group
                composeVC.delegate = self
            } else {
                print("Error: Failed to cast destination to GroupExpenseComposeViewController")
            }
        } else {
            print("Unknown segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    func getMemberName(for userId: String) -> String? {
        if let index = group.groupMembers.firstIndex(of: userId) {
            return group.memberNames[safe: index]
        }
        return nil
    }
    
    func fetchCurrentUser() async {
        if let user = await SupabaseManager.shared.getCurrentUser() {
            currentUserId = user.id.uuidString
            currentUserName = await SupabaseManager.shared.getCurrentUserName()
        } else {
            print("User not logged in")
        }
    }
    
    func loadExpenses() async {
        do {
            expenses = try await GroupExpense.fetchExpensesForGroup(groupId: group.id)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updatePieChart()
            }
        } catch {
            print("Error fetching expenses: \(error)")
            // Show error alert to user
        }
    }
    
    func getColorForPayer(_ payerId: String) -> UIColor {
        // Define colors for pie chart slices
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemOrange, .systemPurple, .systemTeal
        ]
        
        // Generate a consistent index based on the payerId string
        // This ensures the same person always gets the same color
        var sum = 0
        for char in payerId {
            sum += Int(char.asciiValue ?? 0)
        }
        let index = sum % colors.count
        
        return colors[index]
    }
    
    // Configure the avatar image view with a colored circle and initial
    func configureAvatarImageView(_ imageView: UIImageView, with name: String, color: UIColor) {
        // Get the first character of the name
        let initial = String(name.prefix(1).uppercased())
        
        // Make sure the imageView is round
        imageView.backgroundColor = color
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        
        // Remove any existing subviews
        imageView.subviews.forEach { $0.removeFromSuperview() }
        
        // Create a label for the initial
        let initialLabel = UILabel()
        initialLabel.text = initial
        initialLabel.textColor = .white
        initialLabel.font = UIFont.boldSystemFont(ofSize: 18)
        initialLabel.textAlignment = .center
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the imageView
        imageView.addSubview(initialLabel)
        
        // Center the label in the imageView
        NSLayoutConstraint.activate([
            initialLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        // Clear any existing image
        imageView.image = nil
    }
    
    // Update the pie chart function to use the consistent colors
    func updatePieChart() {
        // Clear existing slices
        pieChart.clearSlices()
        
        // Group expenses by who paid
        var expensesByPayer: [String: Double] = [:]
        
        for expense in expenses {
            expensesByPayer[expense.paidBy, default: 0] += expense.amount
        }
        
        // Add slices to pie chart with consistent colors for each payer
        for (payer, amount) in expensesByPayer {
            pieChart.addSlice(value: amount, color: getColorForPayer(payer))
        }
    }
    
    @IBAction func didTapNewExpenseButton(_ sender: Any) {
        performSegue(withIdentifier: "GroupExpenseComposeSegue", sender: nil)
    }
    
    @IBAction func didTapInviteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Invite Member", message: "Enter user ID and name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "User ID"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "User Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let inviteAction = UIAlertAction(title: "Invite", style: .default) { [weak self] _ in
            guard let self = self,
                  let idField = alert.textFields?[0],
                  let nameField = alert.textFields?[1],
                  let userId = idField.text, !userId.isEmpty,
                  let userName = nameField.text, !userName.isEmpty else { return }
            
            // Add member to group
            var updatedMembers = self.group.groupMembers
            var updatedMemberNames = self.group.memberNames
            
            updatedMembers.append(userId)
            updatedMemberNames.append(userName)
            
            let updatedGroup = Group(
                name: self.group.groupName,
                members: updatedMembers,
                member_names: updatedMemberNames,
                id: self.group.id
            )
            
            // Save updated group
            Task {
                do {
                    try await updatedGroup.save()
                    self.group = updatedGroup
                } catch {
                    print("Error updating group: \(error)")
                    // Show error alert to user
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(inviteAction)
        
        present(alert, animated: true)
    }
}

// Extension to safely access array indices
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - ExpenseComposeDelegate
extension GroupDetailsViewController: GroupExpenseComposeDelegate {
    func didCreateExpense(_ expense: GroupExpense) {
        Task {
            await loadExpenses()
        }
    }
}
