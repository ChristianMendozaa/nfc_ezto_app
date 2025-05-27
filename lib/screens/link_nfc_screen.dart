import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../services/nfc_service.dart';

class LinkNfcScreen extends StatefulWidget {
  const LinkNfcScreen({super.key});

  @override
  State<LinkNfcScreen> createState() => _LinkNfcScreenState();
}

class _LinkNfcScreenState extends State<LinkNfcScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? resultMessage;
  bool isScanning = false;
  String scanningText = 'Acerca tu tarjeta NFC al lector para vincularla.';

  void _startNfcLink() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el código de emparejamiento.')),
      );
      return;
    }

    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() => resultMessage = 'NFC no disponible en este dispositivo');
      return;
    }

    setState(() {
      isScanning = true;
      resultMessage = null;
      scanningText = 'Acerca tu tarjeta NFC para completar la vinculación...';
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final identifier = tag.data['nfca']?['identifier'];
          if (identifier == null || identifier is! List) {
            throw Exception('No se pudo obtener el UID de la tarjeta.');
          }

          final nfcId = _bytesToHexString(List<int>.from(identifier));
          debugPrint('✅ UID leído: $nfcId');

          await NfcManager.instance.stopSession();

          final responseMsg = await NFCService.linkNfcCard(nfcId, code);

          if (mounted) {
            setState(() {
              resultMessage = responseMsg;
              isScanning = false;
            });
          }
        } catch (e) {
          debugPrint('❌ Error al vincular tarjeta: $e');
          await NfcManager.instance.stopSession(errorMessage: 'Error al vincular');
          if (mounted) {
            setState(() {
              isScanning = false;
              resultMessage = 'Error: ${e.toString()}';
            });
          }
        }
      },
    );
  }

  String _bytesToHexString(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Vincular Tarjeta NFC'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Introduce el código de emparejamiento:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Código de emparejamiento',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isScanning ? null : _startNfcLink,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
              child: isScanning
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Vincular Tarjeta', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 40),
            if (isScanning)
              Column(
                children: [
                  const Icon(Icons.nfc, size: 60, color: Colors.tealAccent),
                  const SizedBox(height: 10),
                  Text(scanningText,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center),
                ],
              ),
            if (resultMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  resultMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
