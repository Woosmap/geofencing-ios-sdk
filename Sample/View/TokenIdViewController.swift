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
    @IBOutlet weak var distanceAPISwitch: UISwitch!
    @IBOutlet weak var POIRegionSwitch: UISwitch!
    @IBOutlet weak var removeAllRegionsButton: UIButton!
    @IBOutlet weak var removeAllPOIRegionsButton: UIButton!
    @IBOutlet weak var removeAllCustomRegionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TokenLabel.text = UserDefaults.standard.object(forKey: "TokenID") as? String
        trackingSwitch.setOn(WoosmapGeofencing.shared.getTrackingState(), animated: false)
        trackingSwitch.addTarget(self,action: #selector(disableEnableTracking), for: .touchUpInside)
        searchAPISwitch.setOn(WoosmapGeofencing.shared.getSearchAPIRequestEnable(), animated: false)
        searchAPISwitch.addTarget(self,action: #selector(disableEnableSearchAPI), for: .touchUpInside)
        distanceAPISwitch.setOn(WoosmapGeofencing.shared.getDistanceAPIRequestEnable(), animated: false)
        distanceAPISwitch.addTarget(self,action: #selector(disableEnableDistanceAPI), for: .touchUpInside)
        POIRegionSwitch.setOn(WoosmapGeofencing.shared.getSearchAPICreationRegionEnable(), animated: false)
        POIRegionSwitch.addTarget(self,action: #selector(searchAPICreationRegionEnable), for: .touchUpInside)
        
        removeAllRegionsButton.addTarget(self,action: #selector(removeAllRegions), for: .touchUpInside)
        removeAllPOIRegionsButton.addTarget(self,action: #selector(removeAllPOIRegions), for: .touchUpInside)
        removeAllCustomRegionsButton.addTarget(self,action: #selector(removeAllCustomRegions), for: .touchUpInside)
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
    
    @objc func disableEnableDistanceAPI(){
        if distanceAPISwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "DistanceAPIEnable")
            WoosmapGeofencing.shared.setDistanceAPIRequestEnable(enable: true)
        }else {
            UserDefaults.standard.setValue(false, forKey: "DistanceAPIEnable")
            WoosmapGeofencing.shared.setDistanceAPIRequestEnable(enable: false)
        }
    }
    
    @objc func searchAPICreationRegionEnable(){
        if POIRegionSwitch.isOn {
            UserDefaults.standard.setValue(true, forKey: "searchAPICreationRegionEnable")
            WoosmapGeofencing.shared.setSearchAPICreationRegionEnable(enable: true)
        }else {
            UserDefaults.standard.setValue(false, forKey: "searchAPICreationRegionEnable")
            WoosmapGeofencing.shared.setSearchAPICreationRegionEnable(enable: false)
        }
    }
    
    @objc func removeAllRegions(){
        WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.NONE)
    }
    
    @objc func removeAllPOIRegions(){
        WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.POI_REGION)
    }
    
    @objc func removeAllCustomRegions(){
        WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.CUSTOM_REGION)
    }


}
