import 'package:flutter/material.dart';

import 'chat_room_page.dart';
import 'marketplace_data.dart';
import 'purchase_flow.dart';
import 'ui_helpers.dart';
import 'project_flow_pages.dart';
import 'responsive.dart';

/// Daftar layanan dari semua penyedia: pencarian, pengelompokan, dan filter.
class ServiceListPage extends StatefulWidget {
  final String initialCategory;
  const ServiceListPage({super.key, this.initialCategory = 'Semua'});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  static const int _defaultMaxPrice = 10000000;
  static const List<String> _sortOptions = [
    'Relevansi',
    'Harga terendah',
    'Harga tertinggi',
    'Rating tertinggi',
    'Pengalaman terbanyak',
    'Proyek terbanyak',
    'Tercepat',
  ];

  // Kata lain yang dianggap sama saat mencari.
  static const Map<String, List<String>> _synonyms = {
    'kasir': ['pos'],
    'pos': ['kasir'],
    'online': ['e-commerce', 'toko online'],
    'situs': ['website'],
    'web': ['website'],
    'desain': ['logo', 'branding', 'kemasan'],
    'izin': ['nib', 'perizinan', 'legalitas'],
    'modal': ['kur', 'pendanaan', 'pinjaman'],
    'pinjaman': ['kur'],
    'aman': ['keamanan', 'siber'],
    'siber': ['keamanan', 'cyber'],
    'hacker': ['keamanan'],
    'ig': ['instagram'],
    'iklan': ['ads'],
    'aplikasi': ['app', 'mobile'],
    'hp': ['mobile', 'android'],
  };

