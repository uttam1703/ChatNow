//
//  ProfileViewModel.swift
//  ChatNow
//
//  Created by uttam on 06/08/22.
//

import Foundation

enum profileViewModelType{
    case info,logout
}

struct ProfileViewModel{
    let viewModelType:profileViewModelType
    let title:String
    let handle: (()->Void)?
}
