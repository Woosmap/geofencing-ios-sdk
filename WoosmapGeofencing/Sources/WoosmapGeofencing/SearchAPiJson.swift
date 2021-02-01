//
//  SearchAPiJson.swift
//  WoosmapNowNotification
//
//

import Foundation

public struct SearchAPIData: Codable {
    public let type: String?
    public let features: [Features]?
    public let pagination: Pagination?

    enum CodingKeys: String, CodingKey {

        case type = "type"
        case features = "features"
        case pagination = "pagination"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try? values.decodeIfPresent(String.self, forKey: .type)
        features = try? values.decodeIfPresent([Features].self, forKey: .features)
        pagination = try? values.decodeIfPresent(Pagination.self, forKey: .pagination)
    }

}

public struct Address: Codable {
    public let lines: String?
    public let country_code: String?
    public let city: String?
    public let zipcode: String?

    enum CodingKeys: String, CodingKey {

        case lines = "lines"
        case country_code = "country_code"
        case city = "city"
        case zipcode = "zipcode"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lines = try? values.decodeIfPresent(String.self, forKey: .lines)
        country_code = try? values.decodeIfPresent(String.self, forKey: .country_code)
        city = try? values.decodeIfPresent(String.self, forKey: .city)
        zipcode = try? values.decodeIfPresent(String.self, forKey: .zipcode)
    }

}

public struct Features: Codable {
    public let type: String?
    public let properties: Properties?
    public let geometry: Geometry?

    enum CodingKeys: String, CodingKey {

        case type = "type"
        case properties = "properties"
        case geometry = "geometry"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try? values.decodeIfPresent(String.self, forKey: .type)
        properties = try? values.decodeIfPresent(Properties.self, forKey: .properties)
        geometry = try? values.decodeIfPresent(Geometry.self, forKey: .geometry)
    }

}

public struct Geometry: Codable {
    public let type: String?
    public let coordinates: [Double]?

    enum CodingKeys: String, CodingKey {

        case type = "type"
        case coordinates = "coordinates"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try? values.decodeIfPresent(String.self, forKey: .type)
        coordinates = try? values.decodeIfPresent([Double].self, forKey: .coordinates)
    }

}

public struct Pagination: Codable {
    public let page: Int?
    public let pageCount: Int?

    enum CodingKeys: String, CodingKey {

        case page = "page"
        case pageCount = "pageCount"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try? values.decodeIfPresent(Int.self, forKey: .page)
        pageCount = try? values.decodeIfPresent(Int.self, forKey: .pageCount)
    }

}

public struct Properties: Codable {
    public let store_id: String?
    public let name: String?
    public let contact: String?
    public let address: Address?
    public let user_properties: User_properties?
    public let tags: [String]?
    public let types: [String]?
    public let distance: Double?

    enum CodingKeys: String, CodingKey {

        case store_id = "store_id"
        case name = "name"
        case contact = "contact"
        case address = "address"
        case user_properties = "user_properties"
        case tags = "tags"
        case types = "types"
        case distance = "distance"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        store_id = try? values.decodeIfPresent(String.self, forKey: .store_id)
        name = try? values.decodeIfPresent(String.self, forKey: .name)
        contact = try? values.decodeIfPresent(String.self, forKey: .contact)
        address = try? values.decodeIfPresent(Address.self, forKey: .address)
        user_properties = try? values.decodeIfPresent(User_properties.self, forKey: .user_properties)
        tags = try? values.decodeIfPresent([String].self, forKey: .tags)
        types = try? values.decodeIfPresent([String].self, forKey: .types)
        distance = try? values.decodeIfPresent(Double.self, forKey: .distance)
    }

}

public struct User_properties: Codable {
    let aSCII_name: String?

    enum CodingKeys: String, CodingKey {

        case aSCII_name = "ASCII_name"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        aSCII_name = try? values.decodeIfPresent(String.self, forKey: .aSCII_name)
    }

}
