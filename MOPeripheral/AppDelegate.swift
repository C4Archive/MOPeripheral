//
//  AppDelegate.swift
//  MOPeripheral
//
//  Created by travis on 2015-07-17.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    //default iOS, needs to be here
    public var window: UIWindow?
    //the browser will look for the core
    public var netServiceBrowser : NSNetServiceBrowser?
    //a variable to store a local version of the core's service
    var coreService : NSNetService?
    //a list of addresses that point to a broadcast NSNetService
    var serverAddresses : [NSData]?
    //the socket that will be used to connect to the core app
    var asyncSocket : GCDAsyncSocket?


    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //create the browser, it will look for the core
        netServiceBrowser = NSNetServiceBrowser()
        //set its delegate
        netServiceBrowser?.delegate = self
        //start searching for services
        netServiceBrowser?.searchForServicesOfType("_m-o._tcp.", inDomain: "local.")
        return true
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        println(__FUNCTION__)
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        println(__FUNCTION__)

        if coreService != nil {
            coreService?.stop()
            coreService?.delegate =  nil
        }
        coreService = aNetService;
        coreService?.delegate = self
        coreService?.resolveWithTimeout(5.0)
    }
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        println("\(__FUNCTION__) error: \(errorDict)")
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        println(__FUNCTION__)
    }

    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        println(__FUNCTION__)
    }

    public func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println(__FUNCTION__)
    }

    public func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println(__FUNCTION__)
    }

    public func netServiceDidResolveAddress(sender: NSNetService) {
        println(__FUNCTION__)

        //if there are any addresses left over from a previous connection
        if serverAddresses != nil {
            //remove them
            serverAddresses?.removeAll(keepCapacity: false)
        } else {
            //otherwise, create a new array to hold incoming addresses
            serverAddresses = [NSData]()
        }

        //if the net service that was found has addresses
        if let count = sender.addresses?.count,
            //and the addresses are not nil (i.e. we can extract them)
            let addresses = sender.addresses as? [NSData] {
                //then cycle through all the addresses and append them to the local array
                for i in 0..<count {
                    serverAddresses?.append(addresses[i])
                }
        }

        //create a new socket if it hasn't yet been created
        if (asyncSocket == nil) {
            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }

        connectToNextAddress()
    }

    public func connectToNextAddress() {
        println(__FUNCTION__)
        //variable representing the socket's attempt to connect to an address
        var done = false

        //loop through all the addresses until we either run out, or have connected to one of them
        while !done && serverAddresses?.count > 0 {
            //grab the first address
            var address = serverAddresses?[0]
            //remove it from the list
            serverAddresses?.removeAtIndex(0)

            //try connecting to the first address
            var error : NSError?
            if let response = asyncSocket?.connectToAddress(address , error: &error) {
                //if the socket connects, mark done
                done = response
            }
        }
    }

    public func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println(__FUNCTION__)
    }

    func writeTo(sock: GCDAsyncSocket, message: String) {
        println(__FUNCTION__)
        //converts the message to data
        let data = NSMutableData(data: message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        //appends an extra bit of data that acts as an "end point" for reading
        data.appendData(GCDAsyncSocket.CRLFData())
        //writes the full data to the socket
        sock.writeData(data, withTimeout: -1, tag: 0)
        //tells the socket to read until it reaches the "end point"
        sock.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: 0)
    }

    public func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println(__FUNCTION__)
        writeTo(sock, message: "handshake-from-peripheral")
    }

    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        //extracts the data, converts it to a string
        let message = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("\(__FUNCTION__) message: \(message)")
    }

    public func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        println(__FUNCTION__)
    }
}

