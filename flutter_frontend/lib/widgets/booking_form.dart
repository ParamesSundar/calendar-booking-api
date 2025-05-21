import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingForm extends StatefulWidget {
  final VoidCallback onBookingCreated;
  const BookingForm({super.key, required this.onBookingCreated});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final userController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  String message = '';
  bool isSubmitting = false;

  bool get isFormValid =>
      userController.text.isNotEmpty && startTime != null && endTime != null;

  Future<void> submitBooking() async {
    if (!isFormValid) {
      setState(() => message = "Fill all fields");
      return;
    }

    setState(() => isSubmitting = true);

    Booking booking = Booking(
      id: '',
      userId: userController.text,
      startTime: startTime!.toUtc().toIso8601String(),
      endTime: endTime!.toUtc().toIso8601String(),
    );

    String result = await BookingService.createBooking(booking);
    setState(() => message = result);
    widget.onBookingCreated();
    setState(() {
      userController.clear();
      startTime = null;
      endTime = null;
      isSubmitting = false;
    });
  }

  Future<void> pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selected =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      isStart ? startTime = selected : endTime = selected;
    });
  }

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: userController,
            decoration: const InputDecoration(labelText: 'User ID'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => pickDateTime(true),
                  child: Text(startTime == null
                      ? 'Pick Start Time'
                      : dateFormat.format(startTime!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => pickDateTime(false),
                  child: Text(endTime == null
                      ? 'Pick End Time'
                      : dateFormat.format(endTime!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFormValid && !isSubmitting ? submitBooking : null,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Book"),
            ),
          ),
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child:
                  Text(message, style: const TextStyle(color: Colors.green)),
            ),
        ],
      ),
    );
  }
}

