//
//  ChatViewController.swift
//  NexSeedChatProject
//
//  Created by 城間海月 on 2019/12/11.
//  Copyright © 2019 Mizuki. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    // 部屋のドキュメントIDをもらう変数
    var documentId = ""
    
    // 表示するメッセージを全件もつ配列
    var messages: [Message] = [] {
        didSet {
            messagesCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        // FireStoreに接続
        let db = Firestore.firestore()
        
        // roomsコレクション → 今の部屋のドキュメント → messagesコレクションを監視
        db.collection("rooms").document(documentId).collection("messages").order(by: "sentDate").addSnapshotListener { (snapshot, error) in
            
            guard let docs = snapshot?.documents else {
                // documentsがnilの場合、処理中断
                return
            }
            
            // 最新のメッセージを入れる変数
            // ドキュメントをループして、メッセージの配列を作成
            var results: [Message] = []
            
            for doc in docs {
                
                let uid = doc.get("uid") as! String
                let name = doc.get("name") as! String
                let photoUrl = doc.get("photoUrl") as! String
                let text = doc.get("text") as! String
                let sentDate = doc.get("sentDate") as! Timestamp
                
                // メッセージの送信者情報を作成
                let chatUser = ChatUser(senderId: uid, displayName: name, photoUrl: photoUrl)
                
                // メッセージを作成
                let message = Message(text: text, sender: chatUser, messageId: doc.documentID, sentDate: sentDate.dateValue())
                
                results.append(message)
            }
            
            self.messages = results
        }
        
    }

}

extension ChatViewController: MessagesDataSource {
    
    // 現在のログイン者の設定
    func currentSender() -> SenderType {
        
        // 現在ログインしている人を取得
        let user = Auth.auth().currentUser!
        
        // ログイン情報から設定に必要なデータを取得
        let uid = user.uid
        let displayName = user.displayName!
        let photoUrl = user.photoURL?.absoluteString
        
        // ログイン情報を返す
        return ChatUser(senderId: uid, displayName: displayName, photoUrl: photoUrl!)
    }
    
    // 表示するメッセージを設定
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        // 全メッセージをもつ配列から、表示するメッセージを1件取得して返す
        return messages[indexPath.section]
    }
    
    // 表示するメッセージの件数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return messages.count
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
    // アバター画像の設定
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        // メッセージの取得
        let message = messages[indexPath.section]
        
        // このメッセージの送信者を取得
        let user = message.sender as! ChatUser
        
        // 文字のURLをURL型に変換
        let url = URL(string: user.photoUrl)
        
        // URLを元に画像データの取得
        let data = try! Data(contentsOf: url!)
        
        // 取得したデータを元に、ImageViewを作成
        let image = UIImage(data: data)
        
        // ImageViewと名前を元にアバターアイコンを作成
        let avatar = Avatar(image: image, initials: user.displayName)
        
        // 完成したアイコンを配置
        avatarView.set(avatar: avatar)
    }
    
    // 背景色の設定
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if isFromCurrentSender(message: message) {
            // 自分のメッセージの場合
            return .systemBlue
        } else {
            // 他人のメッセージの場合
            return .systemGreen
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        if isFromCurrentSender(message: message) {
            // 自分のメッセージの場合
            return .bubbleTail(.bottomRight, .curved)
        } else {
            // 他人のメッセージの場合
            return .bubbleTail(.bottomLeft, .curved)
        }
    }
    
}

extension ChatViewController: MessageCellDelegate {
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    // 送信ボタンがクリックされた時の処理
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // 現在ログインしているユーザーを取得
        let user = Auth.auth().currentUser!
        
        // FireStoreに接続
        let db = Firestore.firestore()
        
        // roomsコレクション → 今の部屋のドキュメント → messagesコレクションに以下の情報を追加
           // - uid: ログインユーザーのuid
           // - name: ログインユーザーの表示名
           // - photoUrl: ログインユーザーのPhotoUrl
           // - text: メッセージの本文
           // - sentDate: 送信日時
        db.collection("rooms").document(documentId).collection("messages").addDocument(data: [
            "uid": user.uid,
            "name": user.displayName!,
            "photoUrl": user.photoURL?.absoluteString as Any,
            "text": text,
            "sentDate": Date()
        ])
        
        // 入力欄の初期化　inputBarが入力欄
        inputBar.inputTextView.text = ""
        
    }
    
}
