import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/api_service.dart'; // 🆕
import '../main.dart'; // Pour la déconnexion

class ContactsHomePage extends StatefulWidget {
  const ContactsHomePage({super.key});

  @override
  State<ContactsHomePage> createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final ApiService apiService = ApiService(); // 🆕

  List<Contact> contacts = []; // 🆕 Type Contact au lieu de Map
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // 🆕 Charger les contacts depuis l'API
  Future<void> _loadContacts() async {
    setState(() => isLoading = true);
    
    try {
      List<Contact> fetchedContacts = await apiService.getContacts();
      if (mounted) {
        setState(() {
          contacts = fetchedContacts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }
  }

  // 🆕 Ajouter un contact via l'API
  Future<void> addContact() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String email = emailController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs", Colors.red);
      return;
    }

    // Validation email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar("Veuillez entrer un email valide", Colors.orange);
      return;
    }

    // Validation téléphone
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s+'), ''))) {
      _showSnackBar("Numéro de téléphone invalide", Colors.orange);
      return;
    }

    try {
      await apiService.addContact(name, phone, email);

      nameController.clear();
      phoneController.clear();
      emailController.clear();

      _showSnackBar("Contact ajouté avec succès !", Colors.green);
      await _loadContacts();
    } catch (e) {
      _showSnackBar("Erreur: $e", Colors.red);
    }
  }

  // 🆕 Modifier un contact
  void _editContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => _EditContactDialog(
        contact: contact,
        onSave: (name, phone, email) async {
          try {
            await apiService.updateContact(contact.id!, name, phone, email);
            _showSnackBar("Contact modifié avec succès", Colors.green);
            await _loadContacts();
          } catch (e) {
            _showSnackBar("Erreur: $e", Colors.red);
          }
        },
      ),
    );
  }

  // 🆕 Supprimer un contact
  void _deleteContact(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer ${contact.name} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await apiService.deleteContact(contact.id!);
                _showSnackBar("Contact supprimé", Colors.green);
                await _loadContacts();
              } catch (e) {
                _showSnackBar("Erreur: $e", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  // 🆕 Déconnexion
  void _logout() async {
    await apiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("EasyContact", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 4,
        actions: [
          // 🆕 Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // === FORMULAIRE D'AJOUT ===
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nom",
                          prefixIcon: Icon(Icons.person, color: Color(0xFFD78EE4)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone, color: Color(0xFFD19BDB)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email, color: Color(0xFFCB8CD6)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: addContact,
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter le contact", style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC581D1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // === LISTE DES CONTACTS ===
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : contacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.contacts, size: 64, color: Colors.purple[200]),
                                const SizedBox(height: 16),
                                Text(
                                  "Aucun contact ajouté",
                                  style: TextStyle(fontSize: 18, color: Colors.purple[600]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadContacts,
                            child: ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final c = contacts[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.purple[100],
                                      child: Text(
                                        c.name[0].toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                                      ),
                                    ),
                                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text("${c.phone} • ${c.email}", style: TextStyle(color: Colors.grey[600])),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _editContact(c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteContact(c),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === DIALOGUE DE MODIFICATION ===
class _EditContactDialog extends StatefulWidget {
  final Contact contact;
  final Function(String name, String phone, String email) onSave;

  const _EditContactDialog({
    required this.contact,
    required this.onSave,
  });

  @override
  State<_EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<_EditContactDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact.name);
    phoneController = TextEditingController(text: widget.contact.phone);
    emailController = TextEditingController(text: widget.contact.email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier le contact"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              nameController.text.trim(),
              phoneController.text.trim(),
              emailController.text.trim(),
            );
            Navigator.pop(context);
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}