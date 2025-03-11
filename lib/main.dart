import 'package:flutter/material.dart';
import 'dart:async'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contactos',
      theme: ThemeData(
        primaryColor: Color(0xFF61C6C5),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFB6D8D7),
        ),
        scaffoldBackgroundColor: Color(0xFFF0F5F4),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      home: ContactListScreen(),
    );
  }
}

class Contact {
  String name;
  String phone;
  String email;
  String alias;
  bool isFavorite;

  Contact(
      {required this.name,
      required this.phone,
      required this.email,
      required this.alias,
      this.isFavorite = false});
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final List<Contact> contacts = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aliasController = TextEditingController();

  void _addContact() {
    if (_phoneController.text.length != 11) {
      _showAlert('El número de teléfono debe tener 11 dígitos.');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showAlert('El correo debe contener un signo de @.');
      return;
    }

    final formattedPhone = _phoneController.text.substring(0, 4) +
        '-' +
        _phoneController.text.substring(4);

    final newContact = Contact(
      name: _nameController.text,
      phone: formattedPhone,
      email: _emailController.text,
      alias: _aliasController.text,
    );

    setState(() {
      contacts.add(newContact);
      _sortContacts();
    });

    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _aliasController.clear();
  }

  void _editContact(int index) {
    final contact = contacts[index];
    _nameController.text = contact.name;
    _phoneController.text = contact.phone.replaceAll('-', '');
    _emailController.text = contact.email;
    _aliasController.text = contact.alias;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, 'Nombre'),
            SizedBox(height: 8),
            _buildTextField(_phoneController, 'Teléfono', isPhone: true),
            SizedBox(height: 8),
            _buildTextField(_emailController, 'Correo'),
            SizedBox(height: 8),
            _buildTextField(_aliasController, 'Alias'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_phoneController.text.length != 11) {
                _showAlert('El número de teléfono debe tener 11 dígitos.');
                return;
              }

              if (!_emailController.text.contains('@')) {
                _showAlert('El correo debe contener un signo de @.');
                return;
              }

              setState(() {
                contact.name = _nameController.text;
                contact.phone = _phoneController.text.substring(0, 4) +
                    '-' +
                    _phoneController.text.substring(4);
                contact.email = _emailController.text;
                contact.alias = _aliasController.text;
                _sortContacts();
              });
              Navigator.of(context).pop();
              _clearFields();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteContactWithConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Seguro que quieres eliminar este contacto?'),
        content: Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                contacts.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(int index) {
    setState(() {
      contacts[index].isFavorite = !contacts[index].isFavorite;
      _sortContacts();
    });
  }

  void _sortContacts() {
    contacts.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) {
        return -1;
      } else if (!a.isFavorite && b.isFavorite) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _aliasController.clear();
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      maxLength: isPhone ? 11 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('Agenda Telefónica'),
          ],
        ),
        backgroundColor: Color(0xFF61C6C5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(_nameController, 'Nombre'),
                SizedBox(height: 10),
                _buildTextField(_phoneController, 'Teléfono', isPhone: true),
                SizedBox(height: 10),
                _buildTextField(_emailController, 'Correo'),
                SizedBox(height: 10),
                _buildTextField(_aliasController, 'Alias'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addContact,
                  child: Text('Añadir Contacto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF61C6C5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(contact.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${contact.alias}\n${contact.phone}\n${contact.email}',
                        style: TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(contact.isFavorite
                              ? Icons.star
                              : Icons.star_border),
                          onPressed: () => _toggleFavorite(index),
                          color: Colors.amber,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editContact(index),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _deleteContactWithConfirmation(index),
                          color: Colors.red,
                        ),
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () => _navigateToCallScreen(contact),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  
  void _navigateToCallScreen(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(contact: contact),
      ),
    );
  }
}

class CallScreen extends StatefulWidget {
  final Contact contact;

  CallScreen({required this.contact});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late int _counter;
  late Timer _timer;
  bool _isCallActive = true;

  @override
  void initState() {
    super.initState();
    _counter = 1; 
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isCallActive) {
        setState(() {
          _counter++;
        });
      }
    });
  }

  void _hangUp() {
    setState(() {
      _isCallActive = false; 
    });
    _timer.cancel(); 
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    _timer.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Llamando a ${widget.contact.name}'),
        backgroundColor: Color(0xFF61C6C5),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Llamando...',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Nombre: ${widget.contact.name}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Teléfono: ${widget.contact.phone}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 40),
          Text(
            'Tiempo de llamada: $_counter', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.mic_none),
                onPressed: () {},
                iconSize: 40,
                color: Colors.blue,
              ),
              SizedBox(width: 30),
              IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () {},
                iconSize: 40,
                color: Colors.orange,
              ),
              SizedBox(width: 30),
              IconButton(
                icon: Icon(Icons.videocam_off),
                onPressed: () {},
                iconSize: 40,
                color: Colors.red,
              ),
            ],
          ),
          SizedBox(height: 40),
          IconButton(
            icon: Icon(Icons.call_end),
            onPressed: _hangUp, 
            iconSize: 60, 
            color: Colors.red, 
          ),
        ],
      ),
    );
  }
}