  final _store = MarketplaceStore.instance;
  final _searchController = TextEditingController();
  late String _category = _store.categories.contains(widget.initialCategory)
      ? widget.initialCategory
      : 'Semua';
  String _subCategory = 'Semua';
  String _sort = 'Relevansi';
  String _grouping = 'Daftar'; // Daftar | Kategori | Penyedia
  String _role = 'Semua';
  String _location = 'Semua';
  double _minimumRating = 0;
  bool _favoritesOnly = false;
  bool _verifiedOnly = false;
  int _maxPrice = _defaultMaxPrice;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_minimumRating > 0) count++;
    if (_maxPrice < _defaultMaxPrice) count++;
    if (_role != 'Semua') count++;
    if (_location != 'Semua') count++;
    if (_verifiedOnly) count++;
    return count;
  }

  List<String> _tokens() => _searchController.text
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();

  static bool _isAlnum(int c) =>
      (c >= 48 && c <= 57) || (c >= 97 && c <= 122);

  /// Kata kunci harus cocok di awal kata, sehingga "pos" tidak ikut cocok
  /// dengan "proposal" dan "kur" tidak cocok dengan "pengurusan".
  static bool _wordStartMatch(String field, String word) {
    var i = field.indexOf(word);
    while (i != -1) {
      if (i == 0 || !_isAlnum(field.codeUnitAt(i - 1))) return true;
      i = field.indexOf(word, i + 1);
    }
    return false;
  }

  /// Nilai kecocokan pencarian. -1 berarti ada kata yang tidak ditemukan.
  /// Kecocokan di judul, tag, keahlian, atau nama bernilai lebih tinggi
  /// daripada kecocokan di deskripsi.
  int _matchScore(
    ServiceOffer offer,
    ServiceProvider provider,
    List<String> tokens,
  ) {
    if (tokens.isEmpty) return 0;
    final strong = <String>[
      offer.title,
      offer.subCategory,
      offer.category,
      provider.name,
      ...offer.tags,
      ...provider.skills,
    ].map((e) => e.toLowerCase()).toList();
    final weak = <String>[
      offer.description,
      provider.bio,
      provider.role,
      provider.location,
      ...offer.includes,
      ...offer.tools,
    ].map((e) => e.toLowerCase()).toList();
    final title = offer.title.toLowerCase();

    var total = 0;
    for (final token in tokens) {
      final variants = <String>[token, ...(_synonyms[token] ?? const <String>[])];
      var best = 0;
      for (final v in variants) {
        if (strong.any((f) => _wordStartMatch(f, v))) {
          best = 3;
          break;
        }
        if (best < 1 && weak.any((f) => _wordStartMatch(f, v))) best = 1;
      }
      if (best == 0) return -1;
      total += best + (_wordStartMatch(title, token) ? 2 : 0);
    }
    return total;
  }

  List<ServiceOffer> _filteredOffers() {
    final tokens = _tokens();
    final scores = <String, int>{};
    final results = _store.offers.where((offer) {
      final provider = _store.providerById(offer.providerId);
      final score = _matchScore(offer, provider, tokens);
      if (score < 0) return false;
      scores[offer.id] = score;
      return (_category == 'Semua' || offer.category == _category) &&
          (_subCategory == 'Semua' || offer.subCategory == _subCategory) &&
          offer.price <= _maxPrice &&
          provider.rating >= _minimumRating &&
          (_role == 'Semua' || provider.role == _role) &&
          (_location == 'Semua' || provider.location == _location) &&
          (!_verifiedOnly || provider.verified) &&
          (!_favoritesOnly || _store.isFavorite(offer.id));
    }).toList();

    ServiceProvider providerOf(ServiceOffer o) =>
        _store.providerById(o.providerId);

    switch (_sort) {
      case 'Harga terendah':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga tertinggi':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating tertinggi':
        results.sort((a, b) => providerOf(b).rating.compareTo(providerOf(a).rating));
        break;
      case 'Pengalaman terbanyak':
        results.sort((a, b) =>
            providerOf(b).experienceYears.compareTo(providerOf(a).experienceYears));
        break;
      case 'Proyek terbanyak':
        results.sort((a, b) =>
            providerOf(b).completedProjects.compareTo(providerOf(a).completedProjects));
        break;
      case 'Tercepat':
        results.sort((a, b) => a.durationDays.compareTo(b.durationDays));
        break;
      default:
        if (tokens.isNotEmpty) {
          results.sort((a, b) => (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0));
        }
    }
    return results;
  }

  void _resetAll() {
    setState(() {
      _searchController.clear();
      _category = 'Semua';
      _subCategory = 'Semua';
      _role = 'Semua';
      _location = 'Semua';
      _minimumRating = 0;
      _maxPrice = _defaultMaxPrice;
      _favoritesOnly = false;
      _verifiedOnly = false;
      _sort = 'Relevansi';
    });
  }

  Future<void> _showFilters() async {
    double tempRating = _minimumRating;
    int tempPrice = _maxPrice;
    String tempRole = _role;
    String tempLocation = _location;
    bool tempVerified = _verifiedOnly;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 8, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter layanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Jenis penyedia'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final role in ['Semua', ..._store.providerRoles])
                      ChoiceChip(
                        label: Text(role),
                        selected: tempRole == role,
                        onSelected: (_) => setSheetState(() => tempRole = role),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Lokasi penyedia'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final city in ['Semua', ..._store.locations])
                      ChoiceChip(
                        label: Text(city),
                        selected: tempLocation == city,
                        onSelected: (_) =>
                            setSheetState(() => tempLocation = city),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Rating minimum'),
                Slider(
                  value: tempRating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: tempRating == 0 ? 'Semua' : tempRating.toStringAsFixed(1),
                  onChanged: (value) => setSheetState(() => tempRating = value),
                ),
                Text(tempRating == 0
                    ? 'Semua rating'
                    : '${tempRating.toStringAsFixed(1)} bintang ke atas'),
                const SizedBox(height: 14),
                const Text('Anggaran maksimum'),
                Slider(
                  value: tempPrice.toDouble(),
                  min: 500000,
                  max: 10000000,
                  divisions: 19,
                  label: formatRupiah(tempPrice),
                  onChanged: (value) =>
                      setSheetState(() => tempPrice = value.round()),
                ),
                Text(formatRupiah(tempPrice)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hanya penyedia terverifikasi'),
                  value: tempVerified,
                  onChanged: (value) => setSheetState(() => tempVerified = value),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setSheetState(() {
                        tempRating = 0;
                        tempPrice = _defaultMaxPrice;
                        tempRole = 'Semua';
                        tempLocation = 'Semua';
                        tempVerified = false;
                      }),
                      child: const Text('Atur ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: const Text('Terapkan'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        _minimumRating = tempRating;
        _maxPrice = tempPrice;
        _role = tempRole;
        _location = tempLocation;
        _verifiedOnly = tempVerified;
      });
    }
  }

  Widget _chipRow(List<String> labels, String selected, ValueChanged<String> onTap,
      {double height = 48}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(
          label: Text(labels[i]),
          selected: selected == labels[i],
          selectedColor: kPrimary.withOpacity(0.25),
          onSelected: (_) => onTap(labels[i]),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: kTextGrey),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }

  Widget _offerCard(ServiceOffer offer) {
    final provider = _store.providerById(offer.providerId);
    final favorite = _store.isFavorite(offer.id);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ServiceDetailPage(offer: offer)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(offer.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Flexible(
                      child: Text(provider.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: kTextGrey)),
                    ),
                    if (provider.verified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, size: 14, color: kPrimary),
                      ),
                  ]),
                  Text('${provider.role} • ${provider.location}',
                      style: const TextStyle(fontSize: 12, color: kTextGrey)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 2,
                    children: [
                      _meta(Icons.star, '${provider.rating} (${provider.reviewCount})'),
                      _meta(Icons.work_outline, '${provider.experienceYears} thn'),
                      _meta(Icons.task_alt, '${provider.completedProjects} proyek'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final tag in [offer.subCategory, ...offer.tags.take(2)])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(tag, style: const TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(formatRupiah(offer.price),
                        style: const TextStyle(
                            fontSize: 14, color: kPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('• ${offer.duration}',
                        style: const TextStyle(fontSize: 12, color: kTextGrey)),
                  ]),
                ],
              ),
            ),
            IconButton(
              tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
              onPressed: () => _store.toggleFavorite(offer.id),
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? Colors.redAccent : kTextGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardList(List<ServiceOffer> items) {
    return ResponsiveCardList(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: items.length,
      minTileWidth: 400,
      maxColumns: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) => _offerCard(items[i]),
    );
  }

  Widget _groupHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ]),
    );
  }

  List<Widget> _resultWidgets(List<ServiceOffer> offers) {
    if (_grouping == 'Kategori') {
      return [
        for (final category in _store.categories.where((c) => c != 'Semua'))
          if (offers.any((o) => o.category == category)) ...[
            _groupHeader(category,
                '${offers.where((o) => o.category == category).length} layanan'),
            _cardList(offers.where((o) => o.category == category).toList()),
          ],
      ];
    }
    if (_grouping == 'Penyedia') {
      return [
        for (final provider in _store.providers)
          if (offers.any((o) => o.providerId == provider.id)) ...[
            _groupHeader(provider.name,
                '${provider.role} • ${provider.location}'),
            _cardList(offers.where((o) => o.providerId == provider.id).toList()),
          ],
      ];
    }
    return [_cardList(offers)];
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: kTextGrey),
          const SizedBox(height: 12),
          const Text('Layanan tidak ditemukan',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Coba kata kunci lain atau kurangi filter.',
              textAlign: TextAlign.center, style: TextStyle(color: kTextGrey)),
          TextButton(onPressed: _resetAll, child: const Text('Reset pencarian')),
        ],
      ),
    );
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QuotationListPage())),
            icon: const Icon(Icons.request_quote_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final offers = _filteredOffers();
          final filterCount = _activeFilterCount;
          final searching = _searchController.text.trim().isNotEmpty;
          return ResponsiveBody(
            maxWidth: 1000,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari layanan, keahlian, atau nama penyedia...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                _chipRow(_store.categories, _category, (value) {
                  setState(() {
                    _category = value;
                    _subCategory = 'Semua';
                  });
                }),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (_category != 'Semua')
                        _chipRow(
                          ['Semua', ..._store.subCategoriesOf(_category)],
                          _subCategory,
                          (value) => setState(() => _subCategory = value),
                          height: 44,
                        ),
                      if (!searching)
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            scrollDirection: Axis.horizontal,
                            itemCount: _store.searchSuggestions.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                return const Center(
                                  child: Text('Coba cari:',
                                      style: TextStyle(fontSize: 12, color: kTextGrey)),
                                );
                              }
                              final word = _store.searchSuggestions[i - 1];
                              return ActionChip(
                                label: Text(word, style: const TextStyle(fontSize: 12)),
                                onPressed: () {
                                  _searchController.text = word;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          segments: const [
                            ButtonSegment(value: 'Daftar', label: Text('Semua')),
                            ButtonSegment(value: 'Kategori', label: Text('Per kategori')),
                            ButtonSegment(value: 'Penyedia', label: Text('Per penyedia')),
                          ],
                          selected: {_grouping},
                          onSelectionChanged: (value) =>
                              setState(() => _grouping = value.first),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 8, 4),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              '${offers.length} layanan • $_sort',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: kTextGrey, fontSize: 12),
                            ),
                          ),
                          FilterChip(
                            avatar: Icon(
                                _favoritesOnly ? Icons.favorite : Icons.favorite_border,
                                size: 17),
                            label: const Text('Favorit'),
                            selected: _favoritesOnly,
                            onSelected: (value) => setState(() => _favoritesOnly = value),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Urutkan',
                            icon: const Icon(Icons.swap_vert),
                            onSelected: (value) => setState(() => _sort = value),
                            itemBuilder: (_) => [
                              for (final option in _sortOptions)
                                CheckedPopupMenuItem<String>(
                                  value: option,
                                  checked: _sort == option,
                                  child: Text(option),
                                ),
                            ],
                          ),
                          IconButton(
                            tooltip: 'Filter',
                            onPressed: _showFilters,
                            icon: Badge(
                              isLabelVisible: filterCount > 0,
                              label: Text('$filterCount'),
                              child: const Icon(Icons.tune),
                            ),
                          ),
                        ]),
                      ),
                      if (offers.isEmpty) _emptyState() else ..._resultWidgets(offers),
                    ],
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

Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );

