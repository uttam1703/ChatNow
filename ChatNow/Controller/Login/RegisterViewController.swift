//
//  RegisterViewController.swift
//  ChatNow
//
//  Created by uttam on 27/07/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    private let spinner=JGProgressHUD(style: .dark)

    private let scrollView:UIScrollView={
        let scrollView=UIScrollView()
        scrollView.clipsToBounds=true
        return scrollView
    }()
    
    private var imageView : UIImageView={
        let imageview = UIImageView()
        imageview.image=UIImage(systemName: "person.circle")
        imageview.tintColor = .gray
        imageview.contentMode = .scaleAspectFit
        imageview.layer.masksToBounds=true
        imageview.layer.borderWidth=2
        imageview.layer.borderColor = UIColor.lightGray.cgColor
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
        //image
//        field.leftView=UIImageView(image: UIImage(systemName: "mail"))
//        field.leftView=UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
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
    
    private let firstName:UITextField={
        let field=UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder="First Name"
        field.returnKeyType = .continue
        field.layer.cornerRadius=12
        field.layer.borderWidth=1
        field.layer.borderColor=UIColor.lightGray.cgColor
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "person")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        field.leftView = imageView
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    

    private let lastName:UITextField={
        let field=UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder="Last Name"
        field.returnKeyType = .continue
        field.layer.cornerRadius=12
        field.layer.borderWidth=1
        field.layer.borderColor=UIColor.lightGray.cgColor
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "person")
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
//        field.leftView=UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "lock")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        field.leftView = imageView
        field.leftViewMode = .always

//        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry=true
        return field
    }()

    private let registerButton:UIButton={
        let button=UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor( .white , for: .normal)
        button.layer.cornerRadius=12
        button.layer.masksToBounds=true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Create New Account"
//        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Register",
//                                                          style: .done,
//                                                          target: self,
//                                                          action: #selector(didTapRegister))
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        
        emailTextField.delegate=self
        passwordTextField.delegate=self
        // Do any additional setup after loading the view.
        // Add sub view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled=true
        scrollView.isUserInteractionEnabled=true
        
        let gesture=UITapGestureRecognizer(target: self, action: #selector(didChangeProfilePic))
        imageView.addGestureRecognizer(gesture)



    }
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        scrollView.frame=view.bounds
        let size=scrollView.width/3
        imageView.frame=CGRect(x: ((scrollView.width-size)/2),
                               y: 20,
                               width: size,
                               height: size)
        imageView.layer.cornerRadius=imageView.width/2.0
        firstName.frame=CGRect(x: 30,
                               y: imageView.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        lastName.frame=CGRect(x: 30,
                               y: firstName.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        emailTextField.frame=CGRect(x: 30,
                               y: lastName.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        passwordTextField.frame=CGRect(x: 30,
                               y: emailTextField.bottom+10,
                               width: scrollView.width-60,
                               height: 52)
        registerButton.frame=CGRect(x: 30,
                               y: passwordTextField.bottom+10,
                               width: scrollView.width-60,
                               height: 52)

        


    }
    
    @objc private func didChangeProfilePic(){
        print("tap")
        presentPhotoActionSheet()
    }
    
    @objc private func registerButtonTapped(){
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let firstNameStr=firstName.text,
              let lastNameStr=lastName.text,
              let email=emailTextField.text,
              let password=passwordTextField.text,
              !firstNameStr.isEmpty,
              !lastNameStr.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count>=6 else{
            alertLoginError(errorMessage: "Enter valid user information")
                  return
              }
        
        spinner.show(in: view)
        
        //FireBase Part
        DatabaseManger.shared.isUserExists(with: email,completion: { [weak self] exists in
            guard let stronSelf=self else{
                return
            }
            DispatchQueue.main.async {
                stronSelf.spinner.dismiss(animated: true)
            }
            print("inside user create method 1")
//            print(exit)
            guard !exists else{
                print("user alredy exit")
                self?.alertLoginError(errorMessage: "User Already Exits")
                return
            }
            print("inside user create method 2")

            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                print("inside user create method 3")

                guard let user=authResult?.user,  error==nil else{
                    print("****** user create firebase error ******")
                    print(error)
                    self?.alertLoginError(errorMessage: "Please check internet connection")
                    return
                }
                
//                UserDefaults.standard.set(nil, forKey: "name")
//                UserDefaults.standard.set(nil, forKey: "email")
                
                let chatUser=ChatAppUser(firstName: firstNameStr,
                                         lastName: lastNameStr,
                                         emailAdress: email)
                DatabaseManger.shared.insertUser(with:chatUser) { success in
                    
                    if success {
                        guard let image = stronSelf.imageView.image,
                              let data = image.pngData() else{
                                
                            return
                        }
                        let fileName=chatUser.profilePictureFileName
                        StrorageManger.shared.uploadrofilePicture(with: data, filename: fileName) { result in
                            switch result{
                            case .success(let downloadUrl):
                                print("$$$$$$$$$$$$$$$$$$$$$$$$$")
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            
                            case .failure(let error):
                                print("stronage manger error \(error)")
                            }
                        }
                        
                    }
                }
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set("\(firstNameStr) \(lastNameStr)", forKey: "name")
                print("created user \(user)")
                stronSelf.navigationController?.dismiss(animated: true,completion: nil)

            }
            
        })
    }
       
        
                                           
                                           
    private func alertLoginError(errorMessage:String){
        let alert = UIAlertController(title: "Error",
                                      message: errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismmis", style: .cancel,handler: nil))
        present(alert, animated: true)
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

extension RegisterViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
       if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to upload profile picture ?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler:{[weak self] _ in
            self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
            self?.presentPhotoPicker()

            
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc=UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing=true
        vc.delegate = self
        present(vc, animated: true)
        
        
    }
    
    func presentPhotoPicker(){
        let vc=UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate=self
        vc.allowsEditing=true
        present(vc, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
        }
        picker.dismiss(animated: true,completion: nil)
//        let selectedImage=picker.im
        imageView.image=image
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


