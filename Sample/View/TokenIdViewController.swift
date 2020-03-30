//
//  TokenIdViewController.swift
//  Sample
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import UIKit

class TokenIdViewController: UIViewController, UITextFieldDelegate  {
    @IBOutlet weak var TokenLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TokenLabel.text = UserDefaults.standard.object(forKey: "TokenID") as? String
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
    * Called when the user click on the view (outside the UITextField).
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
