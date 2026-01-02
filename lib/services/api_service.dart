import 'dart:convert';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/contact.dart';

class ApiService {

  // ================== BASE URL ==================
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ================== AUTH ==================

  Future<String?> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['detail'] ?? 'Erreur inscription';
      }
    } catch (e) {
      return 'Erreur serveur : $e';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['access_token']);
        return null;
      } else {
        final error = jsonDecode(response.body);
        return error['detail'] ?? 'Login incorrect';
      }
    } catch (e) {
      return 'Erreur serveur : $e';
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // ================== HEADERS ==================

  Future<Map<String, String>> _headers() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================== CONTACTS ==================

  Future<List<Contact>> getContacts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/contacts'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Contact.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement contacts');
    }
  }

  Future<void> addContact(String name, String phone, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/contacts'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur ajout contact');
    }
  }

  Future<void> updateContact(int id, String name, String phone, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/contacts/$id'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur modification contact');
    }
  }

  Future<void> deleteContact(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/contacts/$id'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur suppression contact');
    }
  }
}
