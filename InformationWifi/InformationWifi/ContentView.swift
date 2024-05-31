//
//  ContentView.swift
//  InformationWifi
//
//  Created by Stephane Girão Linhares on 23/05/24.
//

import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import UIKit
import NetworkExtension

struct ContentView: View {
    let helper = MyHotspotHelper()
    init() {
       setupLocation()
        helper.listAvailableNetworks()
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(helper.listAvailableNetworks())")
        }
        .padding()
    }

    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }

    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        print("SSID is: \(ssid)")
        return ssid
    }

    func updateWifi() -> String {
        print("Show all wifi")
        var nome = ""
        currentNetworkInfos?.forEach({ (networkInfo) in
            if let ssid = networkInfo.ssid {
                print("SSID: \(ssid)")
                nome = nome.appending(ssid)
            }
        })
        return nome
    }

    func setupLocation() {
        let status = CLLocationManager.authorizationStatus()
        let locationManager = CLLocationManager()
        if status == .authorizedWhenInUse {
            updateWifi()
        } else if status == .authorizedAlways {
            updateWifi()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}

public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false, ssid: nil, bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append (networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}

class MyHotspotHelper: NEHotspotHelperCommand {
    func listAvailableNetworks() {
        NEHotspotHelper.register(options: nil, queue: DispatchQueue.main) { (cmd: NEHotspotHelperCommand) in
            if cmd.commandType == .filterScanList {
                guard let networkList = cmd.networkList else {
                    print("No networks found")
                    return
                }
                for network in networkList {
                    print("SSID: \(network.ssid), BSSID: \(network.bssid), Signal Strength: \(network.signalStrength)")
                }
            }
        }
    }
}
                                 

#Preview {
    ContentView()
}
