import 'package:flutter/material.dart';

import 'marketplace_data.dart';
import 'order_history_page.dart';
import 'ui_helpers.dart';
import 'responsive.dart';

/// Tab "Aktivitas": riwayat pembelian layanan oleh pengguna.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Aktivitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final orders = store.orders;
          final total = orders.fold<int>(0, (sum, o) => sum + o.offer.price);
          final active =
              orders.where((o) => o.status == OrderStatus.diproses).length;

          return ResponsiveBody(
            maxWidth: 960,
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _SummaryCard(label: 'Total Pesanan', value: '${orders.length}'),
                    const SizedBox(width: 12),
                    _SummaryCard(label: 'Diproses', value: '$active'),
                    const SizedBox(width: 12),
                    _SummaryCard(label: 'Total Belanja', value: formatRupiah(total)),
                  ],
                ),
              ),
              Expanded(
                child: OrderListView(
                  store: store,
                  // padding bawah besar supaya tidak tertutup navbar
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: cardDecoration(),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 11, color: kTextGrey)),
          ],
        ),
      ),
    );
  }
}
