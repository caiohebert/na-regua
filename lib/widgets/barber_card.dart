import 'package:flutter/material.dart';
import '../models/barber_model.dart';
import '../pages/barber_details_page.dart';

/*
  BarberInfo sub-widget to display barber details (name, rating, location)
*/
class BarberInfo extends StatelessWidget {
  const BarberInfo({
    super.key,
    required this.barber,
  });

  final BarberModel barber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          barber.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFD700), size: 16.0),
            const SizedBox(width: 4.0),
            Text(
              barber.rating.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          barber.location,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }
}

/*
  BarberCard widget to display barber information in a card format
  (Picture, Name, Rating, Location, View Button)
*/
class BarberCard extends StatelessWidget {
  final BarberModel barber;

  const BarberCard({
    super.key,
    required this.barber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2024), // Dark card background
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // Barber Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // Slightly rounded square or circle
            child: Image.network(
              barber.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: Colors.grey,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Barber Info
          Expanded(
            child: BarberInfo(barber: barber),
          ),
          // View Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BarberDetailsPage(barber: barber),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEDB33C), // Yellow/Gold color
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              minimumSize: const Size(0, 36),
            ),
            child: const Text(
              'View',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}