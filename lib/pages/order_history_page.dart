import 'package:flutter/material.dart';

import 'chat_room_page.dart';
import 'marketplace_data.dart';
import 'ui_helpers.dart';

/// Riwayat pesanan + daftar penyedia yang pernah dipakai.
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Riwayat'),
          bottom: const TabBar(
            labelColor: kPrimary,
            indicatorColor: kPrimary,
            tabs: [Tab(text: 'Pesanan'), Tab(text: 'Penyedia Dipakai')],
          ),
        ),
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) => TabBarView(
            children: [
              OrderListView(store: store),
              _ProviderTab(store: store),
            ],
          ),
        ),
      ),
    );
  }
}

void _openChat(BuildContext context, String providerId) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ChatRoomPage(providerId: providerId)),
  );
}

/// Daftar pesanan (dipakai di tab Riwayat dan halaman Aktivitas).
class OrderListView extends StatelessWidget {
  final MarketplaceStore store;
  final EdgeInsets padding;
  const OrderListView({
    super.key,
    required this.store,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final orders = store.orders;
    if (orders.isEmpty) {
      return const Center(
        child: Text('Belum ada pesanan', style: TextStyle(color: kTextGrey)),
      );
    }

    return ListView.separated(
      padding: padding,
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = orders[i];
        final provider = store.providerById(order.offer.providerId);
        final done = order.status == OrderStatus.selesai;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.id,
                      style: const TextStyle(fontSize: 12, color: kTextGrey)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: (done ? Colors.green : Colors.orange)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      done ? 'Selesai' : 'Diproses',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: done ? Colors.green : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.offer.title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${provider.name} • ${formatDate(order.date)}',
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(order.offer.price),
                style: const TextStyle(
                    color: kPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _openChat(context, provider.id),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat'),
                  ),
                  if (!done)
                    // Hanya untuk demo; di aplikasi asli status dari penyedia.
                    TextButton.icon(
                      onPressed: () => store.completeOrder(order),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Tandai selesai'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderTab extends StatelessWidget {
  final MarketplaceStore store;
  const _ProviderTab({required this.store});

  @override
  Widget build(BuildContext context) {
    final used = store.usedProviders;
    if (used.isEmpty) {
      return const Center(
        child: Text('Belum ada penyedia yang dipakai',
            style: TextStyle(color: kTextGrey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: used.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final u = used[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: u.provider.color.withOpacity(0.15),
                child: Icon(u.provider.icon, color: u.provider.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.provider.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(u.provider.role,
                        style:
                            const TextStyle(fontSize: 12, color: kTextGrey)),
                    const SizedBox(height: 4),
                    Text(
                      '${u.orderCount} pesanan • ${formatRupiah(u.totalSpent)}\n'
                      'Terakhir: ${formatDate(u.lastUsed)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Chat lagi',
                icon: const Icon(Icons.chat_bubble_outline, color: kPrimary),
                onPressed: () => _openChat(context, u.provider.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
