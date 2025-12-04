import 'package:flutter/material.dart';

class AboutAppModal extends StatelessWidget {
  const AboutAppModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EventHub',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text('v1.0.0', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tentang Aplikasi',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'EventHub adalah platform all-in-one untuk menyewa jasa profesional untuk berbagai kebutuhan event Anda. '
            'Aplikasi ini menghubungkan Customer dengan Vendor terpercaya dalam satu tempat yang mudah digunakan.',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 20),
          Text('Untuk Vendor', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            'Vendor dapat menambah dan mengelola paket layanan mereka langsung melalui aplikasi, '
            'memudahkan dalam menjangkau lebih banyak customer potensial.',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  // Navigasi ke halaman terms
                },
                child: const Text('Ketentuan Layanan'),
              ),
              TextButton(
                onPressed: () {
                  // Navigasi ke halaman privacy
                },
                child: const Text('Kebijakan Privasi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
