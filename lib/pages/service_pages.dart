import 'package:flutter/material.dart';

import 'chat_room_page.dart';
import 'marketplace_data.dart';
import 'purchase_flow.dart';
import 'ui_helpers.dart';
import 'project_flow_pages.dart';

/// Daftar layanan dari semua penyedia, dengan filter kategori.
class ServiceListPage extends StatefulWidget {
  final String initialCategory;
  const ServiceListPage({super.key, this.initialCategory = 'Semua'});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  final _store = MarketplaceStore.instance;
  final _searchController = TextEditingController();
  late String _category = _store.categories.contains(widget.initialCategory)
      ? widget.initialCategory
      : 'Semua';
  String _sort = 'Relevansi';
  double _minimumRating = 0;
  bool _favoritesOnly = false;
  int _maxPrice = 10000000;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceOffer> _filteredOffers() {
    final query = _searchController.text.trim().toLowerCase();
    final results = _store.offers.where((offer) {
      final provider = _store.providerById(offer.providerId);
      final matchesQuery = query.isEmpty ||
          offer.title.toLowerCase().contains(query) ||
          offer.description.toLowerCase().contains(query) ||
          offer.category.toLowerCase().contains(query) ||
          provider.name.toLowerCase().contains(query) ||
          provider.bio.toLowerCase().contains(query);
      return matchesQuery &&
          (_category == 'Semua' || offer.category == _category) &&
          offer.price <= _maxPrice &&
          provider.rating >= _minimumRating &&
          (!_favoritesOnly || _store.isFavorite(offer.id));
    }).toList();

    switch (_sort) {
      case 'Harga terendah':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga tertinggi':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating tertinggi':
        results.sort((a, b) => _store.providerById(b.providerId).rating
            .compareTo(_store.providerById(a.providerId).rating));
        break;
      default:
        // Relevansi sederhana: judul yang cocok dengan kata kunci didahulukan.
        if (query.isNotEmpty) {
          results.sort((a, b) {
            final aTitle = a.title.toLowerCase().contains(query) ? 0 : 1;
            final bTitle = b.title.toLowerCase().contains(query) ? 0 : 1;
            return aTitle.compareTo(bTitle);
          });
        }
    }
    return results;
  }

  Future<void> _showFilters() async {
    double tempRating = _minimumRating;
    int tempPrice = _maxPrice;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter layanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              const Text('Rating minimum'),
              Slider(
                value: tempRating,
                min: 0,
                max: 5,
                divisions: 5,
                label: tempRating == 0 ? 'Semua' : tempRating.toStringAsFixed(1),
                onChanged: (value) => setSheetState(() => tempRating = value),
              ),
              Text(tempRating == 0 ? 'Semua rating' : '${tempRating.toStringAsFixed(1)} bintang ke atas'),
              const SizedBox(height: 14),
              const Text('Anggaran maksimum'),
              Slider(
                value: tempPrice.toDouble(),
                min: 500000,
                max: 10000000,
                divisions: 19,
                label: formatRupiah(tempPrice),
                onChanged: (value) => setSheetState(() => tempPrice = value.round()),
              ),
              Text(formatRupiah(tempPrice)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheetContext, true), child: const Text('Terapkan'))),
              ]),
            ],
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        _minimumRating = tempRating;
        _maxPrice = tempPrice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Jelajahi Layanan'),
        actions: [
          IconButton(
            tooltip: 'Penawaran saya',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotationListPage())),
            icon: const Icon(Icons.request_quote_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final offers = _filteredOffers();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari layanan, kategori, atau penyedia...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() {}); }),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _store.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final category = _store.categories[i];
                    return ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      selectedColor: kPrimary.withOpacity(0.25),
                      onSelected: (_) => setState(() => _category = category),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Row(children: [
                  Text('${offers.length} layanan', style: const TextStyle(color: kTextGrey, fontSize: 12)),
                  const Spacer(),
                  FilterChip(
                    avatar: Icon(_favoritesOnly ? Icons.favorite : Icons.favorite_border, size: 17),
                    label: const Text('Favorit'),
                    selected: _favoritesOnly,
                    onSelected: (value) => setState(() => _favoritesOnly = value),
                  ),
                  const SizedBox(width: 6),
                  IconButton(tooltip: 'Filter harga dan rating', onPressed: _showFilters, icon: const Icon(Icons.tune)),
                  const SizedBox(width: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sort,
                      isDense: true,
                      items: const ['Relevansi', 'Harga terendah', 'Harga tertinggi', 'Rating tertinggi'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (value) { if (value != null) setState(() => _sort = value); },
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: offers.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.search_off, size: 48, color: kTextGrey), const SizedBox(height: 12), const Text('Layanan tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('Coba kata kunci atau filter yang berbeda.', textAlign: TextAlign.center, style: TextStyle(color: kTextGrey)), TextButton(onPressed: () => setState(() { _searchController.clear(); _category = 'Semua'; _minimumRating = 0; _maxPrice = 10000000; _favoritesOnly = false; _sort = 'Relevansi'; }), child: const Text('Reset pencarian'))])))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: offers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final offer = offers[i];
                          final provider = _store.providerById(offer.providerId);
                          final favorite = _store.isFavorite(offer.id);
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailPage(offer: offer))),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: cardDecoration(),
                              child: Row(children: [
                                CircleAvatar(radius: 24, backgroundColor: provider.color.withOpacity(0.15), child: Icon(provider.icon, color: provider.color)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(offer.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(provider.name, style: const TextStyle(fontSize: 12, color: kTextGrey)),
                                  const SizedBox(height: 5),
                                  Row(children: [const Icon(Icons.star, size: 15, color: Colors.amber), const SizedBox(width: 3), Text(provider.rating.toString(), style: const TextStyle(fontSize: 12)), const SizedBox(width: 8), Text(offer.category, style: const TextStyle(fontSize: 12, color: kTextGrey))]),
                                  const SizedBox(height: 5),
                                  Text(formatRupiah(offer.price), style: const TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.bold)),
                                ])),
                                IconButton(tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit', onPressed: () => _store.toggleFavorite(offer.id), icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.redAccent : kTextGrey)),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RequestQuotationPage(offer: offer)),
                          ),
                          icon: const Icon(Icons.request_quote_outlined),
                          label: const Text('Minta Penawaran & Buat Proyek'),
                          style: TextButton.styleFrom(foregroundColor: kPrimary),
                        ),
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
