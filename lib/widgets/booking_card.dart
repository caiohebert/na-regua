import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../db/booking_db.dart';

class StatusText extends StatelessWidget {
  final String status;
  final BookingModel booking;

  const StatusText({super.key, required this.status, required this.booking});

  Color get color {
    switch (status) {
      case 'upcoming':
      case 'PENDING':
      case 'CONFIRMED':
        return const Color(0xFFEDB33C);
      case 'completed':
      case 'COMPLETED':
        return Colors.green;
      case 'canceled':
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get displayText {
    switch (status) {
      case 'upcoming':
      case 'PENDING':
      case 'CONFIRMED':
        return 'AGENDADO';
      case 'completed':
      case 'COMPLETED':
        return 'CONCLUÍDO';
      case 'canceled':
      case 'CANCELLED':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
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

  // Função para exibir o diálogo de confirmação
  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2024), // Mantendo o tema dark
          title: const Text(
            "Cancelar Agendamento?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Tem certeza que deseja cancelar? Essa ação não pode ser desfeita e o horário ficará vago.",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            // Botão NÃO (Voltar)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Voltar", style: TextStyle(color: Colors.white)),
            ),
            // Botão SIM (Confirmar cancelamento)
            TextButton(
              onPressed: () async {
                // 1. Fecha o diálogo primeiro
                Navigator.of(dialogContext).pop();

                // 2. Chama a atualização no banco de dados
                await updateBooking(booking, 'canceled');

                // 3. Exibe o aviso de sucesso (SnackBar)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Agendamento cancelado. O barbeiro foi notificado.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text(
                "Confirmar Cancelamento",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.cancel, color: Colors.red),
      // Agora chamamos a função que abre o diálogo
      onPressed: () => _showCancelConfirmation(context),
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
                  booking.barber?.imageUrl ?? 'https://via.placeholder.com/150',
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
                      booking.barber?.name ?? 'Unknown Barber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      booking.service?.name ?? 'Unknown Service',
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
              if (booking.status == 'upcoming' || booking.status == 'PENDING' || booking.status == 'CONFIRMED') ...[
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
