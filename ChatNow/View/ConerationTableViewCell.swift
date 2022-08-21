//
//  ConerationTableViewCell.swift
//  ChatNow
//
//  Created by uttam on 02/08/22.
//

import UIKit
import SDWebImage

class ConerationTableViewCell: UITableViewCell {
    static let identifier="ConerationTableViewCell"
    
    private let userImageView:UIImageView={
        let imageview=UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius=50
        imageview.layer.masksToBounds=true
        return imageview
    }()
    
    private let userLabel:UILabel={
        let label=UILabel()
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private var userMessageLabel:UILabel={
        let label=UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines=0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame=CGRect(x: 10,
                                   y: 10,
                                   width: 100,
                                   height: 100)
        userLabel.frame=CGRect(x: userImageView.right+10,
                                   y: 10,
                               width: contentView.width-20-userImageView.width,
                               height: (contentView.height-20)/2)
        userMessageLabel.frame=CGRect(x: userImageView.right+10,
                                      y: userLabel.bottom+10,
                                      width: contentView.width-20-userImageView.width,
                                      height: (contentView.height-20)/2)



    }
    
    public func configure(with model:Converstion){
        
        self.userMessageLabel.text=model.lateshMessage.text
        self.userLabel.text=model.name
        
        let pathImage="images/\(model.otherUserEmail)_profile_picture.png"
        StrorageManger.shared.downloadURL(for: pathImage) {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
              
                
                print("Get URL")
            case .failure(let error):
                print("error while download image: \(error)")
            }
        }
        
    }
    
}
