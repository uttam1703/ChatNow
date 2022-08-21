//
//  NewConversionViewController.swift
//  ChatNow
//
//  Created by uttam on 27/07/22.
//

import UIKit
import JGProgressHUD

class NewConversionViewController: UIViewController {
    
    public var completation:((SearchResult)->(Void))?
    
    private let spinner=JGProgressHUD(style: .dark)
    private var users=[[String:String]]()
    private var resultData=[SearchResult]()
    

    private var hasFetchUser:Bool=false
    
    private let searchBar:UISearchBar={
        let search=UISearchBar()
        search.placeholder="Search for User"
        return search
    }()
    
    private let tableView:UITableView={
        let table=UITableView()
        table.isHidden=true
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        return table
    }()
    
    private let noUserLabel:UILabel={
        let label=UILabel()
        label.isHidden=true
        label.text="No User found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noUserLabel)
        view.addSubview(tableView)
        tableView.delegate=self
        tableView.dataSource=self
        view.backgroundColor = .white
        searchBar.delegate=self
        navigationController?.navigationBar.topItem?.titleView=searchBar
        navigationItem.rightBarButtonItem=UIBarButtonItem(title:"cancel",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(didTapCancelbar))
        searchBar.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame=view.bounds
        noUserLabel.frame=CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func didTapCancelbar(){
        dismiss(animated: true,completion: nil)
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

extension NewConversionViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model=resultData[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.config(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start new conversion
        let targetUserData=resultData[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completation?(targetUserData)

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

extension NewConversionViewController:UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("click on serach 1")

        guard let text=searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        print("click on serach ")
        searchBar.resignFirstResponder()
        resultData.removeAll()
        spinner.show(in: view)
        searchUser(query: text)
    }
    
    func searchUser(query:String){
        if hasFetchUser{
            //filter data
            filterUser(with: query)
        }else{
            //fetch new user data
            DatabaseManger.shared.getAllUser {[weak self] result in
                guard let strongSelf=self else{
                    return
                }
                switch result{
                case .success(let fetachData):
                    strongSelf.hasFetchUser=true
                    strongSelf.users=fetachData
                    strongSelf.filterUser(with: query)
                case .failure(let error):
                    print("error while fech user data : \(error)")
                    
                }
            }
            
        }

    }
    
    func filterUser(with term:String){
        
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail=DatabaseManger.safeEmail(email: currentEmail)
       
        spinner.dismiss(animated: true)
        
        let results: [SearchResult] = users.filter({
                    guard let email = $0["email"], email != safeEmail else {
                        return false
                    }

                    guard let name = $0["name"]?.lowercased() else {
                        return false
                    }

                    return name.hasPrefix(term.lowercased())
                }).compactMap({

                    guard let email = $0["email"],
                        let name = $0["name"] else {
                        return nil
                    }

                    return SearchResult(name: name, email: email)
                })
        self.resultData=results
        
        updateUITable()
    }
    
    
    func updateUITable(){
        if resultData.isEmpty {
            noUserLabel.isHidden=false
            tableView.isHidden=true
        }else{
            noUserLabel.isHidden=true
            tableView.isHidden=false
            tableView.reloadData()
        }
        
    }
}
