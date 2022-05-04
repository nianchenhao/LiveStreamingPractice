//
//  StreamerGiftVC.swift
//  LiveStreamingPractice
//
//  Created by Robert_Nian on 2022/4/28.
//

import UIKit
import Lottie

protocol StreamerGiftVCDelegate: AnyObject {
    func sendGift(giftName: String)
}

class StreamerGiftVC: UIViewController {
    var animationView: AnimationView?
    weak var delegate: StreamerGiftVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    @IBAction func quitSendGiftView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func carGiftPress(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PayDiamond", comment: "確定花費鑽石購買"), name: "carGift")
        delegate?.sendGift(giftName: NSLocalizedString("CarGift", comment: "瑪莎拉蒂"))
    }
    
    @IBAction func rocketGiftPress(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PayDiamond", comment: "確定花費鑽石購買"), name: "rocketGift")
        delegate?.sendGift(giftName: NSLocalizedString("RocketGift", comment: "戰神火箭"))
    }
    
    @IBAction func yachtGiftPress(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PayDiamond", comment: "確定花費鑽石購買"), name: "yachtGift")
        delegate?.sendGift(giftName: NSLocalizedString("YachtGift", comment: "公主遊艇"))
    }
    
    @IBAction func helicopterGiftPress(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("SystemMessage", comment: "系統訊息"), message: NSLocalizedString("PayDiamond", comment: "確定花費鑽石購買"), name: "helicopterGift")
        delegate?.sendGift(giftName: NSLocalizedString("HelicopterGift", comment: "海王直升機"))
    }
    
    // MARK: - Function
    func showAlert(title: String, message: String, name: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("BuyIt", comment: "買下去"), style: .default, handler: { [self] alertAction in
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
        let cancelAction = UIAlertAction(title: NSLocalizedString("NotBuyIt", comment: "先不要"), style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}
