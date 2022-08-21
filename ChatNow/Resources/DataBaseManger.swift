//
//  DataBaseManger.swift
//  ChatNow
//
//  Created by uttam on 28/07/22.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseManger{
    static let shared=DatabaseManger()
    
    private let dataBase=Database.database().reference()
    static func safeEmail(email:String)->String{
        var safeEmail=email.replacingOccurrences(of: ".", with: "-")
        safeEmail=safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    
}

extension DatabaseManger{
    public func getData(path:String,completion:@escaping (Result<Any,Error>)->Void){
        dataBase.child("\(path)").observeSingleEvent(of: .value) { snapShot in
            guard let value=snapShot.value else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}
//MARK: - User / Login  Mangement
extension DatabaseManger{
    
    public func isUserExists(with email:String,
                             completion: @escaping ((Bool) -> Void)){
        print("$$$ Function:isUserExists")
        var safeEmail=DatabaseManger.safeEmail(email: email)
        
        dataBase.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            print("inside user exists")
            print(snapshot.value)
            guard snapshot.value as? [String:Any] != nil else{
                completion(false)
                
                return
            }
            
            completion(true)
            
            
            
        })
    }
    
    
    ///   insert user data in firebase
    public func insertUser(with user:ChatAppUser,comletion:@escaping (Bool)->Void){
        print("$$$ Function:insertUser")
        
        dataBase.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ]) {[weak self] error, _ in
            guard error==nil else{
                print("failed to write to database ")
                comletion(false)
                return
                
            }
            /*
             user_collection ->
             [
             [
             user:"uttam bala"
             safeEmail:"email@gmail.com"
             
             ]
             ]
             */
            
            /// Create collection of user
            self?.dataBase.child("users").observeSingleEvent(of: .value) { snapShot in
                if var userCollection=snapShot.value as? [[String:String]]{
                    //append to user dictionary
                    let newElement=[
                        "name":user.firstName+" "+user.lastName,
                        "email":user.safeEmail
                    ]
                    
                    userCollection.append(newElement)
                    self?.dataBase.child("users").setValue(userCollection) { error, _ in
                        guard error==nil else{
                            print("error while set user collection : \(error)")
                            comletion(false)
                            return
                            
                        }
                        comletion(true)
                        
                        
                    }
                    
                }else{
                    //create new array
                    let newCollection:[[String:String]]=[
                        [
                            "name":user.firstName+" "+user.lastName,
                            "email":user.safeEmail
                        ]
                    ]
                    self?.dataBase.child("users").setValue(newCollection) { error, _ in
                        guard error==nil else{
                            print("error while set user collection : \(error)")
                            comletion(false)
                            return
                            
                        }
                        comletion(true)
                        
                    }
                }
                
            }
            //            comletion(true)
        }
        
    }
    public func getAllUser(completion:@escaping(Result<[[String:String]],Error>)->Void){
        dataBase.child("users").observeSingleEvent(of: .value) { snapShot in
            guard let value=snapShot.value as? [[String:String]] else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
        
    }
    public enum dataBaseError:Error{
        case failedToFetch
    }
    
    
}

struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAdress:String
    //let profilePicture:URL
    
    var safeEmail:String{
        var safeEmail=emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail=safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName:String{
        return "\(safeEmail)_profile_picture.png"
    }
}


//MARK: - Message Chat Mangement
extension DatabaseManger{
    
    /*
     Scema :
     
     Convestatio=>
     
     */
    
