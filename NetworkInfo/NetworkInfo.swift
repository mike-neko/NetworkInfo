//
//  NetworkInfo.swift
//  NetworkInfo
//
//  Created by M.Ike on 2016/03/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Foundation

//- Requires: #include <ifaddrs.h> <sys/socket.h> <netinet/in.h>

class NetworkInfo {
    enum Device: String {
        case LocalWifi = "en0"
        case Wan = "pdp_ip0"
    }
    
    enum Version { case IPv4, IPv6 }
    
    struct IPAddress {
        let device: String
        let IP: String
        let version: Version
        let mask: String
    }
    
    static func IPAddressList() -> [IPAddress]? {
        var results = [IPAddress]()
        var ifa_list: UnsafeMutablePointer<ifaddrs> = nil

        defer {
            if ifa_list != nil {
                freeifaddrs(ifa_list)
            }
        }
        
        guard getifaddrs(&ifa_list) == 0 else { return nil }
        
        var p_ifa = ifa_list
        while p_ifa != nil {
            
            let ifa = p_ifa.memory
            
            switch ifa.ifa_addr.memory.sa_family {
            case UInt8(AF_INET):    // IPv4
                let type = AF_INET
                let len = INET_ADDRSTRLEN
                
                guard let device = String.fromCString(ifa.ifa_name) else { return nil }
                
                var socka = UnsafePointer<sockaddr_in>(ifa.ifa_addr).memory.sin_addr
                var sockn = UnsafePointer<sockaddr_in>(ifa.ifa_netmask).memory.sin_addr
                
                var addrstr = [CChar](count: Int(len), repeatedValue: 0)
                inet_ntop(type, &socka, &addrstr, socklen_t(len))
                guard let IP = String.fromCString(addrstr) else { return nil }
                
                var netmaskstr = [CChar](count: Int(len), repeatedValue: 0)
                inet_ntop(type, &sockn, &netmaskstr, socklen_t(len))
                guard let mask = String.fromCString(netmaskstr) else { return nil }
                
                results += [IPAddress(device: device, IP: IP, version: .IPv4, mask: mask)]
                
            case UInt8(AF_INET6):   // IPv6
                let type = AF_INET6
                let len = INET6_ADDRSTRLEN
                
                guard let device = String.fromCString(ifa.ifa_name) else { return nil }
                
                var socka = UnsafePointer<sockaddr_in6>(ifa.ifa_addr).memory.sin6_addr
                var sockn = UnsafePointer<sockaddr_in6>(ifa.ifa_netmask).memory.sin6_addr
                
                var addrstr = [CChar](count: Int(len), repeatedValue: 0)
                inet_ntop(type, &socka, &addrstr, socklen_t(len))
                guard let IP = String.fromCString(addrstr) else { return nil }
                
                var netmaskstr = [CChar](count: Int(len), repeatedValue: 0)
                inet_ntop(type, &sockn, &netmaskstr, socklen_t(len))
                guard let mask = String.fromCString(netmaskstr) else { return nil }
                
                results += [IPAddress(device: device, IP: IP, version: .IPv6, mask: mask)]
                
            default: break
            }
            
            p_ifa = p_ifa.memory.ifa_next
        }
        
        return results
    }
    
    
    static func LocalWifiIPv4() -> String {
        guard let list = IPAddressList() else { return "" }
        guard let i = list.indexOf({ $0.device == Device.LocalWifi.rawValue && $0.version == .IPv4 }) else { return "" }
        return list[i].IP
    }

    static func WanIPv4() -> String {
        guard let list = IPAddressList() else { return "" }
        guard let i = list.indexOf({ $0.device == Device.Wan.rawValue && $0.version == .IPv4 }) else { return "" }
        return list[i].IP
    }
}
