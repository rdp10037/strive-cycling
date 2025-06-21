//
//  Polyline.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import CoreLocation

// Key Documentation references to come back to
// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
// https://developers.strava.com/docs/reference/#api-models-SummaryPolylineMap
// https://github.com/raphaelmor/Polyline

func decodePolyline(_ encodedPolyline: String) -> [CLLocationCoordinate2D] {
    var coordinates: [CLLocationCoordinate2D] = []
    let data = encodedPolyline.data(using: .utf8)!
    let length = data.count
    var index = 0
    var lat: Int32 = 0
    var lng: Int32 = 0
    
    while index < length {
        var byte = 0
        var result: Int32 = 0
        var shift: UInt32 = 0
        
        repeat {
            byte = Int(data[index]) - 63
            index += 1
            result |= Int32(byte & 0x1F) << shift
            shift += 5
        } while byte >= 0x20
        
        let deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1)
        lat += deltaLat
        
        shift = 0
        result = 0
        
        repeat {
            byte = Int(data[index]) - 63
            index += 1
            result |= Int32(byte & 0x1F) << shift
            shift += 5
        } while byte >= 0x20
        
        let deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1)
        lng += deltaLng
        
        let coordinate = CLLocationCoordinate2D(
            latitude: Double(lat) * 1e-5,
            longitude: Double(lng) * 1e-5
        )
        coordinates.append(coordinate)
    }
    
    return coordinates
}
