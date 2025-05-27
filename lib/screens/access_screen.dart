import 'package:flutter/material.dart';
import 'package:nfc_ezto/screens/homescreen.dart';
import '../models/access_response.dart';

class AccessScreen extends StatelessWidget {
  final AccessResponse response;

  const AccessScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final isGranted = response.accessGranted;
    final color = isGranted ? Colors.green : Colors.red;
    final icon = isGranted ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 100, color: color),
              const SizedBox(height: 20),
              Text(response.name,
                  style: const TextStyle(fontSize: 28, color: Colors.white)),
              const SizedBox(height: 10),
              Text('Estado: ${response.status}',
                  style: const TextStyle(fontSize: 20, color: Colors.white70)),
              if (response.plan != null)
                Text('Plan: ${response.plan!}',
                    style:
                        const TextStyle(fontSize: 18, color: Colors.white60)),
              if (response.endDate != null)
                Text('Válido hasta: ${response.endDate!}',
                    style:
                        const TextStyle(fontSize: 18, color: Colors.white60)),
              const SizedBox(height: 20),
              Text(response.message,
                  style: TextStyle(fontSize: 24, color: color)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent),
                child: const Text('Volver a escanear'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
