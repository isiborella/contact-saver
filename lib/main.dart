import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ContactSaverApp());
}

class ContactSaverApp extends StatelessWidget {
  const ContactSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Saver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ContactForm(),
    );
  }
}

class Contact {
  String name;
  String phone;

  Contact(this.name, this.phone);
}

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final List<Contact> contactList = [];
  int? editingIndex;

  void saveOrUpdateContact() {
    if (formKey.currentState!.validate()) {
      setState(() {
        if (editingIndex == null) {
          // Add new contact
          contactList.add(Contact(nameController.text, phoneController.text));
        } else {
          // Update existing contact
          contactList[editingIndex!] = Contact(
            nameController.text,
            phoneController.text,
          );
          editingIndex = null;
        }
        nameController.clear();
        phoneController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved')),
      );
    }
  }

  void editContact(int index) {
    setState(() {
      editingIndex = index;
      nameController.text = contactList[index].name;
      phoneController.text = contactList[index].phone;
    });
  }

  void deleteContact(int index) {
    setState(() {
      contactList.removeAt(index);
      if (editingIndex == index) {
        nameController.clear();
        phoneController.clear();
        editingIndex = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Saver'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter phone number';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Only numbers allowed';
                      }
                      if (value.length < 7) {
                        return 'Number too short';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveOrUpdateContact,
                    child: Text(editingIndex == null
                        ? 'Save Contact'
                        : 'Update Contact'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Saved Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: contactList.isEmpty
                  ? const Text('No contacts saved yet.')
                  : ListView.builder(
                      itemCount: contactList.length,
                      itemBuilder: (context, index) {
                        final contact = contactList[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editContact(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteContact(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
