//
//  LoginViewController.swift
//  ChatNow
//
//  Created by uttam on 27/07/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner=JGProgressHUD(style: .dark)
    
    private let scrollView:UIScrollView={
        let scrollView=UIScrollView()
        scrollView.clipsToBounds=true
        return scrollView
    }()
    
    private var imageView : UIImageView={
        let imageview = UIImageView()
        imageview.image=UIImage(named: "logo")
        imageview.contentMode = .scaleAspectFit
//        imageview.
        return imageview
    }()
    
    private let emailTextField:UITextField={
        let field=UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder="Email Address"
        field.returnKeyType = .continue
        field.layer.cornerRadius=12
        field.layer.borderWidth=1
        field.layer.borderColor=UIColor.lightGray.cgColor
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "mail")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        field.leftView = imageView

        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    
    private let passwordTextField:UITextField={
        let field=UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder="Password"
        field.returnKeyType = .done
        field.layer.cornerRadius=12
        field.layer.borderWidth=1
        field.layer.borderColor=UIColor.lightGray.cgColor
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "lock")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        field.leftView = imageView
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry=true
        return field
    }()

    private let loginButton:UIButton={
        let button=UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor( .white , for: .normal)
        button.layer.cornerRadius=12
        button.layer.masksToBounds=true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf=self else{
                return
            }
            self?.navigationController?.dismiss(animated: true)
        })
        view.backgroundColor = .systemBackground
        title = "Log In"
        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Register",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(didTapRegister))
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        
        emailTextField.delegate=self
        passwordTextField.delegate=self
        // Do any additional setup after loading the view.
        // Add sub view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)


    }
    deinit {
          if let observer = loginObserver {
              NotificationCenter.default.removeObserver(observer)
          }
      }
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        scrollView.frame=view.bounds
        let size=scrollView.width/3
        imageView.frame=CGRect(x: ((scrollView.width-size)/2),
                               y: 20,
                               width: size,
                               height: size)
        emailTextField.frame=CGRect(x: 30,
                               y: imageView.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        passwordTextField.frame=CGRect(x: 30,
                               y: emailTextField.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        loginButton.frame=CGRect(x: 30,
                               y: passwordTextField.bottom+10,
                               width: scrollView.width-60,
                               height: 52)

        


    }
    
    @objc private func loginButtonTapped(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let email=emailTextField.text,
              let password=passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count>=6 else{
            alertLoginError()
                  return
              }
        
        
        spinner.show(in: view)
        //FireBase Login
        
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let stronSelf=self else{
                return
            }
            
            DispatchQueue.main.async {
                stronSelf.spinner.dismiss(animated: true)
            }
            guard let user=authResult?.user, error==nil else{
                print("*** Login Firebase  Error *****")
                print(error)
                return
            }
                        
            UserDefaults.standard.set(email, forKey: "email")
            let safeEmail=DatabaseManger.safeEmail(email: email)
            
            //Get User Data
            DatabaseManger.shared.getData(path: safeEmail) {[weak self] result in
                switch result{
                case .success(let data):
                    guard let userData=data as? [String:Any],
                          let firstName=userData["first_name"] as? String,
                          let lastName=userData["last_name"] as? String else{
                        return
                    }
                    
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    print("name set \(firstName)")

                    print("user data at login time : \(data)")
                case .failure(let error):
                    print("error while getting user data :\(error)")
                }
            }
            
            print("user is login \(user)")
            self?.navigationController?.dismiss(animated: true)
//            })
//            stronSelf.navigationController?.dismiss(animated: true,completion: nil)
            

        }
            }
    
    private func alertLoginError(){
        let alert = UIAlertController(title: "Error",
                                      message: "Please Enter correct email or password",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismmis", style: .cancel,handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc=RegisterViewController()
        vc.title="Create New Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            loginButtonTapped()
        }
        return true
    }
}
