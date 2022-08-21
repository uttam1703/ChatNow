//
//  ConversationsModels.swift
//  ChatNow
//
//  Created by uttam on 06/08/22.
//

import Foundation
import UIKit
import FirebaseAuth
import JGProgressHUD

struct Converstion{
    let id:String
    let name:String
    let otherUserEmail:String
    let lateshMessage:LateshMessage
}
struct LateshMessage{
    let date:String
    let text:String
    let isRead:Bool
}
