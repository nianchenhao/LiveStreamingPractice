//
//  StreamerInfoVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/4/28.
//

import UIKit

class StreamerInfoVC: UIViewController {

    @IBOutlet weak var streamerInfoView: UIView!
    @IBOutlet weak var followButton: UIButton!
    var follow = false
    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        streamerInfoView.layer.cornerRadius = 20
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkFollow()
    }
    
    @IBAction func quitButtonPress(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func followButtonPress(_ sender: UIButton) {
        if follow == false {
            follow = true
            userDefaults.setValue(follow, forKey: "streamerFollow")
            followButton.setTitle("關注中", for: .normal)
            self.view.makeToast("關注成功", position: .center)
            follow = true
        } else {
            follow = false
            userDefaults.setValue(follow, forKey: "streamerFollow")
            followButton.setTitle("關注", for: .normal)
            self.view.makeToast("取消關注", position: .center)
        }
    }
    
    func checkFollow() {
        //拿看看值，沒拿到的話直接return出去
        guard
            let defaultFollow = userDefaults.value(forKey: "streamerFollow") as? Bool
        else {
            print("沒存過值")
            return
        }
        print("已存過值 為\(defaultFollow)")
        //修改follow
        follow = defaultFollow
        
        //如果為true 修改按鈕的title
        guard follow == true else{
            return
        }
        followButton.setTitle("關注中", for: .normal)
    }
    

}
