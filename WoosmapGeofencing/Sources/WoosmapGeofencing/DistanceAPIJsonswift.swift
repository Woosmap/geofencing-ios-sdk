//
//  DistanceAPIJsonswift.swift
//  WoosmapGeofencing
//

import Foundation

public struct DistanceAPIData: Codable {
    public let status: String?
    public let rows: [Row]?
}


public struct Row: Codable {
    public let elements: [Element]?
}


public struct Element: Codable {
    public let status: String?
    public let duration, distance: Distance?
}


public struct Distance: Codable {
    public let value: Int?
    public let text: String?
}
