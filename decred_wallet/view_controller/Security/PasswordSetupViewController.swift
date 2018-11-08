//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit
import PasswordStrength

class PasswordSetupViewController: UIViewController {

    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    
    @IBOutlet weak var lbPasswordStrengthLabel: UILabel!
    
    let passwordStrengthMeasurer = MEPasswordStrength()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        lbMatchIndicator.isHidden = true
        pbPasswordStrength.isHidden = true
        lbPasswordStrengthLabel.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PasswordSetupViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if tfPassword.text == tfConfirmPassword.text {
            lbMatchIndicator.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
            lbMatchIndicator.text = "PASSWORDS MATCH"
        }else{
            lbMatchIndicator.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            lbMatchIndicator.text = "PASSWORDS NOT MATCH"
        }
        if textField.tag == 5 { //password
            pbPasswordStrength.progress = passwordStrengthMeasurer.strength(forPassword: textField.text) as! Float
            pbPasswordStrength.progressTintColor = passwordStrengthMeasurer.strengthColor(forPassword: textField.text)
            pbPasswordStrength.isHidden = false
            lbPasswordStrengthLabel.isHidden = false
        }else{
            lbMatchIndicator.isHidden = false
        }
        return true
    }
}
