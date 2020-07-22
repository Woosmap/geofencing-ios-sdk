//
//  Extension.swift
//  WoosmapGeofencing
//
//

import Foundation


public extension POI {
    internal func convertToModel()-> POIModel {
        return POIModel(city: self.city, zipCode: self.zipCode, distance: self.distance, latitude: self.latitude, longitude: self.longitude, dateCaptured: self.date)
    }
}

public extension Visit {
    internal func convertToModel()-> VisitModel {
        return VisitModel(visitId: self.visitId!, arrivalDate: self.arrivalDate, departureDate: self.departureDate, latitude: self.latitude, longitude: self.longitude, dateCaptured:self.arrivalDate , accuracy: self.accuracy)
    }
}


public extension Date {
    func stringFromDate()-> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy HH:mm:ss"
        let stringDate = formatter.string(from: self) // string purpose I add here
        return stringDate
    }
}
