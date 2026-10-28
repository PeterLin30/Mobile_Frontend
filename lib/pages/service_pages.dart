import 'package:flutter/material.dart';

import 'chat_room_page.dart';
import 'marketplace_data.dart';
import 'purchase_flow.dart';
import 'ui_helpers.dart';

/// Daftar layanan dari semua penyedia, dengan filter kategori.
class ServiceListPage extends StatefulWidget {
  final String initialCategory;
  const ServiceListPage({super.key, this.initialCategory = 'Semua'});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  final _store = MarketplaceStore.instance;
  late String _category = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    final offers = _store.offersByCategory(_category);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Jelajahi Layanan')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _store.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _store.categories[i];
                return ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  selectedColor: kPrimary.withOpacity(0.25),
                  onSelected: (_) => setState(() => _category = c),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final offer = offers[i];
                final provider = _store.providerById(offer.providerId);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailPage(offer: offer),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: provider.color.withOpacity(0.15),
                          child: Icon(provider.icon, color: provider.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.title,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                provider.name,
                                style: const TextStyle(
                                    fontSize: 12, color: kTextGrey),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatRupiah(offer.price),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: kPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kTextGrey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail layanan. Tombol Beli baru aktif setelah pengguna chat penyedia.
class ServiceDetailPage extends StatelessWidget {
  final ServiceOffer offer;
  const ServiceDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    final provider = store.providerById(offer.providerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Layanan')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final canBuy = store.hasChatted(provider.id);
          final ordered = store.hasOrdered(offer.id);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(offer.price),
                      style: const TextStyle(
                        fontSize: 18,
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(offer.category)),
                        Chip(
                          avatar: const Icon(Icons.schedule, size: 16),
                          label: Text(offer.duration),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      offer.description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Penyedia',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextGrey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: cardDecoration(),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: provider.color.withOpacity(0.15),
                            child: Icon(provider.icon, color: provider.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  provider.role,
                                  style: const TextStyle(
                                      fontSize: 12, color: kTextGrey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.bio,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              Text(provider.rating.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!canBuy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Chat penyedia dulu untuk bisa membeli layanan ini',
                            style: TextStyle(fontSize: 12, color: kTextGrey),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomPage(
                                    providerId: provider.id,
                                    offer: offer,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Chat'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                foregroundColor: kPrimary,
                                side: const BorderSide(color: kPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: (canBuy && !ordered)
                                  ? () => confirmPurchase(context, offer)
                                  : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: kPrimary,
                              ),
                              child: Text(ordered ? 'Sudah Dipesan' : 'Beli Layanan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
