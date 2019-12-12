//
//  SettingViewController.swift
//  NexSeedChatProject
//
//  Created by 城間海月 on 2019/12/12.
//  Copyright © 2019 Mizuki. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emaiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 現在ログインしている人を取得
        let user = Auth.auth().currentUser!
        
        nameLabel.text = user.displayName
        emaiLabel.text = user.email
        
        // URLを元に画像データを取得
        let data = try! Data(contentsOf: user.photoURL!)
        
        // 取得したデータを元にImageを作成
        let image = UIImage(data: data)
        
        imageView.image = image
    }
    
    @IBAction func didClickLogoutButton(_ sender: UIButton) {
        // ログアウト
        try! Auth.auth().signOut()
    }
    
}
