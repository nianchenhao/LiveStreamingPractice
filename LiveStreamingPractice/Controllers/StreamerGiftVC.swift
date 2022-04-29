//
//  StreamerGiftVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/4/28.
//

import UIKit
import Lottie

class StreamerGiftVC: UIViewController {
    var animationView: AnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    @IBAction func quitSendGiftView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func carGiftPress(_ sender: UIButton) {
        showAlert(title: "系統訊息", message: "確定花費鑽石購買", name: "carGift")
    }
    
    @IBAction func rocketGiftPress(_ sender: UIButton) {
        showAlert(title: "系統訊息", message: "確定花費鑽石購買", name: "rocketGift")
    }
    
    @IBAction func yachtGiftPress(_ sender: UIButton) {
        showAlert(title: "系統訊息", message: "確定花費鑽石購買", name: "yachtGift")
    }
    
    @IBAction func helicopterGiftPress(_ sender: UIButton) {
        showAlert(title: "系統訊息", message: "確定花費鑽石購買", name: "helicopterGift")
    }
    
    // MARK: - Function
    func showAlert(title: String, message: String, name: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "買下去", style: .default, handler: { [self] alertAction in
            animationView = .init(name: name)
            animationView?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            animationView?.center = self.view.center
            animationView?.contentMode = .scaleAspectFill
            animationView?.loopMode = .loop
            guard let animationView = animationView else {
                return
            }
            view.addSubview(animationView)
            animationView.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.animationView?.stop()
                self.animationView?.isHidden = true
                self.dismiss(animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: "先鼻要", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}
