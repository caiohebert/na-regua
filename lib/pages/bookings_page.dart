import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(booking: booking);
              },
            ),
    );
  }
}
