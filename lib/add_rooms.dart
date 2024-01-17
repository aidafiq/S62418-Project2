import 'package:flutter/material.dart';
import 'package:hotel_management/booking.dart';
import 'package:hotel_management/homepage.dart';
import 'package:hotel_management/login.dart';
import 'package:hotel_management/view_booking.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Room {
  final String name;
  final double price;

  Room({required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name: json['name'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'],
    );
  }
}

class Booking {
  String? id;
  String guestName;
   Room room;
   DateTime startDate;
   DateTime endDate;

  Booking({
    required this.id,
    required this.guestName,
    required this.room,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'guestName': guestName,
      'room':{
        'name': room.name,
        'price': room.price,
      } ,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      guestName: json['guestName'],
      room: Room(
        name: json['room']['name'], 
        price: (json['room']['price'] as int).toDouble(),
        ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      id: json['id'] ?? '',
    );
  }
}

class AddRoomPage extends StatelessWidget {
  final List<Room> rooms = [];
  final List<Booking> bookings = [];
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController roomPriceController = TextEditingController();

  AddRoomPage();

  Future<void> _saveRoom(Room newRoom) async {
    final url = Uri.https(
      'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'rooms.json',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(newRoom.toJson()),
      );

      if (response.statusCode == 200) {
        print('Room saved successfully');
      } else {
        print('Failed to save room');
      }
    } catch (error) {
      print('Error saving room: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Room'),
        backgroundColor:
            Colors.indigo, 
      ),
      body: 
      // Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [
      //         Color.fromARGB(255, 10, 6, 243), 
      //         Color.fromARGB(255, 236, 11, 225), 
      //         Color.fromARGB(255, 255, 0, 76), 
      //       ],
      //     ),
      //   ),
       Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roomNameController,
              decoration: InputDecoration(labelText: 'Room Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: roomPriceController,
              decoration: InputDecoration(labelText: 'Room Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String roomName = roomNameController.text;
                double roomPrice = double.parse(roomPriceController.text);
                Room newRoom = Room(name: roomName, price: roomPrice);

                await _saveRoom(newRoom);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      rooms: [],
                      bookings: [],
                    ),
                  ),
                );
              },
              child: Text('Add Room'),
            ),
          ],
        ),
      ),
      // ),
            drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelManagementHomePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('AddRooms'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRoomPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Booking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      rooms: [],
                      bookings: [],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('View Booking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewBookingPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

    );
  }
}
