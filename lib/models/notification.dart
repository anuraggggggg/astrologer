class CallNotification {
  String description;
  int notificationType;
  int callDuration;

  CallNotification({
    required this.description,
    required this.notificationType,
    required this.callDuration,
  });

  factory CallNotification.fromJson(Map<String, dynamic> json) {
    return CallNotification(
      description: json['description'] ?? "",
      notificationType: json['notificationType'] ?? 0,
      callDuration: json['call_duration'] ?? 90,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'notificationType': notificationType,
      'call_duration': callDuration,
    };
  }
}
