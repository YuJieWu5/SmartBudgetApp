//
//  GroupExpenseComposeViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/30.
//

import UIKit
import Supabase

protocol GroupExpenseComposeDelegate: AnyObject {
    func didCreateExpense(_ expense: GroupExpense)
}

class GroupExpenseComposeViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var paidByButton: UIButton!
    var group: Group!
    weak var delegate: GroupExpenseComposeDelegate?
    var currentUserId: String = ""
    var currentUserName: String = ""
    var selectedPayerId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current user ID
        Task {
//            await fetchCurrentUser()
            configureMemberMenu()
        }
    }
    
    func configureMemberMenu() {
        var menuActions: [UIAction] = []
        
        for i in 0..<group.groupMembers.count {
            let memberId = group.groupMembers[i]
            let memberName = group.memberNames[safe: i] ?? "Unknown"
            
            let action = UIAction(title: memberName) { [weak self] _ in
                guard let self = self else { return }
                self.selectedPayerId = memberId
                self.paidByButton.setTitle(memberName, for: .normal)
            }
            
            menuActions.append(action)
        }
        
        // Create and set menu
        let menu = UIMenu(title: "Select Payer", children: menuActions)
        paidByButton.menu = menu
        paidByButton.showsMenuAsPrimaryAction = true
    }
    
    func fetchCurrentUser() async {
        if let user = await SupabaseManager.shared.getCurrentUser() {
            currentUserId = user.id.uuidString
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, !amountText.isEmpty,
              let amount = Double(amountText),
              !selectedPayerId.isEmpty,
              !group.id.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        // Create new expense
        let newExpense = GroupExpense(
            title: title,
            amount: amount,
            paidBy: selectedPayerId,
            group_id: group.id
        )
        
        // Save expense asynchronously
        Task {
            do {
                try await newExpense.save()
                
                // Notify delegate on main thread
                DispatchQueue.main.async {
                    self.delegate?.didCreateExpense(newExpense)
                    // Dismiss
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error saving expense: \(error)")
                // Show error alert to user
                DispatchQueue.main.async {
                    self.showAlert(message: "Error saving expense: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
