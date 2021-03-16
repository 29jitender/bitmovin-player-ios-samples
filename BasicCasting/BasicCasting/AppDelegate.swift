//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Initialize ChromeCast support for this application
        BitmovinCastManager.initializeCasting()

        // Initialize logging
        GCKLogger.sharedInstance().delegate = self

        GCKCastContext.sharedInstance().discoveryManager.startDiscovery()

        return true
    }
}

extension AppDelegate: GCKLoggerDelegate {
    public func log(fromFunction function: UnsafePointer<Int8>, message: String) {
        print("ChromeCast Log: \(function) \(message)")
    }
}
