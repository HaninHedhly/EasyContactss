import 'package:flutter/material.dart';
import '../models/contact.dart';           // ← NOUVEAU
import '../services/api_service.dart';     // ← NOUVEAU
import 'edit_confirmation_page.dart';      // ← tu gardes ton nom actuel

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});
  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  List<Contact> contacts = [];   // ← Changé : List<Contact> au lieu de List<Map>

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      final data = await ApiService.getContacts();  // ← Utilise l'API
      if (mounted) {
        setState(() {
          contacts = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de chargement"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text("Modifier un contact"),
        backgroundColor: Colors.purple,
      ),
      body: contacts.isEmpty
          ? const Center(child: Text("Aucun contact"))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final c = contacts[index];   // ← c est maintenant un objet Contact
                return Card(
                  color: Colors.purple[100],
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text("${c.phone} • ${c.email}"),
                    trailing: ElevatedButton(
                      child: const Text("Modifier"),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditContactPage(
                              id: c.id!,        // ← c.id
                              name: c.name,     // ← c.name
                              phone: c.phone,   // ← c.phone
                              email: c.email,   // ← c.email
                            ),
                          ),
                        );
                        loadContacts();   // ← recharge après modification
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD78EE4),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}




