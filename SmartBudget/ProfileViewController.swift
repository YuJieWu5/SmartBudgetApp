//
//  ProfileViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/28.
//

import UIKit
import Auth

class ProfileViewController: UIViewController {
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh user profile when view appears
        loadUserProfile()
    }
    
    @IBAction func didTapLogOutButton(_ sender: UIButton) {
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogOut()
        })
        
        present(alert, animated: true)
    }
    
    
    private func loadUserProfile() {
        Task {
            if let user = await SupabaseManager.shared.getCurrentUser() {
                await MainActor.run {
                    // Display user ID
                    userIdLabel.text = "ID:\(user.id.uuidString)"
                    
                    // Display email
                    emailLabel.text = "Email: \(user.email ?? "Not available")"
                    
                    // Get metadata as dictionary with Any values
                    if let metadata = user.userMetadata as? [String: Any] {
                        print(metadata)
                        // Try to get the name directly
                        if let name = metadata["name"] {
                            userNameLabel.text = "User Name: \(name)" // Convert to string using string interpolation
                            print("Found name: \(name)")
                        } else {
                            userNameLabel.text = "User"
                            print("Name not found in metadata")
                        }
                    } else {
                        userNameLabel.text = "User"
                        print("Could not cast metadata to dictionary")
                        print("Metadata type: \(type(of: user.userMetadata))")
                        print("Metadata content: \(user.userMetadata)")
                    }
                }
            } else {
                // Not signed in or session expired
                await MainActor.run {
                    showSignInScreen()
                }
            }
        }
    }
    
    private func performLogOut() {
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        view.isUserInteractionEnabled = false
        
        Task {
            do {
                try await SupabaseManager.shared.signOut()
                
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    showSignInScreen()
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    view.isUserInteractionEnabled = true
                    
                    // Show error alert
                    let alert = UIAlertController(
                        title: "Log Out Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showSignInScreen() {
        // Get the storyboard and initial view controller (assuming it's the login screen)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController()
        
        // Set as root view controller with transition
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = loginVC
            
            // Add a smooth transition animation
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        } else {
            // Fallback if the above doesn't work
            dismiss(animated: true)
        }
    }
    
}
