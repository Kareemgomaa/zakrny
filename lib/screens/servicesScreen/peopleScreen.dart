import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Person {
  final String name;
  final String details;
  final Uint8List? picture;

  Person({required this.name, required this.details, this.picture});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'picture': picture != null ? base64Encode(picture!) : null,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      details: json['details'],
      picture: json['picture'] != null ? base64Decode(json['picture']) : null,
    );
  }
}

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Person> _people = [];
  bool _dataLoaded = false; // Track if data has been loaded

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  void _loadPeople() async {
    if (!_dataLoaded) {
      // Load data only if it hasn't been loaded before
      final prefs = await SharedPreferences.getInstance();
      final List<String>? peopleJson = prefs.getStringList('people');

      if (peopleJson != null) {
        setState(() {
          _people = peopleJson
              .map((json) => Person.fromJson(jsonDecode(json) as Map<String, dynamic>))
              .toList();
        });
      }
      _dataLoaded = true;
    }
  }

  void _savePerson(Person person) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> peopleJson =
    _people.map((person) => jsonEncode(person.toJson())).toList();

    prefs.setStringList('people', peopleJson);

    setState(() {
      _people.add(person);
    });
  }

  Future<Person?> _addPerson(BuildContext context) async {
    String name = '';
    String details = '';
    Uint8List? picture;

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final pickedImageBytes = await pickedImage.readAsBytes();
      picture = Uint8List.fromList(pickedImageBytes);
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Details'),
                onChanged: (value) {
                  details = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(
                    Person(
                      name: name,
                      details: details,
                      picture: picture,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    return picture != null ? Person(name: name, details: details, picture: picture) : null;
  }

  void _updatePerson(BuildContext context, int index) async {
    final person = await _addPerson(context);
    if (person != null) {
      setState(() {
        _people[index] = person;
      });
      _savePeopleToPrefs();
    }
  }

  void _deletePerson(int index) {
    setState(() {
      _people.removeAt(index);
    });
    _savePeopleToPrefs();
  }

  void _savePeopleToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> peopleJson =
    _people.map((person) => jsonEncode(person.toJson())).toList();

    prefs.setStringList('people', peopleJson);
  }

  void _showPersonDialog(BuildContext context, Person person, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Person Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (person.picture != null)
                CircleAvatar(
                  backgroundImage: MemoryImage(person.picture!),
                  radius: 40,
                ),
              SizedBox(height: 8),
              Text('Name: ${person.name}'),
              Text('Details: ${person.details}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updatePerson(context, index);
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePerson(index);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'الاشخاص المقربين',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: _people.isEmpty
          ? Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/alarmEmpty.png'),
          ),
        ),
      )
          : ListView.builder(
        itemCount: _people.length,
        itemBuilder: (BuildContext context, int index) {
          final person = _people[index];
          return GestureDetector(
            onTap: () {
              _showPersonDialog(context, person, index);
            },
            child: ListTile(
              leading: person.picture != null
                  ? CircleAvatar(
                backgroundImage: MemoryImage(person.picture!),
              )
                  : CircleAvatar(),
              title: Text(person.name),
              subtitle: Text(person.details),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await _addPerson(context);
          if (person != null) {
            _savePerson(person);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
