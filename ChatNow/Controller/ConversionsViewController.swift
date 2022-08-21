//
//  ViewController.swift
//  ChatNow
//
//  Created by uttam on 27/07/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class ConversionsViewController: UIViewController {
    
    private let spinner=JGProgressHUD(style: .dark)
    private var conversations=[Converstion]()
    
    
    private let tableView:UITableView={
        let table=UITableView()
        table.isHidden=true
        table.register(ConerationTableViewCell.self, forCellReuseIdentifier:ConerationTableViewCell.identifier)
        //        table.
        return table
    }()
    
    var data=["Name User"]
    
    private let noConversionLabel:UILabel={
        let label=UILabel()
        label.text="No Conversion"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden=true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .add,
                                                          target: self,
                                                          action: #selector(didTapComposed))
        navigationItem.rightBarButtonItem?.tintColor = .black
        view.addSubview(tableView)
        view.addSubview(noConversionLabel)
        setTableView()
//        fetchNewConversion()
        startReadingConversation()
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf=self else{
                return
            }
            strongSelf.startReadingConversation()
        })
        
        
    }
    private func startReadingConversation(){
        guard let email=UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        
        print("### starting conversation fetch...startReadingConversation")
        if let observer = loginObserver {
                   NotificationCenter.default.removeObserver(observer)
        }
        let safeEmail=DatabaseManger.safeEmail(email: email)
        DatabaseManger.shared.getAllConversion(for: safeEmail) {[weak self] result in
            switch result{
            case .success(let conversation):
                guard !conversation.isEmpty else{
                    self?.tableView.isHidden=true
                    self?.noConversionLabel.isHidden=false
                    return
                }
                self?.noConversionLabel.isHidden=true
                self?.tableView.isHidden=false
                self?.conversations=conversation
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                print("get all convesation")
            case .failure(let error):
                self?.tableView.isHidden=true
                self?.noConversionLabel.isHidden=false

                print("error : \(error)")
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame=view.bounds
        noConversionLabel.frame = CGRect(x: 10,
                                         y: (view.height-100)/2,
                                         width: view.width-20,
                                         height: 100)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        print("####view did apper ")
        
    }
    
    @objc private func didTapComposed(){
        let vc=NewConversionViewController()
        vc.completation={[weak self] result in
            print("#### completation of serch result\(result.email)")
            guard let stronSelf=self else{
                return
            }
            
            
            let cureentConversation=stronSelf.conversations
            
            if let targetConversation=cureentConversation.first(where: {
                $0.otherUserEmail==DatabaseManger.safeEmail(email: result.email)
            }){
                let chatVC=ChatViewController(with: targetConversation.otherUserEmail,id: targetConversation.id)
                chatVC.isNewConversion=false
                chatVC.title=targetConversation.name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                stronSelf.navigationController?.pushViewController(chatVC, animated: true)
            }else{
                
                self?.createNewConversion(result: result)
            }
        }
        let navVc=UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    private func createNewConversion(result:SearchResult){
        let name=result.name
        var email=result.email
        
        let safeEmail = DatabaseManger.safeEmail(email: result.email)
        
        //check for new conversation
        DatabaseManger.shared.conversationExists(with: safeEmail) {[weak self] result in
            switch result{
            case .success(let conversationId):
                let chatVC=ChatViewController(with: safeEmail,id: conversationId)
                chatVC.isNewConversion=false
                chatVC.title=name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(chatVC, animated: true)
                
            case .failure(_):
                let chatVC=ChatViewController(with: safeEmail,id: nil)
                chatVC.isNewConversion=true
                chatVC.title=name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(chatVC, animated: true)

            }
        }
        
    }
    
    private func validateAuth(){
        //        print(Auth.auth().currentUser?.email)
        if Auth.auth().currentUser==nil{
            let vc=LoginViewController()
            let nav=UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }else{
            startReadingConversation()
        }
        
    }
    
    private func setTableView(){
        tableView.delegate=self
        tableView.dataSource=self
    }
    
    
    
    
}


extension ConversionsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("conversation count : \(conversations.count)")
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model=conversations[indexPath.row]
        print("@@@@@ \(model.otherUserEmail)")
        let cell=tableView.dequeueReusableCell(withIdentifier: ConerationTableViewCell.identifier, for: indexPath) as! ConerationTableViewCell
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let model=conversations[indexPath.row]
        openConversation(model)
        
        
        
    }
    
    func openConversation(_ model:Converstion){
        
        let chatVC=ChatViewController(with: model.otherUserEmail,id: model.id)
        chatVC.title=model.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            let convesationId=conversations[indexPath.row].id
            
            DatabaseManger.shared.deleteConversation(conversationId: convesationId) {[weak self] sucess in
                if sucess{
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    print("deleted sucess")
                }else{
                    print("deleted fail")
                }
            }
            
            tableView.endUpdates()
        }
    }
    
    
}



