//
//  InterfaceAddress.swift
//  NetworkInfo
//
//  Created by M.Ike on 2016/12/19.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Foundation
import libc

//- Requires: #include <ifaddrs.h> <sys/socket.h> <netinet/in.h>

public class InterfaceAddress {
    public enum Network: String {
        case localWiFi = "en0"
        case wan = "pdp_ip0"
    }
    
    public enum Version: String {
        case IPv4
        case IPv6
        
        public func toString() -> String {
            return self.rawValue
        }
    }
    
    public let name: String
    public let version: Version
    public let IP: String
    public let mask: String
    
    private init(name: String, version: Version, IP: String, mask: String) {
        self.name = name
        self.version = version
        self.IP = IP
        self.mask = mask
    }
    
    public static func list() -> [InterfaceAddress]? {
        var results = [InterfaceAddress]()
        var ifaList: UnsafeMutablePointer<ifaddrs>? = nil
        
        defer {
            if ifaList != nil {
                freeifaddrs(ifaList)
            }
        }
        
        guard getifaddrs(&ifaList) == 0 else { return nil }
        
        var next = ifaList
        while next != nil {
            guard let ifa = next?.pointee else { return nil }
            if let address = address(ifa: ifa) {
                results += [address]
            }
            next = ifa.ifa_next
        }
        
        return results
    }
    
    private static func address(ifa: ifaddrs) -> InterfaceAddress? {
        switch ifa.ifa_addr.pointee.sa_family {
        case UInt8(AF_INET):    // IPv4
            let type = AF_INET
            let len = INET_ADDRSTRLEN
            
            guard let name = ifa.ifa_name,
                let device = String(validatingUTF8: name) else { return nil }
            
            guard let IP = ifa.ifa_addr.withMemoryRebound(
                to: sockaddr_in.self,
                capacity: 1,
                { sock -> String? in
                    var buffer = [CChar](repeating: 0, count: Int(len))
                    var sin = sock.pointee.sin_addr
                    inet_ntop(type, &sin, &buffer, socklen_t(len))
                    return String(validatingUTF8: buffer)
            }) else {
                return nil
            }
            
            guard let mask = ifa.ifa_netmask.withMemoryRebound(
                to: sockaddr_in.self,
                capacity: 1,
                { sock -> String? in
                    var buffer = [CChar](repeating: 0, count: Int(len))
                    var sin = sock.pointee.sin_addr
                    inet_ntop(type, &sin, &buffer, socklen_t(len))
                    return String(validatingUTF8: buffer)
            }) else {
                return nil
            }
            
            return InterfaceAddress(name: device, version: .IPv4, IP: IP, mask: mask)
            
        case UInt8(AF_INET6):   // IPv6
            let type = AF_INET6
            let len = INET6_ADDRSTRLEN
            
            guard let name = ifa.ifa_name,
                let device = String(validatingUTF8: name) else { return nil }
            
            guard let IP = ifa.ifa_addr.withMemoryRebound(
                to: sockaddr_in6.self,
                capacity: 1,
                { sock -> String? in
                    var buffer = [CChar](repeating: 0, count: Int(len))
                    var sin = sock.pointee.sin6_addr
                    inet_ntop(type, &sin, &buffer, socklen_t(len))
                    return String(validatingUTF8: buffer)
            }) else {
                return nil
            }
            
            guard let mask = ifa.ifa_netmask.withMemoryRebound(
                to: sockaddr_in6.self,
                capacity: 1,
                { sock -> String? in
                    var buffer = [CChar](repeating: 0, count: Int(len))
                    var sin = sock.pointee.sin6_addr
                    inet_ntop(type, &sin, &buffer, socklen_t(len))
                    return String(validatingUTF8: buffer)
            }) else {
                return nil
            }
            
            return InterfaceAddress(name: device, version: .IPv6, IP: IP, mask: mask)
            
        default:
            return nil
        }
    }
    
    public static func address(network: Network, version: Version) -> InterfaceAddress? {
        return list()?.filter { $0.name == network.rawValue && $0.version == version }.first
    }
}
