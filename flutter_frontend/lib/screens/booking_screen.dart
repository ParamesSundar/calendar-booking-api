import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../widgets/booking_form.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Booking> bookings = [];
  Booking? bookingById;
  final idController = TextEditingController();
  String message = '';

  Future<void> loadBookings() async {
    try {
      final allBookings = await BookingService.getAllBookings();
      setState(() {
        bookings = allBookings;
        message = '';
      });
    } catch (e) {
      setState(() => message = 'Failed to load bookings');
    }
  }

  Future<void> loadBookingById() async {
    if (idController.text.isEmpty) return;
    try {
      final booking = await BookingService.getBookingById(idController.text);
      setState(() {
        bookingById = booking;
        message = '';
      });
    } catch (e) {
      setState(() {
        bookingById = null;
        message = 'Booking not found';
      });
    }
  }

  Future<void> deleteBooking(String id) async {
    final result = await BookingService.deleteBooking(id);
    setState(() => message = result);
    await loadBookings();
  }

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Booking')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingForm(onBookingCreated: loadBookings),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Enter Booking ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: loadBookingById,
                child: const Text('Get Booking by ID'),
              ),
              if (bookingById != null) ...[
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: Text('User ID: ${bookingById!.userId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText('ID: ${bookingById!.id}'),
                        Text('Start: ${bookingById!.startTime}'),
                        Text('End: ${bookingById!.endTime}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await deleteBooking(bookingById!.id);
                        setState(() {
                          bookingById = null;
                          idController.clear();
                        });
                      },
                    ),
                  ),
                ),
              ],
              const Divider(height: 32),
              const Text('All Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...bookings.map(
                (b) => Card(
                  child: ListTile(
                    title: Text('User ID: ${b.userId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText('ID: ${b.id}'),
                        Text('Start: ${b.startTime}'),
                        Text('End: ${b.endTime}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteBooking(b.id),
                    ),
                  ),
                ),
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(message, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
