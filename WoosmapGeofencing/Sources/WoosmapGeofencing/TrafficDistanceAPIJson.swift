//
//  TrafficDistanceAPIJson.swift
//  WoosmapGeofencing
//

import Foundation

public struct TrafficDistanceAPIData: Codable {
    public let rows: [RowDistance]?
    public let status: String?
}

public struct RowDistance: Codable {
    public let elements: [ElementDistance]?
}

public struct ElementDistance: Codable {
    public let status: String?
    public let duration_with_traffic: TrafficDistanceInfo?
    public let distance: TrafficDistanceInfo?
}

public struct TrafficDistanceInfo: Codable {
    public let value: Int?
    public let text: String?
}
