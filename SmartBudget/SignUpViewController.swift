//
//  SignUpViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/28.
//

import UIKit
import Supabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup input formate
        passwordField.isSecureTextEntry = true
        
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        
        userNameField.autocapitalizationType = .none
        userNameField.autocorrectionType = .no
    }
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        // Validate input fields
        guard let email = emailField.text, !email.isEmpty,
              let username = userNameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        view.isUserInteractionEnabled = false
        
        // Perform signup with Supabase
        Task {
            do {
                let response = try await SupabaseManager.shared.signUp(
                    email: email,
                    password: password,
                    username: username
                )
                
                // Update UI on main thread
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    
                    // Check if email confirmation is required
                    if response.session == nil {
                        showAlert(
                            title: "Verification Required",
                            message: "Please check your email and follow the verification link to complete signup"
                        )
                    } else {
                        // User is signed in automatically
                        showAlert(
                            title: "Success",
                            message: "Your account has been created successfully",
                            completion: { [weak self] _ in
                                // Navigate to main screen or dismiss
                                self?.dismiss(animated: true)
                            }
                        )
                    }
                }
            } catch {
                // Handle error
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}
