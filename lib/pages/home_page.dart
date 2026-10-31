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
import 'responsive.dart';

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

  // GlobalKey supaya state tiap tab tidak hilang saat layar diputar
  // (bottom bar <-> side bar).
  final GlobalKey _pagesKey = GlobalKey();

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
    // Layar lebar (HP landscape / tablet): navigasi pindah ke samping.
    final wide = context.isWide;

    // IndexedStack keeps each page's state while switching tabs.
    final pages = IndexedStack(
      key: _pagesKey,
      index: _selectedIndex,
      children: [
        _buildHomeContent(),
        const ChatPage(),
        const ActivityPage(),
        const ProfilePage(),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: wide
            ? Row(
                children: [
                  _buildSideNavigation(),
                  Expanded(child: pages),
                ],
              )
            : pages,
      ),
      bottomNavigationBar: wide ? null : _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent() {
    return ResponsiveBody(
      maxWidth: 960,
      child: CustomScrollView(
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
          sliver: SliverToBoxAdapter(
            child: ResponsiveCardList(
              padding: EdgeInsets.zero,
              spacing: 10,
              minTileWidth: 320,
              maxColumns: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _news.length,
              itemBuilder: (context, index) => _buildNewsCard(_news[index]),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
      ),
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
  // Lebar item tetap 60; di layar lebar jarak antar item melebar otomatis
  // sehingga baris ikon mengisi lebar yang tersedia.
  Widget _buildServices() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: lightCyan,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          const itemWidth = 60.0;
          final count = _services.length;
          final free = box.maxWidth - 24 - count * itemWidth;
          final spread = count > 1 ? free / (count - 1) : 16.0;
          final gap = spread < 16 ? 16.0 : spread;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: count,
            separatorBuilder: (context, index) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final service = _services[index];
              final bool isSeeAll = service.title == 'See All';

              return SizedBox(
                width: itemWidth,
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
          );
        },
      ),
    );
  }

  // PROMO: HP portrait = kartu horizontal yang bisa digeser,
  // layar lebar = kartu dibagi rata (Expanded) memenuhi lebar.

  Widget _buildPromoCard(PromoItem promo) {
    return Material(
      color: lightCyan,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(promo.icon, size: 27, color: const Color(0xFF397E82)),
              const Spacer(),
              Text(
                promo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                promo.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromos() {
    return SizedBox(
      height: 120,
      child: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= 520) {
            return Row(
              children: [
                for (int i = 0; i < _promos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _buildPromoCard(_promos[i])),
                ],
              ],
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: _promos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                SizedBox(width: 150, child: _buildPromoCard(_promos[index])),
          );
        },
      ),
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

  // SIDE NAVIGATION: dipakai di layar lebar (HP landscape / tablet).
  Widget _buildSideNavigation() {
    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: primaryColor.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        right: false,
        // ListView supaya tetap bisa di-scroll di landscape yang pendek.
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _buildRailItem(0, Icons.home_rounded, 'Home'),
            _buildRailItem(1, Icons.chat_rounded, 'Pesan'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Material(
                  color: const Color(0xFF9CE3E7),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _showQuickActions,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildRailItem(2, Icons.receipt_long_rounded, 'Aktivitas'),
            _buildRailItem(3, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildRailItem(int index, IconData icon, String label) {
    final bool selected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
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
                fontSize: 10,
                color: selected ? primaryColor : const Color(0xFF9EA1A3),
              ),
            ),
          ],
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
      body: ResponsiveBody(
        maxWidth: 960,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        // HP portrait: gambar di atas. Landscape/tablet: gambar di kiri.
        child: AdaptiveSplit(
          gap: 20,
          primaryFlex: 2,
          secondaryFlex: 3,
          primary: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: lightCyan,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(news.icon, size: 80, color: const Color(0xFF397E82)),
            ),
          secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
      ),
    );
  }
}

class AllServicesPage extends StatelessWidget {
  final List<ServiceItem> services;

  const AllServicesPage({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Semua Layanan'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveBody(
        maxWidth: 960,
        child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        // jumlah kolom otomatis: 3 di HP portrait, lebih banyak di layar lebar
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final service = services[index];

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final valid = MarketplaceStore.instance.categories
                    .contains(service.title);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceListPage(
                      initialCategory: valid ? service.title : 'Semua',
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: lightCyan,
                    child: Icon(
                      service.icon,
                      color: const Color(0xFF397E82),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
