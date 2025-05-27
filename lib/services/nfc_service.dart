import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/access_response.dart';

class NFCService {
  static const String _apiUrl = 'https://nfc-ezto.onrender.com/nfc/access';

  static Future<AccessResponse> checkAccess(String nfcId) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nfc_id': nfcId}),
    );

    if (response.statusCode == 200) {
      return AccessResponse.fromJson(jsonDecode(response.body));
    } else {
      // Intenta obtener el mensaje de error si está disponible
      String errorMessage = 'Error al verificar acceso';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('detail')) {
          errorMessage = body['detail'];
        }
      } catch (_) {
        // Ignora errores de parseo JSON
      }

      throw Exception(errorMessage);
    }
  }

  static const String _linkUrl = 'https://nfc-ezto.onrender.com/nfc/link';

  static Future<String> linkNfcCard(String nfcId, String pairingCode) async {
    final response = await http.post(
      Uri.parse(_linkUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pairing_code': pairingCode,
        'nfc_id': nfcId,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Tarjeta vinculada exitosamente';
    } else {
      String errorMessage = 'Error al vincular tarjeta';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('detail')) {
          errorMessage = body['detail'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
