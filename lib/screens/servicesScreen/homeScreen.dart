import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/servicesScreen/connectionScreen.dart';
import 'package:untitled/screens/servicesScreen/mapScreen.dart';
import 'package:untitled/screens/servicesScreen/peopleScreen.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    AlarmScreen(),
    PeopleScreen(),
    MapScreen(),
    connectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black26,
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'المنبه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'الاشخاص المقربين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'الخريطة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_sharp),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}




class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmList = prefs.getStringList('alarms') ?? [];

    setState(() {
      _alarms = alarmList.map((alarmJson) => Alarm.fromJson(alarmJson)).toList();
    });
  }

  Future<void> _saveAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmList = _alarms.map((alarm) => alarm.toJson()).toList();
    await prefs.setStringList('alarms', alarmList);
  }
  Future<void> _addAlarm(BuildContext context) async {
    final alarm = await showDialog<Alarm>(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String address = '';
        TimeOfDay? time;

        return AlertDialog(
          title: Text('Add Alarm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  address = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (selectedTime != null) {
                    setState(() {
                      time = selectedTime;
                    });
                  }
                },
                child: Text(
                  time != null ? time!.format(context) : 'Select Time',
                  style: TextStyle(fontSize: 18),
                ),
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
                if (title.isNotEmpty && address.isNotEmpty && time != null) {
                  Navigator.of(context).pop(
                    Alarm(
                      title: title,
                      address: address,
                      time: time!,
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

    if (alarm != null) {
      setState(() {
        _alarms.add(alarm);
      });

      _saveAlarms();
    }
  }
  Future<void> _deleteAlarm(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Alarm'),
          content: Text('Are you sure you want to delete this alarm?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _alarms.removeAt(index);
                });

                _saveAlarms();

                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlarmList() {
    if (_alarms.isEmpty) {
      return Center(
        child: Image.asset('assets/alarmEmpty.png'), // Add your image path here
      );
    }

    return ListView.builder(
      itemCount: _alarms.length,
      itemBuilder: (context, index) {
        final alarm = _alarms[index];

        return ListTile(
          title: Text(alarm.title),
          subtitle: Text(alarm.address),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAlarm(index);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('صفحة المواعيد',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: _buildAlarmList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          _addAlarm(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Alarm {
  final String title;
  final String address;
  final TimeOfDay time;

  Alarm({
    required this.title,
    required this.address,
    required this.time,
  });

  factory Alarm.fromJson(String json) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(json));

    return Alarm(
      title: map['title'],
      address: map['address'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
    );
  }

  String toJson() {
    final Map<String, dynamic> map = {
      'title': title,
      'address': address,
      'hour': time.hour,
      'minute': time.minute,
    };

    return jsonEncode(map);
  }
}