Widget _infoChips(List<String> items) => Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [for (final item in items) Chip(label: Text(item))],
    );

Widget _statBox(IconData icon, String value, String label) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: kPrimary),
        const SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: kTextGrey)),
      ]),
    ),
  );
}

Widget _providerStats(ServiceProvider provider) {
  return Row(children: [
    _statBox(Icons.star, '${provider.rating} (${provider.reviewCount})', 'Rating'),
    const SizedBox(width: 8),
    _statBox(Icons.work_outline, '${provider.experienceYears} tahun', 'Pengalaman'),
    const SizedBox(width: 8),
    _statBox(Icons.task_alt, '${provider.completedProjects}', 'Proyek selesai'),
    const SizedBox(width: 8),
    _statBox(Icons.bolt, provider.responseTime, 'Respon'),
  ]);
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

          return ResponsiveBody(
            maxWidth: 900,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AdaptiveSplit(
                        gap: 24,
                        primaryFlex: 3,
                        secondaryFlex: 2,
                        primary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(offer.title,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(formatRupiah(offer.price),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: kPrimary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(label: Text(offer.category)),
                                Chip(label: Text(offer.subCategory)),
                                Chip(
                                  avatar: const Icon(Icons.schedule, size: 16),
                                  label: Text(offer.duration),
                                ),
                                Chip(
                                  avatar: const Icon(Icons.edit_note, size: 16),
                                  label: Text('${offer.revisions}x revisi'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(offer.description,
                                style: const TextStyle(fontSize: 14, height: 1.5)),
                            _sectionTitle('Yang kamu dapatkan'),
                            for (final item in offer.includes)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 18, color: kPrimary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item)),
                                  ],
                                ),
                              ),
                            _sectionTitle('Alat dan teknologi'),
                            _infoChips(offer.tools),
                            _sectionTitle('Kata kunci'),
                            _infoChips(offer.tags),
                          ],
                        ),
                        secondary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Penyedia',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kTextGrey)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: cardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
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
                                          Row(children: [
                                            Flexible(
                                              child: Text(provider.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w600)),
                                            ),
                                            if (provider.verified)
                                              const Padding(
                                                padding: EdgeInsets.only(left: 4),
                                                child: Icon(Icons.verified,
                                                    size: 16, color: kPrimary),
                                              ),
                                          ]),
                                          Text('${provider.role} • ${provider.location}',
                                              style: const TextStyle(
                                                  fontSize: 12, color: kTextGrey)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text(provider.bio, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 10),
                                  _providerStats(provider),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      for (final skill in provider.skills)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: kPrimary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(skill,
                                              style: const TextStyle(fontSize: 11)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProviderProfilePage(providerId: provider.id),
                                        ),
                                      ),
                                      icon: const Icon(Icons.person_search_outlined),
                                      label: const Text('Lihat portofolio & ulasan'),
                                      style: TextButton.styleFrom(foregroundColor: kPrimary),
                                    ),
                                  ),
                                ],
                              ),
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
                              MaterialPageRoute(
                                  builder: (_) => RequestQuotationPage(offer: offer)),
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
            ),
          );
        },
      ),
    );
  }
}

