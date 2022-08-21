//
//  ProfileViewController.swift
//  ChatNow
//
//  Created by uttam on 27/07/22.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data=[ProfileViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self,forCellReuseIdentifier: ProfileTableViewCell.identifier)
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: UserDefaults.standard.value(forKey: "name") as? String ?? "No Name",
                                     handle: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: UserDefaults.standard.value(forKey: "email") as? String ?? "No email",
                                     handle: nil))
        data.append(ProfileViewModel(viewModelType: .logout,
                                     title: "Log Out",
                                     handle: { [weak self] in
            let action=UIAlertController(title: "LogOut",
                                         message: "Are you sure ?",
                                         preferredStyle: .alert)
           
            action.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: {[weak self] _ in
                guard let strongSelf=self else{
                    return
                }
                print(" name user before sing out \(UserDefaults.standard.value(forKey: "name"))")

                UserDefaults.standard.set(nil, forKey: "name")
                UserDefaults.standard.set(nil, forKey: "email")
                print(" name user after sing out \(UserDefaults.standard.value(forKey: "name"))")

                print("sing out")

                do {
                    try Auth.auth().signOut()
                    self?.tabBarController!.selectedIndex = 0
                   
                    

                    
                } catch  {
                    print("Error: sing out ")
                }
            }))
            action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self?.present(action, animated: true)
        }))

        
        tableView.delegate=self
        tableView.dataSource=self
        tableView.tableHeaderView=createableHeader()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
      print("# viewWillAppear profile")
     
    }
    
    func createableHeader()->UIView?{
        guard let email=UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail=DatabaseManger.safeEmail(email: email)
        print("&&&& SafeEmauil \(safeEmail)")
        let fileName=safeEmail+"_profile_picture.png"
        let path="images/"+fileName
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        headerView.backgroundColor = .systemGreen
        let imageView=UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 42, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth=3
        imageView.layer.masksToBounds=true
        imageView.layer.cornerRadius=imageView.width/2
        headerView.addSubview(imageView)
        StrorageManger.shared.downloadURL(for: path) {[weak self ] result in
            guard let strongSelf=self else{
                return
            }
            
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url,completed: nil)
                
            case .failure(let error):
                print("error download url : \(error)")
            }
        }

        return headerView
        
    }
    
}


extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel=data[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handle?()
        
        
       
        
    }
    
}

class ProfileTableViewCell:UITableViewCell{
    static let identifier = "ProfileTableViewCell"
    public func setUp(with model:ProfileViewModel){
        textLabel?.text=model.title
        switch model.viewModelType{
        case .info:
            textLabel?.textAlignment = .center
            selectionStyle = .none
            textLabel?.font = .systemFont(ofSize: 23, weight: .bold)
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
            textLabel?.font = .systemFont(ofSize: 23, weight: .bold)


            
        }
        
    }
}
