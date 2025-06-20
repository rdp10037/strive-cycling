//
//  ActivityMapSnapshotView.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ActivityMapSnapshotView: View {
    let coordinates: [CLLocationCoordinate2D]
    
    @State private var snapshotImage: UIImage?
    
    var body: some View {
        Group {
            if let image = snapshotImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.green.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
        .frame(height: 160)
        .onAppear {
            generateSnapshot()
        }
    }
    
    private func generateSnapshot() {
        guard !coordinates.isEmpty else { return }
        
        // Center the region on the activity path
        let region = MKCoordinateRegion(coordinates: coordinates)
        
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: UIScreen.main.bounds.width * 0.6, height: 160)
        options.mapType = .mutedStandard
        options.showsBuildings = false
        options.showsPointsOfInterest = false
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { result, error in
            guard let snapshot = result, error == nil else {
                print("Snapshot error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            let image = drawPolyline(on: snapshot)
            self.snapshotImage = image
        }
    }
    
    private func drawPolyline(on snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
        let image = snapshot.image
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        
        image.draw(at: .zero)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(3)
        context?.setStrokeColor(UIColor.systemGreen.cgColor)
        
        let points = coordinates.map { snapshot.point(for: $0) }
        
        guard points.count > 1 else {
            UIGraphicsEndImageContext()
            return image
        }
        
        context?.beginPath()
        context?.move(to: points[0])
        
        for point in points.dropFirst() {
            context?.addLine(to: point)
        }
        
        context?.strokePath()
        
        // Start pin
        drawPin(at: points.first, color: .systemBlue)
        // End pin
        drawPin(at: points.last, color: .systemRed)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    private func drawPin(at point: CGPoint?, color: UIColor) {
        guard let point = point else { return }
        
        let pinRadius: CGFloat = 6
        let rect = CGRect(x: point.x - pinRadius, y: point.y - pinRadius, width: pinRadius * 2, height: pinRadius * 2)
        
        let path = UIBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
    }
}



#Preview {
    let sampleCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        CLLocationCoordinate2D(latitude: 37.7793, longitude: -122.4192),
        CLLocationCoordinate2D(latitude: 37.7800, longitude: -122.4180),
        CLLocationCoordinate2D(latitude: 37.7812, longitude: -122.4170),
        CLLocationCoordinate2D(latitude: 37.7825, longitude: -122.4160)
    ]
    
    return ActivityMapSnapshotView(coordinates: sampleCoordinates)
        .padding()
        .previewLayout(.sizeThatFits)
}


