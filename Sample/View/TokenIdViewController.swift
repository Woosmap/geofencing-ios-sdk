//
//  TokenIdViewController.swift
//  Sample
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import UIKit
import WoosmapGeofencing

class TokenIdViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var TokenLabel: UITextField!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var refreshAllTimeSwitch: UISwitch!
    @IBOutlet weak var searchAPISwitch: UISwitch!
    @IBOutlet weak var removeAllRegionsButton: UIButton!
    @IBOutlet weak var testDataButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        TokenLabel.text = UserDefaults.standard.object(forKey: "TokenID") as? String
        trackingSwitch.setOn(WoosmapGeofencing.shared.getTrackingState(), animated: false)
        trackingSwitch.addTarget(self, action: #selector(disableEnableTracking), for: .touchUpInside)
        refreshAllTimeSwitch.setOn(WoosmapGeofencing.shared.getModeHighfrequencyLocation(), animated: false)
        refreshAllTimeSwitch.addTarget(self, action: #selector(disableEnableRefresh), for: .touchUpInside)
        searchAPISwitch.setOn(WoosmapGeofencing.shared.getSearchAPIRequestEnable(), animated: false)
        searchAPISwitch.addTarget(self, action: #selector(disableEnableSearchAPI), for: .touchUpInside)

        removeAllRegionsButton.addTarget(self, action: #selector(removeAllRegions), for: .touchUpInside)
        testDataButton.addTarget(self, action: #selector(testData), for: .touchUpInside)
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildString = "Version: \(appVersion ?? "").\(build ?? "")"
        
        versionLabel.text = buildString
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

    @objc func disableEnableTracking() {
        if trackingSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "TrackingEnable")
            WoosmapGeofencing.shared.setTrackingEnable(enable: true)
        } else {
            UserDefaults.standard.setValue(false, forKey: "TrackingEnable")
            WoosmapGeofencing.shared.setTrackingEnable(enable: false)
            refreshAllTimeSwitch.setOn(WoosmapGeofencing.shared.getModeHighfrequencyLocation(), animated: true)
            UserDefaults.standard.setValue(false, forKey: "ModeHighfrequencyLocation")
        }
    }
    
    @objc func disableEnableRefresh() {
        if refreshAllTimeSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "ModeHighfrequencyLocation")
            WoosmapGeofencing.shared.setModeHighfrequencyLocation(enable: true)
            searchAPISwitch.setOn(WoosmapGeofencing.shared.getSearchAPIRequestEnable(), animated: true)
            UserDefaults.standard.setValue(WoosmapGeofencing.shared.getSearchAPIRequestEnable(), forKey: "SearchAPIEnable")
        } else {
            UserDefaults.standard.setValue(false, forKey: "ModeHighfrequencyLocation")
            WoosmapGeofencing.shared.setModeHighfrequencyLocation(enable: false)
        }
    }

    @objc func disableEnableSearchAPI() {
        if searchAPISwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "SearchAPIEnable")
            WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: true)
        } else {
            UserDefaults.standard.setValue(false, forKey: "SearchAPIEnable")
            WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: false)
        }
    }

    @objc func removeAllRegions() {
        WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.RegionType.none)
    }

    @objc func testData() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: {
            MockDataVisit().mockVisitData()
            //MockDataVisit().mockLocationsData()
            //MockDataVisit().mockDataFromSample()
        })
        dismiss(animated: false, completion: nil)
    }

}
