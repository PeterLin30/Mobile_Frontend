import 'package:flutter/material.dart';

import 'marketplace_data.dart';
import 'ui_helpers.dart';

/// Dialog konfirmasi lalu buat pesanan. Dipakai di halaman detail & ruang chat.
Future<void> confirmPurchase(BuildContext context, ServiceOffer offer) async {
  final store = MarketplaceStore.instance;

  if (!store.hasChatted(offer.providerId)) {
    showToast(context, 'Kirim pesan ke penyedia dulu sebelum membeli');
    return;
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi pesanan'),
      content: Text(
        '${offer.title}\n${formatRupiah(offer.price)} • ${offer.duration}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Pesan', style: TextStyle(color: kPrimary)),
        ),
      ],
    ),
  );

  if (ok == true && context.mounted) {
    final order = store.buy(offer);
    if (order != null) {
      showToast(context, 'Pesanan ${order.id} berhasil dibuat');
    }
  }
}