/// Profil lengkap penyedia: pengalaman, keahlian, portofolio, ulasan,
/// dan semua layanan yang ditawarkan.
class ProviderProfilePage extends StatelessWidget {
  final String providerId;
  const ProviderProfilePage({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    final provider = store.providerById(providerId);
    final offers = store.offersOfProvider(providerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Penyedia')),
      body: ResponsiveBody(
        maxWidth: 800,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: provider.color.withOpacity(0.15),
                      child: Icon(provider.icon, color: provider.color, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(provider.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            if (provider.verified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified, size: 18, color: kPrimary),
                              ),
                          ]),
                          Text(provider.role,
                              style: const TextStyle(fontSize: 13, color: kTextGrey)),
                          Row(children: [
                            const Icon(Icons.place_outlined, size: 14, color: kTextGrey),
                            const SizedBox(width: 2),
                            Text(provider.location,
                                style: const TextStyle(fontSize: 13, color: kTextGrey)),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _providerStats(provider),
                  const SizedBox(height: 12),
                  Text(provider.bio, style: const TextStyle(fontSize: 14, height: 1.5)),
                  _sectionTitle('Keahlian'),
                  _infoChips(provider.skills),
                  _sectionTitle('Portofolio'),
                  for (final item in provider.portfolio)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(item.description,
                              style: const TextStyle(fontSize: 12, color: kTextGrey)),
                        ],
                      ),
                    ),
                  _sectionTitle('Ulasan klien (${provider.reviewCount})'),
                  for (final review in provider.reviews)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(review.reviewer,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                            for (int i = 0; i < review.rating; i++)
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                          ]),
                          const SizedBox(height: 4),
                          Text(review.comment, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  _sectionTitle('Layanan dari ${provider.name} (${offers.length})'),
                  for (final offer in offers)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: cardDecoration(),
                      child: ListTile(
                        title: Text(offer.title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text('${offer.subCategory} • ${offer.duration}'),
                        trailing: Text(formatRupiah(offer.price),
                            style: const TextStyle(
                                color: kPrimary, fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => ServiceDetailPage(offer: offer)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ChatRoomPage(providerId: provider.id)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat penyedia'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: kPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
