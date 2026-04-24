// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

/// A small dialog that lets the user set a custom server IP address.
/// Useful when running on a physical device that can't reach localhost.
///
/// Usage:
///   ServerIpDialog.show(context);
class ServerIpDialog extends StatefulWidget {
  const ServerIpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ServerIpDialog(),
    );
  }

  @override
  State<ServerIpDialog> createState() => _ServerIpDialogState();
}

class _ServerIpDialogState extends State<ServerIpDialog> {
  late final TextEditingController _ipController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: AuthProvider.serverIp);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() => _saving = true);
    await AuthProvider.saveServerIp(ip);
    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Server IP saved: $ip'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _reset() async {
    setState(() => _saving = true);
    await AuthProvider.clearSavedIp();
    _ipController.text = AuthProvider.serverIp;
    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Reset to auto-detected IP'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      title: const Row(
        children: [
          Icon(Icons.settings_ethernet, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text(
            'Server Connection',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your backend server IP address.\n'
            '• Web → use localhost\n'
            '• Android emulator → use 10.0.2.2\n'
            '• Physical device → use your PC\'s IP (run ipconfig)',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'IP Address',
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: 'e.g. 192.168.1.100',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: const Icon(Icons.lan, color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${AuthProvider.serverIp}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _reset,
          child:
              const Text('Auto-detect', style: TextStyle(color: Colors.orange)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
