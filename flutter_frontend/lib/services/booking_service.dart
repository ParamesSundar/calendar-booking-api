// services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking.dart';

class BookingService {
  static Future<List<Booking>> getAllBookings() async {
    final response = await http.get(Uri.parse('$BASE_URL/bookings'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((b) => Booking.fromJson(b)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  static Future<Booking> getBookingById(String id) async {
    final response = await http.get(Uri.parse('$BASE_URL/bookings/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data);
    } else {
      throw Exception('Booking not found');
    }
  }

  static Future<String> createBooking(Booking booking) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode == 201) {
      return 'Booking created successfully';
    } else {
      return jsonDecode(response.body)['error'] ?? 'Unknown error';
    }
  }

  static Future<String> deleteBooking(String id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/bookings/$id'));

    if (response.statusCode == 200) {
      return 'Booking deleted successfully';
    } else {
      return jsonDecode(response.body)['error'] ?? 'Delete failed';
    }
  }
}
