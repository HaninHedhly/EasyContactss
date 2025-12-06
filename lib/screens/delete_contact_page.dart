import 'package:flutter/material.dart';
import '../models/contact.dart';           // ← NOUVEAU
import '../services/api_service.dart';     // ← NOUVEAU
import 'delete_confirmation_page.dart';   // ← inchangé

class DeleteListPage extends StatefulWidget {
  const DeleteListPage({super.key});

  @override
  State<DeleteListPage> createState() => _DeleteListPageState();
}

class _DeleteListPageState extends State<DeleteListPage> {
  List<Contact> contacts = [];   // ← List<Contact> au lieu de List<Map>

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      final data = await ApiService.getContacts();   // ← Appel API
      if (mounted) {
        setState(() {
          contacts = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de charger les contacts"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text("Supprimer un contact"),
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
                      child: const Text("Supprimer"),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteContactPage(
                              id: c.id!,      // ← c.id
                              name: c.name,   // ← c.name
                            ),
                          ),
                        );
                        loadContacts(); // recharge la liste après suppression
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA5C1),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}