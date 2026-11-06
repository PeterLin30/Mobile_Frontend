import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'chat_page.dart';
import 'profile_page.dart';
import 'voucher_page.dart';
import 'news_page.dart';
import 'promo_detail_page.dart';
import 'marketplace_data.dart';
import 'service_pages.dart';
import 'chat_room_page.dart';
import 'activity_page.dart';
import 'ui_helpers.dart';
import 'quick_action_sheet.dart';

const Color primaryColor = Color(0xFF5CC8CC);
const Color lightCyan = Color(0xFFC8F1F3);
const Color textColor = Color(0xFF202124);

class ServiceItem {
  final String title;
  final IconData icon;

  const ServiceItem(this.title, this.icon);
}

class PromoItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const PromoItem(this.title, this.subtitle, this.icon);
}

class NewsItem {
  final String title;
  final String date;
  final IconData icon;

  const NewsItem(this.title, this.date, this.icon);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<ServiceItem> _services = const [
    ServiceItem('Mobile', LucideIcons.smartphone),
    ServiceItem('Web', LucideIcons.globe),
    ServiceItem('Cyber', LucideIcons.shieldCheck),
    ServiceItem('Graphic', LucideIcons.palette),
    ServiceItem('Digital', LucideIcons.megaphone),
    ServiceItem('Bisnis', LucideIcons.store),
    ServiceItem('See All', LucideIcons.grid2x2),
  ];

  final List<PromoItem> _promos = const [
    PromoItem(
      'Promo UMKM',
      'Penawaran menarik untuk usahamu',
      Icons.storefront_rounded,
    ),
    PromoItem(
      'Paket Hemat',
      'Solusi digital lebih terjangkau',
      Icons.local_offer_rounded,
    ),
    PromoItem(
      'Promo Desain',
      'Tingkatkan identitas bisnismu',
      Icons.design_services_rounded,
    ),
  ];

