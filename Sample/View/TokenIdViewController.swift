//
//  TokenIdViewController.swift
//  Sample
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import UIKit
import WoosmapGeofencing

class TokenIdViewController: UIViewController, UITextFieldDelegate  {
    @IBOutlet weak var TokenLabel: UITextField!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var searchAPISwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TokenLabel.text = UserDefaults.standard.object(forKey: "TokenID") as? String
        trackingSwitch.setOn(WoosmapGeofencing.shared.getTrackingState(), animated: false)
        trackingSwitch.addTarget(self,action: #selector(disableEnableTracking), for: .touchUpInside)
        searchAPISwitch.setOn(WoosmapGeofencing.shared.getSearchAPIRequestEnable(), animated: false)
        searchAPISwitch.addTarget(self,action: #selector(disableEnableSearchAPI), for: .touchUpInside)
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
    
    
    @objc func disableEnableTracking(){
        if trackingSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "TrackingEnable")
            WoosmapGeofencing.shared.setTrackingEnable(enable: true)
        }else {
            UserDefaults.standard.setValue(false, forKey: "TrackingEnable")
            WoosmapGeofencing.shared.setTrackingEnable(enable: false)
        }
    }
    
    @objc func disableEnableSearchAPI(){
        if searchAPISwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "SearchAPIEnable")
            WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: true)
        }else {
            UserDefaults.standard.setValue(false, forKey: "SearchAPIEnable")
            WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: false)
        }
    }


}