    ///create New conversion with new user
    public func createNewConversion(with otherUserEmail:String,name:String,firstMessage:Message,completion:@escaping(Bool)->Void){
        
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String,
              let currentName=UserDefaults.standard.value(forKey: "name") as? String else{
            return
        }
        let safeEmail=DatabaseManger.safeEmail(email: currentEmail)
        
        let refChild=dataBase.child("\(safeEmail)")
        refChild.observeSingleEvent(of: .value) {[weak self] snapShot in
            guard var userNode=snapShot.value as? [String: Any] else{
                print("user not found")
                completion(false)
                return
            }
            
            let messageDate=firstMessage.sentDate
            let dateString=ChatViewController.dateFormmater.string(from: messageDate)
            var message=""
            switch firstMessage.kind{
                
            case .text(let messageText):
                message=messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let converstationId="conversation_\(firstMessage.messageId)"
            let newConverstation:[String:Any]=[
                "id":converstationId,
                "other_user_email":otherUserEmail,
                "name":name,
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                    
                ]
                
                
            ]
            
            let recipent_newConverstation:[String:Any]=[
                "id":converstationId,
                "other_user_email":safeEmail,
                "name":currentName,
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                    
                ]
                
                
            ]
            
            ///update reciient conversation entry
            self?.dataBase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) {[weak self] snapShot in
                if var conversations=snapShot.value as? [[String:Any]]{
                    //append
                    conversations.append(recipent_newConverstation)
                    self?.dataBase.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else{
                    //create
                    self?.dataBase.child("\(otherUserEmail)/conversations").setValue([recipent_newConverstation])
                }
            }
            
            ///update current user
            if var conversations=userNode["conversations"] as? [[String:Any]]{
                conversations.append(newConverstation)
                userNode["conversations"]=conversations
                refChild.setValue(userNode) {[weak self] error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name,
                                                     conversationID: converstationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    //                    completion(true)
                }
                
                
            }else{
                
                //create new conversation array
                userNode["conversations"]=[newConverstation]
                refChild.setValue(userNode) {[weak self] error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name,
                                                     conversationID: converstationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                    
                }
            }
            
            
        }
        
    }
    
    public func finishCreatingConversation(name:String,conversationID:String,firstMessage:Message, completion:@escaping(Bool)->Void){
        //        {
        //            "id": String,
        //            "type": text, photo, video,
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        //        }
        
        let messageDate=firstMessage.sentDate
        let dateString=ChatViewController.dateFormmater.string(from: messageDate)
        var message=""
        switch firstMessage.kind{
            
        case .text(let messageText):
            message=messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentSafeEmail=DatabaseManger.safeEmail(email: currentEmail)
        
        let collectionMessage:[String:Any]=[
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "contend":message,
            "date":dateString,
            "sender_email":currentSafeEmail,
            "is_read":false,
            "name":name
            
        ]
        
        let value:[String:Any]=[
            "messages":[collectionMessage]
        ]
        print("adding id of messages : \(conversationID)")
        
        dataBase.child("\(conversationID)").setValue(value) { error, _ in
            guard error==nil else{
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    ///fetch and resturn all converstions for the user
    public func getAllConversion(for email:String,completation:@escaping(Result<[Converstion],Error>)->Void){
        dataBase.child("\(email)/conversations").observe(.value) { snapShot in
            print("#getAllConversion")
            print(snapShot.value)
            guard let value=snapShot.value as? [[String:Any]] else{
                completation(.failure(dataBaseError.failedToFetch))
                return
            }
            let conversation:[Converstion]=value.compactMap { dictionary in
                guard let conversationId=dictionary["id"] as? String,
                      let name=dictionary["name"] as? String,
                      let otherUserEmail=dictionary["other_user_email"] as? String,
                      let latestMessage=dictionary["latest_message"] as? [String:Any],
                      let date=latestMessage["date"] as? String,
                      let message=latestMessage["message"] as? String,
                      let isRead=latestMessage["is_read"] as? Bool else{
                    return nil
                }
                
                let latestMessageObject=LateshMessage(date: date,
                                                      text: message,
                                                      isRead: isRead)
                return Converstion(id: conversationId,
                                   name: name,
                                   otherUserEmail: otherUserEmail,
                                   lateshMessage: latestMessageObject)
                
            }
            
            completation(.success(conversation))
        }
    }
    
    ///get all message for converstation
    public func getAllMessageForConverstation(with id:String,completation:@escaping(Result<[Message],Error>)->Void){
        print("#getAllMessageForConverstation")
        dataBase.child("\(id)/messages").observe(.value) { snapShot in
            print(snapShot.value)
            guard let value=snapShot.value as? [[String:Any]] else{
                completation(.failure(dataBaseError.failedToFetch))
                return
            }
            print("pass 2")
            
            let messages:[Message]=value.compactMap { dictionary in
                
                guard let name=dictionary["name"] as? String,
                      let isRead=dictionary["is_read"] as? Bool,
                      let messageId=dictionary["id"] as? String,
                      let content=dictionary["contend"] as? String,
                      let senderEmail=dictionary["sender_email"] as? String,
                      let type=dictionary["type"] as? String,
                      let dateString=dictionary["date"] as? String,
                      let date=ChatViewController.dateFormmater.date(from: dateString)
                else{
                    return nil
                }
                print("pass 3")
                
                let sender=Sender(senderId: senderEmail,
                                  displayName: name)
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content))
                
                
            }
            
            completation(.success(messages))
        }
        
    }
    
    ///send mesage
    public func sendMessage(to conversation:String,otherUserEmail: String,name:String,newMessage:Message,completation:@escaping(Bool)->Void){
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String else{
            completation(false)
            return
        }
        print("#sendMessage")
        let currentSafeEmail=DatabaseManger.safeEmail(email: currentEmail)
        dataBase.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapShot in
            
            guard let stronSelf=self else{
                return
            }
            guard var currentMessage=snapShot.value as? [[String:Any]] else{
                completation(false)
                return
            }
            
            let messageDate=newMessage.sentDate
            let dateString=ChatViewController.dateFormmater.string(from: messageDate)
            var message=""
            switch newMessage.kind{
                
            case .text(let messageText):
                message=messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
          
            
            let newMessageEntiry:[String:Any]=[
                "id":newMessage.messageId,
                "type":newMessage.kind.messageKindString,
                "contend":message,
                "date":dateString,
                "sender_email":currentSafeEmail,
                "is_read":false,
                "name":name
                
            ]
            currentMessage.append(newMessageEntiry)
            
            print("#before appent")
            
            ///append in conversation database
            stronSelf.dataBase.child("\(conversation)/messages").setValue(currentMessage) { error, _ in
                guard error==nil else {
                    print("# error 1:\(error)")
                    completation(false)
                    return
                }
                
                stronSelf.dataBase.child("\(currentSafeEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                    print("#\(snapShot)")
                    var databaseEntryConversation=[[String:Any]]()
                    let updateLatestMaeesge:[String:Any]=[
                        "date":dateString,
                        "is_read":false,
                        "message":message
                        
                    ]
                    print("######### \(snapShot.value)")
                    
                    
                    if var currentUserConversation=snapShot.value as? [[String:Any]] {
                        print("#####in first")
                        
                        var targetConversation:[String:Any]?
                        var position:Int=0
                        for conversationDict in currentUserConversation {
                            if let currentId=conversationDict["id"] as? String ,
                               currentId==conversation {
                                targetConversation=conversationDict
                                
                                break
                            }
                            position+=1
                            
                            
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"]=updateLatestMaeesge
                            currentUserConversation[position]=targetConversation
                            databaseEntryConversation=currentUserConversation
                        }else{
                            let newConversation:[String:Any]=[
                                "id":conversation,
                                "other_user_email":DatabaseManger.safeEmail(email: otherUserEmail),
                                "name":name,
                                "latest_message":updateLatestMaeesge
                            ]
                            currentUserConversation.append(newConversation)
                            databaseEntryConversation=currentUserConversation
                        }
                        
                    }else{
                        print("#####in second")

                        let newConversation:[String:Any]=[
                            "id":conversation,
                            "other_user_email":DatabaseManger.safeEmail(email: otherUserEmail),
                            "name":name,
                            "latest_message":updateLatestMaeesge
                        ]
                        databaseEntryConversation=[newConversation]
                        
                        
                        
                        
                    }
                    print(" ######## \(databaseEntryConversation)")
                    
                    
                    //
                    stronSelf.dataBase.child("\(currentSafeEmail)/conversations").setValue(databaseEntryConversation) { error, _ in
                        
                        guard error==nil else{
                            completation(false)
                            return
                        }
                        
                        print("#before update recept")
                        
                        //update latest message for recipent user
                        stronSelf.dataBase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                            var databaseEntryConversation=[[String:Any]]()
                            let updateLatestMaeesge:[String:Any]=[
                                "date":dateString,
                                "is_read":false,
                                "message":message
                                
                            ]
                            guard let currentName=UserDefaults.standard.value(forKey: "name") as? String else{
                                return
                            }
                            
                            if var otherUserConversation=snapShot.value as? [[String:Any]] {
                                
                                var targetConversation:[String:Any]?
                                var position:Int=0
                                for conversationDict in otherUserConversation {
                                    if let currentId=conversationDict["id"] as? String ,
                                       currentId==conversation {
                                        targetConversation=conversationDict
                                        
                                        break
                                    }
                                    position+=1
                                    
                                    
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"]=updateLatestMaeesge
                                    otherUserConversation[position]=targetConversation
                                    databaseEntryConversation=otherUserConversation
                                }
                                else{
                                    let newConversation:[String:Any]=[
                                        "id":conversation,
                                        "other_user_email":currentSafeEmail,
                                        "name":currentName,
                                        "latest_message":updateLatestMaeesge
                                    ]
                                    otherUserConversation.append(newConversation)
                                    databaseEntryConversation=otherUserConversation
                                }
                                
                            }else{
                                let newConversation:[String:Any]=[
                                    "id":conversation,
                                    "other_user_email":currentSafeEmail,
                                    "name":currentName,
                                    "latest_message":updateLatestMaeesge
                                ]
                                databaseEntryConversation=[newConversation]
                                
                                
                                
                                
                            }
                            
                            
                            
                            let otherSafeEmail=DatabaseManger.safeEmail(email: otherUserEmail)
                            print(" ######## \(databaseEntryConversation)")

                            //
                            stronSelf.dataBase.child("\(otherSafeEmail)/conversations").setValue(databaseEntryConversation) { error, _ in
                                
                                guard error==nil else{
                                    completation(false)
                                    return
                                }
                                
                                completation(true)
                                
                            }
                            
                        }
                        
                        
                    }
                    
                }
                
                
            }
        }
    }
    
    public func deleteConversation(conversationId:String,completion:@escaping(Bool)->Void){
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        print("#deleteConversation")
        let currentSafeEmail=DatabaseManger.safeEmail(email: currentEmail)
        
        //get conversation for user
        let ref=dataBase.child("\(currentSafeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapShot in
            if var conversations=snapShot.value as? [[String:Any]] {
                var postion=0
                for conversation in conversations{
                    if let id=conversation["id"] as? String,
                       id==conversationId{
                        print("found id for delete")
                        break
                    }
                    postion+=1
                }
                
                conversations.remove(at: postion)
                ref.setValue(conversations) { error, _ in
                    guard error==nil else{
                        completion(false)
                        print("failed to write new conversation ")
                        return
                    }
                    print("deleted conversation")
                    completion(false)
                }
                
                
            }
            
        }
    }
    
    
    public func conversationExists(with targetEmail:String,completation:@escaping(Result<String,Error>)->Void){
        let receipentEmail=DatabaseManger.safeEmail(email: targetEmail)
        guard let currentEmail=UserDefaults.standard.value(forKey: "email") as? String else{
            //            completation(.failure(dataBaseError.failedToFetch))
            return
        }
        print("#conversationExists")
        let currentSafeEmail=DatabaseManger.safeEmail(email: currentEmail)
        
        
        dataBase.child("\(receipentEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
            guard let collection=snapShot.value as? [[String:Any]] else{
                completation(.failure(dataBaseError.failedToFetch))
                return
            }
            
            //itrate and find conversation
            if let conversation=collection.first(where: {
                guard let targetEmail=$0["other_user_email"] as? String else{
                    return false
                }
                return currentSafeEmail==targetEmail
            }){
                //get id
                guard let id=conversation["id"] as? String else{
                    completation(.failure(dataBaseError.failedToFetch))
                    return
                }
                completation(.success(id))
            }
            completation(.failure(dataBaseError.failedToFetch))
            return
        }
        
        
        
    }
}

