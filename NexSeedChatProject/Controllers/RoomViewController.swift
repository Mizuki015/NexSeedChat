//
//  RoomViewController.swift
//  NexSeedChatProject
//
//  Created by 城間海月 on 2019/12/10.
//  Copyright © 2019 Mizuki. All rights reserved.
//

import UIKit
import Firebase
import RevealingSplashView

class RoomViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    // チャット部屋を全件もつ配列
    var rooms: [Room] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // スプラッシュを表示するか判断する
        if didDisplaySplashFlag == false {
            
            // まだスプラッシュを表示していなかったら
            showSplashView()
            
            didDisplaySplashFlag = true
        }
        
        // FireStoreに接続
        let db = Firestore.firestore()
        
        db.collection("rooms").order(by: "createdAt", descending: false).addSnapshotListener { (querySnapshot, error) in
            
            // 最新のroomsコレクションの中身を取得
            guard let documents = querySnapshot?.documents else {
                // roomsコレクションの中身がnilの場合、処理を中断
                // 中身がある場合は、変数documentsに中身を全て入れる
                return
            }
            
            // 結果を入れる配列
            var results: [Room] = []
            
            // ドキュメントをfor文を使ってループする
            for document in documents {
                let name = document.get("name") as! String
                let room = Room(name: name, documentId: document.documentID)
                results.append(room)
            }
            print(results)
            // テーブルに表示する変数roomsを全結果の入ったresultsで上書き
            self.rooms = results
            
        }
        
    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        // 部屋の名前が入力されたかチェック
        if textField.text == "" {
            return
        }
        
        // FIreStoreに接続
        let db = Firestore.firestore()
        
        // 部屋をFireStoreに作成
        db.collection("rooms").addDocument(data: [
            
            "name": textField.text!,
            "createdAt": FieldValue.serverTimestamp()
        ]) {error in
            
            if let error = error {
                // エラーが発生した場合
                // (変数errorがnilでない場合、エラー情報を変数errorに入れる))
                print("エラーが発生しました")
            } else {
                // エラーが発生しなかった場合
                print("正常に作動しています")
            }
        }
        
        // TextFieldの値をクリアする
        textField.text = ""
    }
    
    // スプラッシュ画面を表示するメソッド
    func showSplashView () {
        
        // スプラッシュ画面の作成
        let splashView = RevealingSplashView(
            iconImage: UIImage(named: "seedkun")!,
            iconInitialSize: CGSize(width: 250, height: 250),
            backgroundColor: UIColor(red: 79/255, green: 171/255, blue: 255/255, alpha: 1)
        )
        
        // スプラッシュのアニメーション設定
        splashView.animationType = .swingAndZoomOut
        // 画面に表示
        self.tabBarController?.view.addSubview(splashView)
        // アニメーション開始
        splashView.startAnimation{
            // アニメーション終了時の処理
        }
        
    }
    
}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを名前と行番号で取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // 配列から表示する部屋情報を1件取得
        let room = rooms[indexPath.row]
        
        // セルに名前を設定
        cell.textLabel?.text = room.name
        cell.accessoryType = .disclosureIndicator
        
        // セルを返す
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 今回クリックされた部屋情報を取得
        let room = rooms[indexPath.row]
       
        // セルの選択状態(グレー色になるやつ)を解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        // チャット画面に遷移
        performSegue(withIdentifier: "toRoom", sender: room.documentId)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toRoom" {
            let ChatVC = segue.destination as! ChatViewController
            ChatVC.documentId = sender as! String
        }
    }
    
}
