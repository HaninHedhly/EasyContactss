import 'package:flutter/material.dart';
import '../services/api_service.dart';     // ← NOUVEAU (remplace DBHelper)

class DeleteContactPage extends StatelessWidget {
  final int id;
  final String name;

  const DeleteContactPage({super.key, required this.id, required this.name});

  Future<void> deleteContact(BuildContext context) async {
    try {
      await ApiService.deleteContact(id);   // ← Appel API au lieu de DBHelper
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contact supprimé avec succès"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retour à DeleteListPage
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Supprimer Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Voulez-vous vraiment supprimer ce contact ?",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => deleteContact(context),
              icon: const Icon(Icons.delete),
              label: const Text("Supprimer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA5C1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}