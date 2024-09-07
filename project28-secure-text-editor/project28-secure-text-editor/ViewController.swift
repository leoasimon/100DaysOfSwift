//
//  ViewController.swift
//  project28-secure-text-editor
//
//  Created by Leo on 2024-09-06.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var secret: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//            let ac = UIAlertController(title: "Authentication Error", message: error?.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)

            authWithPwd()
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identify yourself!") { [weak self] success, authenticationError in

            DispatchQueue.main.async {
                if success {
                    self?.unlockSecretMessage()
                } else {
                    let ac = UIAlertController(title: "Authentication Error", message: authenticationError?.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        }
    }
    
    private func authWithPwd() {
        if let pwd = KeychainWrapper.standard.string(forKey: "Password") {
            let ac = UIAlertController(title: "Password", message: "type your password to authenticate", preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "Authenticate", style: .default, handler: {
                [weak self] _ in
                let userPwd = ac.textFields?[0].text ?? ""
                guard userPwd == pwd else {
                    let ac = UIAlertController(title: "Authentication Error", message: "Incorrect password", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                    
                    return
                }
                
                self?.unlockSecretMessage()
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Password", message: "Create your password", preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "Set password", style: .default, handler: {
                [weak self] _ in
                let userPwd = ac.textFields?[0].text ?? ""
                KeychainWrapper.standard.set(userPwd, forKey: "Password")
                self?.authWithPwd()
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    private func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        navigationItem.rightBarButtonItem = nil
        title = "Nothing to see here"
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}

