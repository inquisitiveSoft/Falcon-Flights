//
//  SceneDelegate.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    /// Creates and attaches the root SwiftUI
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let contentView = RootView()
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
    }
}

