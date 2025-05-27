class AccessResponse {
  final String id;
  final String name;
  final String status;
  final bool accessGranted;
  final String message;
  final String? plan;
  final String? endDate;

  AccessResponse({
    required this.id,
    required this.name,
    required this.status,
    required this.accessGranted,
    required this.message,
    this.plan,
    this.endDate,
  });

  factory AccessResponse.fromJson(Map<String, dynamic> json) {
    return AccessResponse(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      accessGranted: json['access_granted'],
      message: json['message'],
      plan: json['plan'], // Puede venir como null
      endDate: json['end_date'],
    );
  }
}
