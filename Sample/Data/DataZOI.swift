//
//  DataZOI.swift
//  Sample
//
//  Created by Mac de Laurent on 26/05/2020.
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import WoosmapGeofencing

public class DataZOI {
    public init() {}

    public func readZOIs() -> [ZOI] {
        return ZOIs.getAll()
    }

    public func eraseZOIs() {
        ZOIs.deleteAll()
    }
}
