//
//  ExpenseComposeViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/23.
//

import UIKit

class ExpenseComposeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryButton: UIButton!
    
    var selectCategory: String?
    var onComposeExpense: ((Expense) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountField.delegate = self
        titleField.delegate = self
        
        setupCategoryMenu()
    }
    
    func setupCategoryMenu(){
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Other") { [weak self] action in
                self?.handleSelection(item: action.title)
            },
            UIAction(title: "Transportation") { [weak self] action in
                self?.handleSelection(item: action.title)
            },
            UIAction(title: "Entertainment") { [weak self] action in
                self?.handleSelection(item: action.title)
            },
            UIAction(title: "Food") { [weak self] action in
                self?.handleSelection(item: action.title)
            }
        ])
        
        // Attach the menu to the button
        categoryButton.menu = menu
        categoryButton.showsMenuAsPrimaryAction = true
    }
    
    private func handleSelection(item: String) {
        // Update the button title
        categoryButton.setTitle(item, for: .normal)
        selectCategory = item
        
        // Do something with the selected item
        print("Selected: \(item)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Check which text field is being edited
            if textField == amountField {
                // Logic for number text field
                
                // Get the current text and the text that will be in the field after this change
                let currentText = textField.text ?? ""
                let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
                
                // Allow backspace/delete
                if string.isEmpty { return true }
                
                // Check for decimal point - only allow one
                if string == "." {
                    return !currentText.contains(".")
                }
                
                // Only allow numeric input
                let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
                let characterSet = CharacterSet(charactersIn: string)
                
                // Make sure the result is a valid number format
                return allowedCharacters.isSuperset(of: characterSet) && isValidNumber(updatedText)
            } else if textField == titleField {
                return true
            }
            
            return true
        }
        
        // Additional validation to ensure it's a valid number format
        private func isValidNumber(_ string: String) -> Bool {
            // Allow empty string
            if string.isEmpty { return true }
            
            // Check if it's a valid number format
            return Double(string) != nil
        }
        
        // Optional: Handle text field interactions
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Handle when a text field begins editing
            if textField == amountField {
                print("0.00")
            } else if textField == titleField {
                print("Expense Title")
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Handle return key - dismiss keyboard
            textField.resignFirstResponder()
            return true
        }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        guard let title = titleField.text,
              !title.isEmpty
        else{
            presentAlert(title: "Oops...", message: "Make sure to add a title!")
            return
        }
        
        guard let amount = amountField.text,
              !amount.isEmpty
        else{
            presentAlert(title: "Oops...", message: "Make sure each field is not empty!")
            return
        }
        
        var expense: Expense
        expense = Expense(title:  title, amount: Double(amount) ?? 0.00, date: datePicker.date, category: selectCategory!)
        
        onComposeExpense?(expense)
        dismiss(animated: true)
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
