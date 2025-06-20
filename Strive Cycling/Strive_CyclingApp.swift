//
//  Strive_CyclingApp.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/18/25.
//

import SwiftUI

@main
struct Strive_CyclingApp: App {
    
    @State private var overlayWindow: PassThroughWindow?
    
    @StateObject var stravaAuthVm = StravaAuthViewModel()
    @StateObject var stravaActivityVm = StravaActivityViewModel()
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    if overlayWindow == nil {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            let overlayWindow = PassThroughWindow(windowScene: windowScene)
                            overlayWindow.backgroundColor = .clear
                            overlayWindow.tag = 0320
                            let controller = StatusBarBasedController()
                            controller.view.backgroundColor = .clear
                            overlayWindow.rootViewController = controller
                            overlayWindow.isHidden = false
                            overlayWindow.isUserInteractionEnabled = true
                            self.overlayWindow = overlayWindow
                            //      print("Overlay Window Created")
                        }
                    }
                })
                .environmentObject(stravaAuthVm)
                .environmentObject(stravaActivityVm)
        }
    }
}


class StatusBarBasedController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}

fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
