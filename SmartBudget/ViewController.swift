//
//  ViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/16.
//

import UIKit
import Supabase

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBAction func didTapSignInButton(_ sender: UIButton) {
        print("email: \(String(describing: emailTextField.text))")
        print("password: \(String(describing: passwordTextField.text))")
        
        // Validate input
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter your email and password")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        view.isUserInteractionEnabled = false
        
        // Perform sign in with Supabase
        Task {
            do {
                let session = try await SupabaseManager.shared.signIn(
                    email: email,
                    password: password
                )
                
                // Successfully signed in
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    
                    // Navigate to main screen
                    self.performSegue(withIdentifier: "goToMainTabBar", sender: nil)
                }
            } catch {
                // Handle error
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    
                    let alert = UIAlertController(
                        title: "Invalid Credentials",
                        message: "Please check your email and password and try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMainTabBar"{
            let destination = segue.destination
            destination.modalPresentationStyle = .fullScreen
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up password field to hide text
        passwordTextField.isSecureTextEntry = true
        
        // Set up keyboard types
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        // Check if user is already signed in
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        Task {
            if await SupabaseManager.shared.isSignedIn() {
                // User is already signed in, navigate to main screen
                await MainActor.run {
                    self.performSegue(withIdentifier: "goToMainTabBar", sender: nil)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


}

