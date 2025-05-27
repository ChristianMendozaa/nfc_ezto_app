class LinkNfcRequest {
  final String pairingCode;
  final String nfcId;

  LinkNfcRequest({required this.pairingCode, required this.nfcId});

  Map<String, dynamic> toJson() => {
        'pairing_code': pairingCode,
        'nfc_id': nfcId,
      };
}
