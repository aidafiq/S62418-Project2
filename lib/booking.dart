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
  late List<Room> availableRooms = [];

  @override
  void initState() {
    super.initState();
    availableRooms = [];
    _fetchRooms(); // Load available rooms when the page is initialized
    startDate = DateTime.now();
    endDate = DateTime.now();
  }

  Future<void> _fetchRooms() async {
    final urlRooms = Uri.https(
      'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'rooms.json',
    );

    try {
      final responseRooms = await http.get(urlRooms);

      print('Firebase Response Body: ${responseRooms.body}');

      if (responseRooms.statusCode == 200) {
        final dataRooms = json.decode(responseRooms.body) as Map<String, dynamic>;
        List<Room> fetchedRooms = [];

        // dataRooms.forEach((key, value) {
        //   fetchedRooms.add(Room(
        //     name: value['name'],
        //     price: (value['price'] as int).toDouble(),
        //   ));
        // });
        dataRooms.forEach((key, value) {
        fetchedRooms.add(Room.fromJson(value));
      });

        setState(() {
          availableRooms = fetchedRooms;
        });
        print('Room available: $availableRooms');
      } else {
        print('Failed to load rooms. Status code: ${responseRooms.statusCode}');
      }
    } catch (error) {
      print('Error fetching rooms: $error');
    }
  }

  Future<void> _saveBooking(Booking newBooking) async {
    final urlBookings = Uri.https(
      'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
      'bookings.json',
    );

    try {
      final responseBookings = await http.post(
        urlBookings,
        body: json.encode(newBooking.toJson()),
      );

      if (responseBookings.statusCode == 200) {
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
        print('Failed to save booking. Status code: ${responseBookings.statusCode}');
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
        backgroundColor: Colors.indigo,
      ),
      body:
      //  Container(
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
        Column(
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
              child: availableRooms.isNotEmpty
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
                    : Center (
                      child: CircularProgressIndicator(),
                    )
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
                      id: '',
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
