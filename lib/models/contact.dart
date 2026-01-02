class Contact {
  int? id;
  String name;
  String phone;
  String email;
  int? userId; // 🆕 Ajouté pour le backend

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.userId,
  });

  // Pour SQLite (ancien système)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
    );
  }

  // 🆕 Pour l'API (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'user_id': userId,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      userId: json['user_id'],
    );
  }
}