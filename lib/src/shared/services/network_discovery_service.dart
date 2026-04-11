import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

/// Discovers network devices that have the WebRTC server running
class NetworkDiscoveryService {
  /// Get device's own IP addresses
  static Future<List<String>> getDeviceIps() async {
    try {
      final interfaces = await NetworkInterface.list();
      final ips = <String>[];
      
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // IPv4 addresses only, skip loopback for network discovery
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
      
      return ips;
    } catch (e) {
      return [];
    }
  }

  /// Scan network for devices running signaling server on port 3000
  /// Returns list of IPs that have a responding server
  static Future<List<String>> scanForServers({
    String? baseIp,
    int timeout = 1000,
  }) async {
    final foundServers = <String>[];
    final ips = await getDeviceIps();
    
    // If no base IP supplied, use first available
    String subnet = baseIp ?? (ips.isNotEmpty ? ips[0] : '192.168.1');
    
    // Get first 3 octets for subnet
    final parts = subnet.split('.');
    final base = parts.take(3).join('.');
    
    // Check IPs in the subnet (1-254)
    final futures = <Future<void>>[];
    
    // Scan the entire standard subnet range (1-254) using concurrent requests
    final rangesToScan = List.generate(254, (i) => i + 1);
    
    for (final i in rangesToScan) {
      futures.add(_checkServer('$base.$i', timeout, foundServers));
    }
    
    // Also check localhost and common local IPs
    await Future.wait([
      _checkServer('localhost', timeout, foundServers),
      _checkServer('127.0.0.1', timeout, foundServers),
      _checkServer('10.0.2.2', timeout, foundServers), // Android emulator
    ]);
    
    await Future.wait(futures);
    return foundServers;
  }

  static Future<void> _checkServer(
    String ip,
    int timeout,
    List<String> foundServers,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('http://$ip:3000'))
          .timeout(Duration(milliseconds: timeout));
      
      if (response.statusCode < 500) {
        if (!foundServers.contains(ip)) {
          foundServers.add(ip);
        }
      }
    } catch (_) {
      // Not responding, skip
    }
  }
}
