//
//  ChatUser.swift
//  NexSeedChatProject
//
//  Created by 城間海月 on 2019/12/11.
//  Copyright © 2019 Mizuki. All rights reserved.
//

import Foundation
import MessageKit

// 送信者の構造体を作成
struct ChatUser: SenderType {
    
    // ユーザーのID
    // FirebaseのAuthenticationのuidを今回は使う
    var senderId: String
    
    // 表示名
    var displayName: String
    
    // アイコン画像のURL
    var photoUrl: String
}
