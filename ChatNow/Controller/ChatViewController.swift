//
//  ChatViewController.swift
//  ChatNow
//
//  Created by uttam on 30/07/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage



class ChatViewController: MessagesViewController{
    
    public var currentUserURL:URL?
    public var otherUserURL:URL?
    
    public static var dateFormmater:DateFormatter={
        let date=DateFormatter()
        date.dateStyle = .medium
        date.timeStyle = .long
        date.locale = .current
        return date
    }()
    
    public let otherEmailUser:String
    public var conversationId:String?
    public var isNewConversion=false
    
    
    private var messages=[Message]()
    private var selfSender:Sender?{
        guard let email=UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail=DatabaseManger.safeEmail(email: email)
       return  Sender(senderId: safeEmail,
                              displayName: "Me")
    }

    init(with email:String,id:String?) {
        self.otherEmailUser=email
        self.conversationId=id
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .green
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate=self
        
        
        
//        message.append(Message(sender: selfSender
//                               , messageId: "1",
//                               sentDate: Date(),
//                               kind: .text("hello uttam")))
//        message.append(Message(sender: selfSender
//                               , messageId: "2",
//                               sentDate: Date(),
//                               kind: .text("how are you what are you doing")))

        // Do any additional setup after loading the view.
    }
    
    func listenForMessage(id:String,shouldScrollToBottom:Bool){
        DatabaseManger.shared.getAllMessageForConverstation(with: id) {[weak self] result in
            switch result{
            case .success(let messagesData):
                print("message : \(messagesData)")
                guard !messagesData.isEmpty else{
                    return
                }
                
                self?.messages=messagesData
                print("%%% get messge first \(self?.messages[0].sender.senderId)")
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                print("get all messages in chatview")
            case .failure(let error):
                print("error message at chat : \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId=conversationId{
            listenForMessage(id:conversationId,shouldScrollToBottom: true)
        }

    }

}


extension ChatViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender=self.selfSender,
        let messageId=createMessageId()
        else{
            return
        }
        print("sending : \(text)")
        let safeEmail=DatabaseManger.safeEmail(email: otherEmailUser)
        print("%%%% in massege send :\(selfSender.senderId)")
        let message=Message(sender: selfSender,
                            messageId: messageId,
                            sentDate: Date(),
                            kind: .text(text))
        
        if isNewConversion{
            //create onvocetation in database
            
            print("new message")
            
            DatabaseManger.shared.createNewConversion(with: otherEmailUser,name:self.title ?? "User",firstMessage: message) {[weak self]sucess in
                if sucess{
                    self?.isNewConversion=false
                    let newConversationId="conversation_\(message.messageId)"
                    self?.conversationId=newConversationId
                    self?.listenForMessage(id: newConversationId, shouldScrollToBottom: true)
                    
                    self?.messageInputBar.inputTextView.text=nil

                    print("message send")
                }else{
                    print("messgae did't send")
                }
            }
            
            
        }else{
            
            guard let conversation=conversationId,
                  let name=self.title else{
                return
            }
            //append to exiting conversion data
            DatabaseManger.shared.sendMessage(to: conversation,otherUserEmail: safeEmail,name: name, newMessage: message) {[weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text=nil
                    print("message send")
                }else{
                    print("message failed to send")
                }
            }
            
        }
    }
    
    public func createMessageId()->String?{
        guard let currentEmailEmail=UserDefaults.standard.value(forKey: "email") as? String
        else{
            return nil
        }
        let safeEmail=DatabaseManger.safeEmail(email: currentEmailEmail)
        let dateString=ChatViewController.dateFormmater.string(from: Date())
        let newIdentifier="\(otherEmailUser)_\(safeEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}
extension ChatViewController:MessagesDataSource,MessagesDisplayDelegate,MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        if let sender=selfSender{
            return sender
        }
        fatalError("sender email is nil ")

        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        print("******\(messages[indexPath.section].sender.displayName)")
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender=message.sender
        if sender.senderId == selfSender?.senderId{
            return .link
        }
        return .lightGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender=message.sender
        print("%%%%  \(sender.senderId)  -> \(selfSender?.senderId)")
        if sender.senderId==selfSender?.senderId{
            //current user image
            if  let userPhotoURL=self.currentUserURL{
                //alredy download url image
                avatarView.sd_setImage(with: userPhotoURL,completed: nil)
                
            }else{
                // fetch image url from firebase
                guard let emailCurrent=UserDefaults.standard.value(forKey: "email") as? String else{
                    return
                }
                let safeEmail=DatabaseManger.safeEmail(email: emailCurrent)
                let path="images/\(safeEmail)_profile_picture.png"
                StrorageManger.shared.downloadURL(for: path) {[weak self] result in
                    switch result{
                    case .success(let url):
                        self?.currentUserURL=url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url,completed: nil)
                        }
                    case .failure(let error):
                        print("failed download profile image :\(error)")
                    }
                    
                }
                
                
                
            }
            
        }else{
            //other user image
            if  let userPhotoURL=self.otherUserURL{
                //alredy download url image
                avatarView.sd_setImage(with: userPhotoURL,completed: nil)
                
            }else{
                // fetch image url from firebase
                let safeEmail=DatabaseManger.safeEmail(email: self.otherEmailUser)
                let path="images/\(safeEmail)_profile_picture.png"
                StrorageManger.shared.downloadURL(for: path) {[weak self] result in
                    switch result{
                    case .success(let url):
                        self?.otherUserURL=url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url,completed: nil)
                        }
                    case .failure(let error):
                        print("failed download profile image :\(error)")
                    }
                    
                }
                
                
                
            }
            
        }
    }
    
    
}

extension ChatViewController: MessageCellDelegate {}
