// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/contact.dart';

class ApiService {
  // Change ici selon ta plateforme
 static const String baseUrl = "http://10.0.2.2:8000";   // Android Emulator
  // static const String baseUrl = "http://localhost:8000"; // iOS Simulator ou vrai téléphone même WiFi

  static const _storage = FlutterSecureStorage();

  // ==================== AUTH ====================
  static Future<void> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Erreur inscription');
    }
  }

  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['access_token']);
    } else {
      final error = jsonDecode(response.body)['detail'] ?? 'Erreur connexion';
      throw Exception(error);
    }
  }

  static Future<String?> getToken() async => await _storage.read(key: 'jwt_token');

  static Future<void> logout() async => await _storage.delete(key: 'jwt_token');

  // ==================== CONTACTS ====================
  static Future<List<Contact>> getContacts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/contacts'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Contact.fromMap(json)).toList();
    } else if (response.statusCode == 401) {
      await logout();
      throw Exception("Session expirée");
    } else {
      throw Exception("Erreur chargement contacts");
    }
  }

  static Future<void> addContact(Contact contact) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/contacts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contact.toMap()),
    );
    if (response.statusCode != 200) throw Exception("Erreur ajout");
  }

  static Future<void> updateContact(Contact contact) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/contacts/${contact.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contact.toMap()),
    );
    if (response.statusCode != 200) throw Exception("Erreur modification");
  }

  static Future<void> deleteContact(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/contacts/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception("Erreur suppression");
  }
}