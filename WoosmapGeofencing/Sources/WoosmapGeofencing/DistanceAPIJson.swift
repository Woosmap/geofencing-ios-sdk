//
//  TrafficDistanceAPIJson.swift
//  WoosmapGeofencing
//

import Foundation

public struct DistanceAPIData: Codable {
    public let rows: [RowDistance]?
    public let status: String?
}

public struct RowDistance: Codable {
    public let elements: [ElementDistance]?
}

public struct ElementDistance: Codable {
    public let status: String?
    public let duration_with_traffic: DistanceInfo?
    public let duration: DistanceInfo?
    public let distance: DistanceInfo?
}

public struct DistanceInfo: Codable {
    public let value: Int?
    public let text: String?
}
