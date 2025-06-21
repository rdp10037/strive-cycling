//
//  MKCoordinateRegionExtension.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (latitudes.max()! - latitudes.min()!) * 1.4,
            longitudeDelta: (longitudes.max()! - longitudes.min()!) * 1.4
        )

        self.init(center: center, span: span)
    }
}
