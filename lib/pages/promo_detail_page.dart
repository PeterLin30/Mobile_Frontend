import 'package:flutter/material.dart';
import 'responsive.dart';

const Color _primary = Color(0xFF5CC8CC);
const Color _lightCyan = Color(0xFFC8F1F3);
const Color _darkTeal = Color(0xFF397E82);
const Color _textColor = Color(0xFF202124);

class PromoDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PromoDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  String get description {
    switch (title) {
      case 'Promo UMKM':
        return 'Penawaran khusus untuk membantu pelaku UMKM '
            'mengembangkan bisnis melalui layanan digital. '
            'Cocok untuk usaha yang ingin meningkatkan jangkauan '
            'pasar dan memperkuat kehadiran secara online.';
      case 'Paket Hemat':
        return 'Pilihan layanan digital dengan konsep hemat '
            'untuk membantu bisnis memenuhi kebutuhan teknologi '
            'sesuai anggaran. Pilih layanan yang paling sesuai '
            'dengan kebutuhan usaha kamu.';
      case 'Promo Desain':
        return 'Penawaran untuk mendukung identitas visual bisnis, '
            'mulai dari kebutuhan desain promosi hingga materi '
            'branding agar bisnis tampil lebih konsisten dan mudah '
            'dikenali oleh pelanggan.';
      default:
        return '$subtitle. Hubungi tim MikroHub untuk mengetahui '
            'rincian penawaran, layanan yang tersedia, dan syarat '
            'promo yang berlaku.';
    }
  }

  List<String> get benefits {
    switch (title) {
      case 'Promo UMKM':
        return [
          'Mendukung pengembangan bisnis UMKM.',
          'Membantu kebutuhan digital usaha.',
          'Mempermudah perencanaan pengembangan bisnis.',
        ];
      case 'Paket Hemat':
        return [
          'Pilihan layanan sesuai kebutuhan bisnis.',
          'Membantu perencanaan anggaran digital.',
          'Fokus pada layanan yang diperlukan.',
        ];
      case 'Promo Desain':
        return [
          'Mendukung identitas visual bisnis.',
          'Membantu kebutuhan materi promosi.',
          'Membangun tampilan merek yang konsisten.',
        ];
      default:
        return [
          'Informasi layanan lebih terarah.',
          'Pilihan sesuai kebutuhan usaha.',
          'Dukungan untuk pengembangan bisnis.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Promo'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveBody(
        maxWidth: 960,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        // HP portrait: header di atas. Landscape/tablet: header di kiri.
        child: AdaptiveSplit(
          gap: 24,
          primaryFlex: 2,
          secondaryFlex: 3,
          primary: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _lightCyan,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 48, color: _darkTeal),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: _textColor),
                  ),
                ],
              ),
            ),
          secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Penawaran',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manfaat Penawaran',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _darkTeal,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: _textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _lightCyan),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: _darkTeal),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Informasi ini merupakan contoh penawaran '
                      'untuk tampilan aplikasi. Hubungi pihak '
                      'MikroHub untuk memastikan harga, periode, '
                      'dan syarat promo yang sebenarnya.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: _textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
        ),
      ),
      ),
    );
  }
}
