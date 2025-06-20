//
//  Polyline.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import CoreLocation


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


//func decodePolyline(_ encodedPolyline: String) -> [CLLocationCoordinate2D] {
//    var coordinates: [CLLocationCoordinate2D] = []
//    var index = encodedPolyline.startIndex
//    var lat = 0
//    var lng = 0
//
//    while index < encodedPolyline.endIndex {
//        var b, shift = 0, result = 0
//        repeat {
//            b = Int(encodedPolyline[index].asciiValue! - 63)
//            result |= (b & 0x1F) << shift
//            shift += 5
//            index = encodedPolyline.index(after: index)
//        } while b >= 0x20
//        let deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
//        lat += deltaLat
//
//        shift = 0
//        result = 0
//        repeat {
//            b = Int(encodedPolyline[index].asciiValue! - 63)
//            result |= (b & 0x1F) << shift
//            shift += 5
//            index = encodedPolyline.index(after: index)
//        } while b >= 0x20
//        let deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
//        lng += deltaLng
//
//        let coord = CLLocationCoordinate2D(latitude: Double(lat) / 1E5, longitude: Double(lng) / 1E5)
//        coordinates.append(coord)
//    }
//
//    return coordinates
//}
