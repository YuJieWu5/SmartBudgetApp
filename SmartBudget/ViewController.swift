//
//  ViewController.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBAction func didTapSignInButton(_ sender: UIButton) {
        print("email: \(String(describing: emailTextField.text))")
        print("password: \(String(describing: passwordTextField.text))")
        
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            return
        }
        
        if isValidCredentials(email: email, password: password){
            performSegue(withIdentifier: "goToMainTabBar", sender: nil)
        }else{
            let alert = UIAlertController(
                title: "Invalid Credentials",
                message: "Please check your username and password and try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            
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
        // Do any additional setup after loading the view.
    }
    
    // Helper function to validate credentials
    func isValidCredentials(email: String, password: String) -> Bool {
        
//        return email == "correctUsername" && password == "correctPassword"
        return true;
    }


}

