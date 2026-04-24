import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/services/network_discovery_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  late TextEditingController _ipController;
  String _currentIp = '';
  bool _testing = false;
  bool _scanning = false;
  String? _testResult;
  List<String> _discoveredServers = [];
  List<String> _deviceIps = [];

  @override
  void initState() {
    super.initState();
    _currentIp = AuthProvider.serverIp;
    _ipController = TextEditingController(text: _currentIp);
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final ips = await NetworkDiscoveryService.getDeviceIps();
    if (mounted) {
      setState(() => _deviceIps = ips);
    }
  }

  Future<void> _testConnection() async {
    setState(() => _testing = true);
    final ip = _ipController.text.trim();

    try {
      final result = await http
          .get(Uri.parse('http://$ip:3000'))
          .timeout(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          _testResult = result.statusCode == 200
              ? '✅ Connected to $ip:3000'
              : '⚠️ Server responded with ${result.statusCode}';
          _testing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = '❌ Failed: ${e.toString()}';
          _testing = false;
        });
      }
    }
  }

  Future<void> _scanNetwork() async {
    setState(() => _scanning = true);
    _discoveredServers = [];

    try {
      final discovered = await NetworkDiscoveryService.scanForServers()
          .timeout(const Duration(seconds: 15), onTimeout: () => []);

      if (mounted) {
        setState(() {
          _discoveredServers = discovered;
          _scanning = false;
        });

        if (discovered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No servers found on network. Ensure server is running on port 3000.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    }
  }

  Future<void> _saveIp() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IP cannot be empty')),
      );
      return;
    }

    await AuthProvider.saveServerIp(ip);
    if (mounted) {
      setState(() => _currentIp = ip);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Server IP saved: $ip')),
      );
    }
  }

  Future<void> _clearSavedIp() async {
    await AuthProvider.clearSavedIp();
    if (mounted) {
      setState(() {
        _currentIp = AuthProvider.serverIp;
        _ipController.text = _currentIp;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Saved IP cleared, using auto-detected')),
      );
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device IP Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Device\'s IP Addresses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_deviceIps.isEmpty)
                    const Text(
                      'Detecting...',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _deviceIps
                          .map((ip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '• $ip',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                    color: Colors.blue,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Current Server IP
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currently Connected to',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentIp,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Port: 3000 (WebRTC Signaling Server)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Scan Network Button
          ElevatedButton.icon(
            onPressed: _scanning ? null : _scanNetwork,
            icon: _scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.radar),
            label: Text(
                _scanning ? 'Scanning Network...' : 'Scan Network for Server'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          // Discovered Servers
          if (_discoveredServers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Servers Found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._discoveredServers.map((ip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: GestureDetector(
                            onTap: () {
                              _ipController.text = ip;
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ip,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap any IP to select it',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Manual IP Input
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: 'Enter Server IP',
              hintText: 'e.g., 192.168.1.100 or example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.dns),
            ),
          ),
          const SizedBox(height: 12),

          // Test Connection Button
          ElevatedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.public),
            label: Text(_testing ? 'Testing...' : 'Test Connection'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          // Test Result
          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testResult!.startsWith('✅')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                border: Border.all(
                  color:
                      _testResult!.startsWith('✅') ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _testResult!,
                style: TextStyle(
                  color: _testResult!.startsWith('✅')
                      ? Colors.green.shade900
                      : Colors.red.shade900,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Save Button
          ElevatedButton.icon(
            onPressed: _saveIp,
            icon: const Icon(Icons.save),
            label: const Text('Save IP Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // Clear Saved Button
          OutlinedButton.icon(
            onPressed: _clearSavedIp,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Saved IP (Auto-detect)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 32),

          // Help Section
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Setup Instructions - All Devices',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '✅ SETUP FOR ALL DEVICES (Phone, Tablet, Laptop, PC):\n\n'
                    '1️⃣ Ensure Server is Running\n'
                    '   • Start npm server: npm start\n'
                    '   • Should run on port 3000\n\n'
                    '2️⃣ Same WiFi Network (Recommended)\n'
                    '   • Connect all devices to same WiFi\n'
                    '   • Open Settings on each device\n'
                    '   • Tap "Scan Network for Server"\n'
                    '   • Select found IP → Test → Save\n\n'
                    '3️⃣ Different Networks\n'
                    '   • Must first connect to same WiFi\n'
                    '   • Or use VPN to reach server\n\n'
                    '4️⃣ Manual Configuration\n'
                    '   • Enter IP manually in text field\n'
                    '   • Tap "Test Connection"\n'
                    '   • When ✅ shows, tap "Save IP Address"\n'
                    '   • Restart app\n\n'
                    '5️⃣ For Students & Alumni\n'
                    '   • All use same server IP\n'
                    '   • Join classroom as Student or Mentor\n'
                    '   • WebRTC will work instantly',
                    style: TextStyle(fontSize: 12, height: 1.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
