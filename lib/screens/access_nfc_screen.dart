import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../services/nfc_service.dart';
import 'access_screen.dart';

class AccessNfcScreen extends StatefulWidget {
  const AccessNfcScreen({super.key});

  @override
  State<AccessNfcScreen> createState() => _AccessNfcScreenState();
}

class _AccessNfcScreenState extends State<AccessNfcScreen> {
  bool isScanning = false;
  String message = 'Acerca tu tarjeta NFC para verificar acceso';

  @override
  void initState() {
    super.initState();
    _startNfcSession();
  }

  void _startNfcSession() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() => message = 'NFC no disponible en este dispositivo');
      return;
    }

    setState(() => isScanning = true);

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          debugPrint('🔍 TAG COMPLETO: ${tag.data}');

          // Extraer UID físico desde nfca
          final identifier = tag.data['nfca']?['identifier'];
          if (identifier == null || identifier is! List) {
            throw Exception('No se pudo obtener el UID de la tarjeta');
          }

          final nfcId = _bytesToHexString(List<int>.from(identifier));
          debugPrint('✅ UID leído: $nfcId');

          await NfcManager.instance.stopSession(); // Detiene la sesión antes del HTTP

          final result = await NFCService.checkAccess(nfcId);

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AccessScreen(response: result)),
            );
          }
        } catch (e) {
          debugPrint('❌ Error al leer UID: $e');
          if (context.mounted) {
            setState(() => message = 'Error al leer la tarjeta: $e');
            await NfcManager.instance.stopSession(errorMessage: 'Lectura fallida');
          }
        } finally {
          if (mounted) setState(() => isScanning = false);
        }
      },
    );
  }

  String _bytesToHexString(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Verificación de Acceso'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nfc, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 20),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (isScanning) const SizedBox(height: 20),
              if (isScanning)
                const CircularProgressIndicator(color: Colors.tealAccent),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isScanning ? null : _startNfcSession,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
