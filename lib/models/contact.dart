class Contact {
  int? id;
  String name;
  String phone;
  String email;

  Contact({this.id, required this.name, required this.phone, required this.email});

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }
}