  final List<NewsItem> _news = const [
    NewsItem(
      'Tips Mengembangkan Bisnis UMKM di Era Digital',
      '28 Oktober 2026',
      Icons.trending_up_rounded,
    ),
    NewsItem(
      'Pentingnya Website untuk Bisnis Lokal',
      '25 Oktober 2026',
      Icons.language_rounded,
    ),
    NewsItem(
      'Strategi Branding agar UMKM Lebih Dikenal',
      '22 Oktober 2026',
      Icons.lightbulb_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sidebar digunakan saat landscape, navbar bawah saat portrait.
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        bottom: isLandscape,
        child: isLandscape
            ? Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        _buildHomeContent(),
                        const ChatPage(),
                        const ActivityPage(),
                        const ProfilePage(),
                      ],
                    ),
                  ),
                ],
              )
            : IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeContent(),
                  const ChatPage(),
                  const ActivityPage(),
                  const ProfilePage(),
                ],
              ),
      ),
      bottomNavigationBar:
          isLandscape ? null : _buildBottomNavigation(),
    );
  }

  // SIDEBAR NAVIGATION (LANDSCAPE)
  // LayoutBuilder + Expanded menjaga sidebar tetap muat pada layar pendek.
  Widget _buildSidebar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxHeight < 500;

        return Container(
          width: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: compact ? 12 : 24,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: primaryColor,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'MikroHub',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Expanded memberi ruang fleksibel untuk daftar navigasi.
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: compact ? 8 : 20,
                    bottom: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSidebarNavItem(
                        0, Icons.home_rounded, 'Home',
                      ),
                      _buildSidebarNavItem(
                        1, Icons.chat_rounded, 'Pesan',
                      ),
                      _buildSidebarNavItem(
                        2, Icons.receipt_long_rounded, 'Aktivitas',
                      ),
                      _buildSidebarNavItem(
                        3, Icons.person_rounded, 'Profil',
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions tetap berada di bawah dan lebih ringkas
              // pada perangkat landscape dengan tinggi layar terbatas.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  compact ? 4 : 8,
                  12,
                  compact ? 8 : 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showQuickActions,
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    label: const Text(
                      'Quick Actions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CE3E7),
                      foregroundColor: textColor,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 9 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarNavItem(
    int index,
    IconData icon,
    String label,
  ) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected ? lightCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? primaryColor
                    : const Color(0xFF9EA1A3),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? const Color(0xFF397E82)
                      : const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Welcome,',
                style: TextStyle(fontSize: 19, color: textColor),
              ),
              const Text(
                'Pengguna MikroHub',
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Services
              _buildServices(),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(child: _buildSectionTitle('Layanan Populer')),
                  OutlinedButton(
                    onPressed: _openServiceList,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: lightCyan),
                      minimumSize: const Size(0, 34),
                    ),
                    child: const Text('SEE ALL', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _buildPopularOffers(),

              const SizedBox(height: 22),

              _buildSectionTitle('Penyedia Layanan'),

              const SizedBox(height: 10),

              _buildProviders(),

              const SizedBox(height: 22),

              _buildSectionTitle('Promo'),

              const SizedBox(height: 10),

              _buildPromos(),

              const SizedBox(height: 16),

              _buildVoucherButton(),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'News',
                      style: TextStyle(
                        fontSize: 21,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: lightCyan),
                      minimumSize: const Size(0, 34),
                    ),
                    child: const Text(
                      'SEE ALL',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ]),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildNewsCard(_news[index]),
              );
            }, childCount: _news.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  void _openServiceList({String category = 'Semua'}) {
    final valid = MarketplaceStore.instance.categories.contains(category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ServiceListPage(initialCategory: valid ? category : 'Semua'),
      ),
    );
  }

  void _showQuickActions() {
    QuickActionSheet.show(
      context,
      onFindDeveloper: () => _openServiceList(),
      onBusinessHelp: () => _openServiceList(category: 'Bisnis'),
      onConsult: () => setState(() => _selectedIndex = 1),
      onVoucher: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VoucherPage(),
        ),
      ),
    );
  }

  // LAYANAN POPULER: data dari MarketplaceStore (dummy).
  Widget _buildPopularOffers() {
    final store = MarketplaceStore.instance;
    final offers = store.offers;

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final offer = offers[i];
          final provider = store.providerById(offer.providerId);

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServiceDetailPage(offer: offer)),
            ),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: provider.color.withOpacity(0.15),
                        child: Icon(provider.icon, color: provider.color, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: kTextGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatRupiah(offer.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // PENYEDIA LAYANAN: ketuk untuk langsung chat.
  Widget _buildProviders() {
    final providers = MarketplaceStore.instance.providers;

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: providers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = providers[i];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatRoomPage(providerId: p.id)),
            ),
            child: SizedBox(
              width: 92,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: p.color.withOpacity(0.15),
                    child: Icon(p.icon, color: p.color, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: textColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      Text(
                        p.rating.toString(),
                        style: const TextStyle(fontSize: 11, color: kTextGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // SERVICES: komponen bawaan Flutter.

  Widget _buildServices() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: lightCyan,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: _services.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final service = _services[index];
          final bool isSeeAll = service.title == 'See All';

          return SizedBox(
            width: 60,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (isSeeAll) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllServicesPage(
                        services: _services
                            .where((item) => item.title != 'See All')
                            .toList(),
                      ),
                    ),
                  );
                } else {
                  _openServiceList(category: service.title);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF616D70),
                    child: Icon(service.icon, size: 25),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // PROMO: slider manual (swipe, tombol panah, dan indikator).
  Widget _buildPromos() {
    return PromoCarousel(
      promos: _promos,
      onPromoTap: (promo) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromoDetailPage(
              title: promo.title,
              subtitle: promo.subtitle,
              icon: promo.icon,
            ),
          ),
        );
      },
    );
  }

  // VOUCHER
  Widget _buildVoucherButton() {
    return Material(
      color: const Color(0xFF9CE3E7),
      borderRadius: BorderRadius.circular(5),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VoucherPage()),
          );
        },
        child: const SizedBox(
          height: 42,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 23),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Voucher Coupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.arrow_circle_right_outlined, size: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEWS

  Widget _buildNewsCard(NewsItem news) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeNewsDetailPage(news: news),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: lightCyan,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  news.icon,
                  color: const Color(0xFF397E82),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.date,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: primaryColor.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.chat_rounded, 'Pesan'),
                  const SizedBox(width: 60),
                  _buildNavItem(2, Icons.receipt_long_rounded, 'Aktivitas'),
                  _buildNavItem(3, Icons.person_rounded, 'Profil'),
                ],
              ),
              Positioned(
                top: -22,
                child: Material(
                  color: const Color(0xFF9CE3E7),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      _showQuickActions();
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool selected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected ? primaryColor : const Color(0xFFD2D4D5),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: selected ? primaryColor : const Color(0xFF9EA1A3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SLIDER PROMO (manual: swipe, tombol panah, dan indikator)
class PromoCarousel extends StatefulWidget {
  final List<PromoItem> promos;
  final Function(PromoItem) onPromoTap;

  const PromoCarousel({
    super.key,
    required this.promos,
    required this.onPromoTap,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool? _isLandscape;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Saat landscape, kartu lebih ringkas dan kartu berikutnya tetap terlihat.
    if (_isLandscape != isLandscape) {
      _isLandscape = isLandscape;
      _pageController.dispose();
      _pageController = PageController(
        initialPage: _currentIndex,
        viewportFraction: isLandscape ? 0.58 : 1.0,
      );
    }
  }

  @override
  void didUpdateWidget(covariant PromoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.promos.length != widget.promos.length) {
      _currentIndex = 0;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (!_pageController.hasClients) return;
    if (index < 0 || index >= widget.promos.length) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.35,
      child: Material(
        color: lightCyan,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF245F63),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promos.isEmpty) {
      return const SizedBox.shrink();
    }

    final isLandscape = _isLandscape ?? false;
    final bool hasPrev = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.promos.length - 1;

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            // Batasi lebar slider pada layar landscape yang lebar.
            constraints: BoxConstraints(
              maxWidth: isLandscape ? 760 : double.infinity,
            ),
            child: SizedBox(
              height: isLandscape ? 112 : 145,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.promos.length,
                physics: const BouncingScrollPhysics(),
                padEnds: true,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final promo = widget.promos[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 7 : 3,
                      vertical: isLandscape ? 2 : 0,
                    ),
                    child: Material(
                      color: lightCyan,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => widget.onPromoTap(promo),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isLandscape ? 13 : 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC8F1F3),
                                Color(0xFF8EDDE1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      promo.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isLandscape ? 15 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF245F63),
                                      ),
                                    ),
                                    SizedBox(height: isLandscape ? 5 : 8),
                                    Text(
                                      promo.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isLandscape ? 10 : 12,
                                        color: const Color(0xFF397E82),
                                      ),
                                    ),
                                    SizedBox(height: isLandscape ? 5 : 8),
                                    Text(
                                      'Lihat Selengkapnya →',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isLandscape ? 9 : 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF245F63),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isLandscape ? 6 : 12),
                              Icon(
                                promo.icon,
                                size: isLandscape ? 34 : 55,
                                color: const Color(0xFF397E82),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: isLandscape ? 7 : 10),

        // Kontrol di bawah kartu: panah kiri, indikator titik, panah kanan.
        // Tidak lagi menumpuk di atas kartu, jadi tidak menutupi teks.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: hasPrev,
              onTap: () => _goToPage(_currentIndex - 1),
            ),
            const SizedBox(width: 12),
            ...List.generate(
              widget.promos.length,
              (index) {
                final isActive = _currentIndex == index;

                return GestureDetector(
                  onTap: () => _goToPage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: hasNext,
              onTap: () => _goToPage(_currentIndex + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeNewsDetailPage extends StatelessWidget {
  final NewsItem news;

  const HomeNewsDetailPage({super.key, required this.news});

  String get articleContent {
    switch (news.title) {
      case 'Tips Mengembangkan Bisnis UMKM di Era Digital':
        return 'Perkembangan teknologi digital memberikan '
            'kesempatan bagi pelaku UMKM untuk menjangkau lebih '
            'banyak pelanggan. Pemanfaatan media sosial, pemasaran '
            'digital, dan layanan online dapat membantu bisnis '
            'meningkatkan visibilitasnya.\n\n'
            'Pelaku usaha dapat memulai dengan menentukan target '
            'pasar, membuat konten yang relevan, menjaga kualitas '
            'produk, serta memberikan pelayanan yang baik kepada '
            'pelanggan. Evaluasi secara berkala juga penting untuk '
            'mengetahui strategi yang paling efektif.';

      case 'Pentingnya Website untuk Bisnis Lokal':
        return 'Website dapat menjadi pusat informasi resmi bagi '
            'bisnis lokal. Melalui website, pelanggan dapat '
            'mengenal produk, melihat informasi layanan, serta '
            'menemukan cara menghubungi pemilik usaha.\n\n'
            'Website yang informatif dan mudah digunakan dapat '
            'membantu meningkatkan kepercayaan pelanggan. Pastikan '
            'informasi produk, kontak, harga, dan jam operasional '
            'diperbarui secara berkala.';

      case 'Strategi Branding agar UMKM Lebih Dikenal':
        return 'Branding membantu bisnis memiliki identitas yang '
            'mudah dikenali oleh pelanggan. Identitas tersebut '
            'dapat dibangun melalui nama merek, logo, warna, gaya '
            'komunikasi, dan kualitas pelayanan yang konsisten.\n\n'
            'UMKM sebaiknya memahami karakteristik target pasar '
            'sebelum menentukan strategi branding. Gunakan identitas '
            'yang konsisten pada kemasan, media sosial, dan materi '
            'promosi agar pelanggan lebih mudah mengingat bisnis.';

      default:
        return 'Baca informasi dan tips berikut untuk membantu '
            'mengembangkan bisnis serta memahami peluang di era '
            'digital.\n\n'
            'Sesuaikan strategi dengan kebutuhan usaha, pahami '
            'pelanggan, dan lakukan evaluasi secara berkala agar '
            'pengembangan bisnis dapat berjalan lebih terarah.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: lightCyan,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(news.icon, size: 80, color: const Color(0xFF397E82)),
            ),
            const SizedBox(height: 20),
            Text(
              news.date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              news.title,
              style: const TextStyle(
                color: textColor,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              articleContent,
              style: const TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.8,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllServicesPage extends StatelessWidget {
  final List<ServiceItem> services;

  const AllServicesPage({super.key, required this.services});

  static const double _spacing = 12;
  static const double _minTile = 110;
  static const double _maxTile = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Semua Layanan'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double available = constraints.maxWidth - 40; // padding 20

            // Maksimal kolom = setengah jumlah item (dibulatkan ke atas),
            // sehingga selalu ada minimal 2 baris. Jumlah kolom juga
            // dibatasi agar tiap tombol tidak lebih kecil dari _minTile.
            final int rowsMin2Cols = (services.length / 2).ceil();
            final int fitCols =
                ((available + _spacing) / (_minTile + _spacing)).floor();
            final int columns = fitCols.clamp(1, rowsMin2Cols);

            // Lebar grid dibatasi agar tombol tidak melebar di layar besar.
            final double maxGridWidth =
                columns * _maxTile + (columns - 1) * _spacing;
            final double gridWidth =
                available < maxGridWidth ? available : maxGridWidth;

            return Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                width: gridWidth,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: _spacing,
                    mainAxisSpacing: _spacing,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) =>
                      _buildServiceTile(context, services[index]),
                ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, ServiceItem service) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final valid =
              MarketplaceStore.instance.categories.contains(service.title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceListPage(
                initialCategory: valid ? service.title : 'Semua',
              ),
            ),
          );
        },
        // Ukuran ikon dan font mengikuti ukuran tile.
        child: LayoutBuilder(
          builder: (context, box) {
            final double side = box.biggest.shortestSide;
            final double radius = side * 0.26;
            final double iconSize = radius * 1.0;
            final double fontSize = (side * 0.105).clamp(11.0, 16.0);

            return Padding(
              padding: EdgeInsets.all(side * 0.07),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: CircleAvatar(
                        radius: radius,
                        backgroundColor: lightCyan,
                        child: Icon(
                          service.icon,
                          color: const Color(0xFF397E82),
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          service.title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}