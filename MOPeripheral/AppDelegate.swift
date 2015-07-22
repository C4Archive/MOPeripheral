//
//  AppDelegate.swift
//  MOPeripheral
//
//  Created by travis on 2015-07-17.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    //default iOS, needs to be here
    public var window: UIWindow?
    public var socketManager = PeripheralSocketManager()

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        socketManager.startSearching()
        return true
    }
}