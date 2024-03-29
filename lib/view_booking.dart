import 'package:flutter/material.dart';
import 'package:hotel_management/add_rooms.dart';
import 'package:hotel_management/booking.dart';
import 'package:hotel_management/homepage.dart';
import 'package:hotel_management/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewBookingPage extends StatefulWidget {
  ViewBookingPage({Key? key}) : super(key: key);

  @override
  _ViewBookingPageState createState() => _ViewBookingPageState();
}

class _ViewBookingPageState extends State<ViewBookingPage> {
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // Future<void> _fetchBookings() async {
  //   final url = Uri.https(
  //     'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
  //     'bookings.json',
  //   );

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body) as Map<String, dynamic>;
  //       List<Booking> fetchedBookings = [];

  //       data.forEach((key, value) {
  //         dynamic roomPrice = value['room']['price'];
  //         double convertedRoomPrice;

  //         if (roomPrice is int) {
  //           convertedRoomPrice = roomPrice.toDouble();
  //         } else if (roomPrice is double) {
  //           convertedRoomPrice = roomPrice;
  //         } else {
  //           throw Exception('Invalid price type for room');
  //         }

  //         Booking booking = Booking(
  //           guestName: value['guestName'],
  //           room: Room(
  //             name: value['room']['name'],
  //             price: convertedRoomPrice,
  //           ),
  //           startDate: DateTime.parse(value['startDate']),
  //           endDate: DateTime.parse(value['endDate']),
  //         );

  //         fetchedBookings.add(booking);
  //       });

  //       setState(() {
  //         bookings = fetchedBookings;
  //       });
  //     } else {
  //       throw Exception('Failed to load bookings');
  //     }
  //   } catch (error) {
  //     print('Error fetching bookings: $error');
  //   }
  // }

  // Future<void> _updateBooking(Booking booking) async {
  //   final url = Uri.https(
  //     'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
  //     'bookings/${booking.id}.json',
  //   );

  //   try {
  //     final response = await http.put(
  //       url,
  //       body: json.encode(booking.toJson()),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Booking updated successfully');
  //       await _fetchBookings();
  //     } else {
  //       print('Failed to update booking');
  //     }
  //   } catch (error) {
  //     print('Error updating booking: $error');
  //   }
  // }

Future<void> _fetchBookings() async {
  final url = Uri.https(
    'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
    'bookings.json',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      List<Booking> fetchedBookings = [];

      data.forEach((key, value) {
        // Handle both int and double types for 'price' in room
        dynamic roomPrice = value['room']['price'];
        double convertedRoomPrice;

        if (roomPrice is int) {
          convertedRoomPrice = roomPrice.toDouble();
        } else if (roomPrice is double) {
          convertedRoomPrice = roomPrice;
        } else {
          throw Exception('Invalid price type for room');
        }

        // Check if 'id' is null, if so, skip this booking entry
        if (key != null) {
          Booking booking = Booking(
            id: key.toString(), // Assign 'id' here
            guestName: value['guestName'],
            room: Room(
              name: value['room']['name'],
              price: convertedRoomPrice,
            ),
            startDate: DateTime.parse(value['startDate']),
            endDate: DateTime.parse(value['endDate']),
          );

          fetchedBookings.add(booking);
        }
      });

      setState(() {
        bookings = fetchedBookings;
      });
    } else {
      throw Exception('Failed to load bookings');
    }
  } catch (error) {
    print('Error fetching bookings: $error');
  }
}


Future<void> _deleteBooking(String? bookingId) async {
  if (bookingId == null) {
    print('Booking ID is null. Cannot delete.');
    return;
  }

  final url = Uri.https(
    'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
    'bookings/$bookingId.json',
  );

  print('Delete URL: $url'); // Print the URL for debugging

  try {
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Booking deleted successfully');
      await _fetchBookings();
    } else {
      print('Failed to delete booking. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    print('Error deleting booking: $error');
  }
}

Future<void> _updateBooking(Booking updatedBooking) async {
  final url = Uri.https(
    'hotel-e520a-default-rtdb.asia-southeast1.firebasedatabase.app',
    'bookings/${updatedBooking.id}.json',
  );

  try {
    final response = await http.put(
      url,
      body: json.encode(updatedBooking.toJson()),
    );

    if (response.statusCode == 200) {
      print('Booking updated successfully');
      // Optionally, you can update the local state or perform other actions after a successful update.
    } else {
      print('Failed to update booking. Status code: ${response.statusCode}');
      // Handle the case when the update fails
    }
  } catch (error) {
    print('Error updating booking: $error');
    // Handle the error when updating the booking
  }
}


  Future<void> _showEditDialog(BuildContext context, Booking booking) async {
    TextEditingController guestNameController =
        TextEditingController(text: booking.guestName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: guestNameController,
                decoration: InputDecoration(labelText: 'Guest Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                booking.guestName = guestNameController.text;
                _updateBooking(booking);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateRange(DateTime startDate, DateTime endDate) {
    final startDateFormat = DateFormat('MMM d, yyyy');
    final endDateFormat = DateFormat('MMM d, yyyy');
    return '${startDateFormat.format(startDate)} - ${endDateFormat.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Booking'),
        backgroundColor: Colors.indigo,
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
         bookings.isNotEmpty
            ? ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(bookings[index].guestName),
                    subtitle: Text(
                      'Room: ${bookings[index].room.name}, Date: ${_formatDateRange(bookings[index].startDate, bookings[index].endDate)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, bookings[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            print('Deleting booking: ${bookings[index].id}');
                            _deleteBooking(bookings[index].id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Text('No bookings available.'),
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
                    builder: (context) => BookingPage(rooms: [], bookings: []),
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
                  MaterialPageRoute(builder: (context) => ViewBookingPage()),
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
