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
    var selectedPayerName: String = ""
    
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
                self.selectedPayerName = memberName
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
              !selectedPayerName.isEmpty,
              !group.id.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        // Find the user ID for the selected payer name
        let payerIndex = group.memberNames.firstIndex(of: selectedPayerName) ?? -1
        let payerId = payerIndex >= 0 ? group.groupMembers[payerIndex] : selectedPayerName
        
        // Create new expense with the correct user ID
        let newExpense = GroupExpense(
            title: title,
            amount: amount,
            paidBy: payerId,
            group_id: group.id
        )
        
        // Save expense asynchronously
        Task {
            do {
                try await newExpense.save()
                print("Expense saved successfully")
                
                // Notify delegate on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.delegate?.didCreateExpense(newExpense)
                    print("Called delegate didCreateExpense")
                    
                    // Comprehensive dismissal approach
                    if let presentingVC = self.presentingViewController {
                        print("Dismissing presented view controller")
                        self.dismiss(animated: true)
                    } else if let nav = self.navigationController {
                        print("Popping from navigation stack")
                        nav.popViewController(animated: true)
                    } else {
                        print("No navigation or presenting context found")
                    }
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
        print("Cancel button tapped")
        
        if let presentingVC = self.presentingViewController {
            print("Dismissing presented view controller")
            self.dismiss(animated: true)
        } else if let nav = self.navigationController {
            print("Popping from navigation stack")
            nav.popViewController(animated: true)
        } else {
            print("No navigation or presenting context found")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
