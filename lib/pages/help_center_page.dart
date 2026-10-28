import 'package:flutter/material.dart';

import 'ui_helpers.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static const List<List<String>> _faqs = [
    [
      'Bagaimana cara mencari developer?',
      'Buka tab Home, pilih kategori Developer App, lalu kirim brief proyekmu.'
    ],
    [
      'Bagaimana cara mengajukan bantuan bisnis?',
      'Pilih menu Bantuan Bisnis di tab Home, lalu ikuti langkah pendaftarannya.'
    ],
    [
      'Apakah MikroHub berbayar?',
      'Membuat akun gratis. Biaya hanya muncul jika kamu menyewa jasa developer.'
    ],
    [
      'Bagaimana cara mengubah peran akun?',
      'Buka Edit Profil, lalu pilih peran baru di bagian Peran.'
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final f in _faqs)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: cardDecoration(),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(f[0], style: const TextStyle(fontSize: 14)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f[1], style: const TextStyle(color: kTextGrey)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => showToast(context, 'Menghubungkan ke tim dukungan...'),
            icon: const Icon(Icons.support_agent),
            label: const Text('Hubungi Kami'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
