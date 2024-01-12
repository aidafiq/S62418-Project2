import 'package:flutter/material.dart';
import 'package:hotel_management/add_rooms.dart';
import 'package:hotel_management/booking_confirmation.dart';
import 'package:hotel_management/homepage.dart';
import 'package:hotel_management/login.dart';
import 'package:hotel_management/view_booking.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final List<Room> rooms;
  final List<Booking> bookings;

  BookingPage({required this.rooms, required this.bookings});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime startDate;
  late DateTime endDate;
  Room? selectedRoom;
  final TextEditingController guestNameController = TextEditingController();
  late List<Room> availableRooms;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    startDate = DateTime.now();
    endDate = DateTime.now();
  }

  Future<void> _fetchRooms() async {
    final url = Uri.https(
      'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'rooms.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        List<Room> fetchedRooms = [];

        data.forEach((key, value) {
          fetchedRooms.add(Room(
            name: value['name'],
            price: (value['price'] as int).toDouble(),
          ));
        });

        setState(() {
          availableRooms = fetchedRooms;
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (error) {
      print('Error fetching rooms: $error');
    }
  }

  Future<void> _saveBooking(Booking newBooking) async {
    final url = Uri.https(
      'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'bookings.json',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(newBooking.toJson()),
      );

      if (response.statusCode == 200) {
        print('Booking saved successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationPage(
              room: newBooking.room,
              bookings: widget.bookings,
            ),
          ),
        );
      } else {
        print('Failed to save booking');
      }
    } catch (error) {
      print('Error saving booking: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Room'),
        backgroundColor:
            Colors.lightBlueAccent, 
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Available Rooms:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: availableRooms != null
                ? ListView.builder(
                    itemCount: availableRooms.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(availableRooms[index].name),
                        subtitle: Text(
                            '\RM${availableRooms[index].price.toStringAsFixed(2)}'),
                        onTap: () {
                          setState(() {
                            selectedRoom = availableRooms[index];
                          });
                        },
                      );
                    },
                  )
                : CircularProgressIndicator(),
          ),
          if (selectedRoom != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: guestNameController,
                decoration: InputDecoration(labelText: 'Enter Your Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  DateTimeRange? pickedDateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      Duration(days: 365),
                    ),
                    initialDateRange: DateTimeRange(
                      start: startDate,
                      end: endDate,
                    ),
                  );

                  if (pickedDateRange != null &&
                      pickedDateRange !=
                          DateTimeRange(
                            start: startDate,
                            end: endDate,
                          )) {
                    setState(() {
                      startDate = pickedDateRange.start;
                      endDate = pickedDateRange.end;
                    });
                  }
                },
                child: Text('Choose Date Range'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  String guestName = guestNameController.text;
                  Booking newBooking = Booking(
                    guestName: guestName,
                    room: selectedRoom!,
                    startDate: startDate,
                    endDate: endDate,
                  );

                  await _saveBooking(newBooking);

                  setState(() {
                    selectedRoom = null;
                    guestNameController.clear();
                    startDate = DateTime.now();
                    endDate = DateTime.now();
                  });
                },
                child: Text('Book Room'),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: Colors.blueGrey[200],
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
