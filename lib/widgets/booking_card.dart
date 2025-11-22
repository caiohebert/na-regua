import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../db/booking_db.dart';

class StatusText extends StatelessWidget {
  final String status;
  final BookingModel booking;

  const StatusText({super.key, required this.status, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'upcoming'
            ? const Color(0xFFEDB33C).withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: status == 'upcoming'
              ? const Color(0xFFEDB33C)
              : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final BookingModel booking;

  const CancelButton({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.cancel, color: Colors.red),
      onPressed: () async {
        await updateBooking(booking, 'canceled');
      },
      style: IconButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class ScheludedTime extends StatelessWidget {
  final BookingModel booking;

  const ScheludedTime({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMM d, yyyy').format(booking.date),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Text(
          DateFormat('h:mm a').format(booking.date),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2024),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  booking.barber.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.barber.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      booking.service.name,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              StatusText(status: booking.status, booking: booking),
              const SizedBox(width: 8),
              if (booking.status == 'upcoming') ...[
                const SizedBox(width: 8),
                CancelButton(booking: booking),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ScheludedTime(booking: booking),
        ],
      ),
    );
  }
}
