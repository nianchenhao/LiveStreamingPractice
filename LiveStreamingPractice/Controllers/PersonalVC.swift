//
//  PersonalViewController.swift
//  LiveStreamingPractice
//
//  Created by Class on 2022/3/29.
//

import UIKit
import Firebase

class PersonalVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var rememberButton: UIButton!
    @IBOutlet weak var checkLabel: UILabel!
    
    var agreeIconClick: Bool! = false
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 20
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.checkAndAdd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ auth, user in
            guard user != nil, Auth.auth().currentUser != nil
            else { return }
            let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = myStoryboard.instantiateViewController(withIdentifier: "MemberInfoVC")
            self.navigationController?.pushViewController(vc, animated: false)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - @IBAction
    @IBAction func rememberTapped(_ sender: UIButton) {
        if agreeIconClick == false {
            if let image = UIImage(named: "check") {
                rememberButton.setImage(image, for: .normal)
            }
            agreeIconClick = true
        } else {
            if let image = UIImage(named: "un_check") {
                rememberButton.setImage(image, for: .normal)
            }
            agreeIconClick = false
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if let account = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: account, password: password) { user, error in
                if error != nil {
                    print(error!)
                    self.showAlert(title: NSLocalizedString("LoginFailed", comment: "登入失敗"), message: error?.localizedDescription ?? "")
                    self.checkLabel.isHidden = false
                } else {
                    print("Log in Succesful")
                    if self.agreeIconClick == true {
                        UserDefaults.standard.set("1", forKey: "rememberMe")
                        UserDefaults.standard.set(self.emailTextField.text ?? "", forKey: "userEmail")
                        UserDefaults.standard.set(self.passwordTextField.text ?? "", forKey: "userPassword")
                        print("Email & Password Saved Successfully")
                    } else {
                        UserDefaults.standard.set("2", forKey: "rememberMe")
                    }
                    self.checkLabel.isHidden = true
                    guard Auth.auth().currentUser != nil else { return }
                    
                    self.tabBarController?.selectedIndex = 0
                    
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MemberInfoVC") as? MemberInfoVC {
                        controller.modalPresentationStyle = .currentContext
                        self.navigationController?.viewControllers = [controller]
                    }
                }
            }
        }
    }
    
    // MARK: - Function
    func checkAndAdd() {
        if UserDefaults.standard.string(forKey: "rememberMe") == "1" {
            if let image = UIImage(named: "check") {
                rememberButton.setImage(image, for: .normal)
            }
            agreeIconClick = true
            self.emailTextField.text = UserDefaults.standard.string(forKey: "userEmail") ?? ""
            self.passwordTextField.text = UserDefaults.standard.string(forKey: "userPassword") ?? ""
        } else {
            if let image = UIImage(named: "un_check") {
                rememberButton.setImage(image, for: .normal)
            }
            agreeIconClick = false
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OkButton", comment: "確定"), style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension PersonalVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}

