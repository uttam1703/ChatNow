//
//  NewConversationTableViewCell.swift
//  ChatNow
//
//  Created by uttam on 06/08/22.
//

import UIKit

class NewConversationTableViewCell: UITableViewCell {

    static let identifier = "NewConversationCell"
    
    private let uiimage:UIImageView={
        let imageView=UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius=35
        imageView.layer.masksToBounds=true
        return imageView
    }()
    
    private let userNameLabel:UILabel={
        let label=UILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(uiimage)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        uiimage.frame=CGRect(x: 10, y: 10, width: 70, height: 70)
        userNameLabel.frame=CGRect(x: uiimage.right+10,
                                   y: 20,
                                   width: contentView.width-20-uiimage.width,
                                   height: 50)
    }
    
    public func config(with model:SearchResult){
        userNameLabel.text=model.name
        
        let path = "images/\(model.email)_profile_picture.png"
        StrorageManger.shared.downloadURL(for: path) {[weak self] result in
            
            switch result{
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.uiimage.sd_setImage(with: url,completed: nil)
                }
            case .failure(let error):
                print("failde to get image : \(error)")
                
            }
        }
    }

}
