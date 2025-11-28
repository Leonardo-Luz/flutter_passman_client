class PassEntry {
  final String id;
  final String service;
  final String secret;
  final String? description;

  PassEntry({
    required this.id,
    required this.service,
    required this.secret,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service': service,
      'secret': secret,
      'description': description,
    };
  }

  static PassEntry fromMap(Map<String, dynamic> map) {
    return PassEntry(
      id: map['id'],
      service: map['service'],
      secret: map['secret'],
      description: map['description'],
    );
  }
}
