import 'dart:async';

import 'package:flutter/material.dart';

// ===================== MODEL =====================

class ServiceProvider {
  final String id;
  final String name;
  final String role; // salah satu dari kUserRoles
  final String bio;
  final double rating;
  final IconData icon;
  final Color color;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.rating,
    required this.icon,
    required this.color,
  });
}

class ServiceOffer {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String category;
  final String duration;
  final int price; // rupiah

  const ServiceOffer({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.price,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

enum OrderStatus { diproses, selesai }

enum QuotationStatus { ditawarkan, diterima, ditolak }

enum ProjectStatus { dikerjakan, review, revisi, selesai }

class ServiceQuotation {
  final String id;
  final ServiceOffer offer;
  final String businessNeed;
  final int proposedPrice;
  final int requestedBudget;
  final String proposedDuration;
  final int revisions;
  final DateTime createdAt;
  QuotationStatus status;

  ServiceQuotation({
    required this.id,
    required this.offer,
    required this.businessNeed,
    required this.proposedPrice,
    required this.requestedBudget,
    required this.proposedDuration,
    required this.revisions,
    required this.createdAt,
    this.status = QuotationStatus.ditawarkan,
  });
}

class ProjectMilestone {
  final String title;
  final String description;
  bool isComplete;
  DateTime? completedAt;

  ProjectMilestone({
    required this.title,
    required this.description,
    this.isComplete = false,
    this.completedAt,
  });
}

class TrackedProject {
  final String id;
  final ServiceQuotation quotation;
  final DateTime startedAt;
  final List<ProjectMilestone> milestones;
  ProjectStatus status;

  TrackedProject({
    required this.id,
    required this.quotation,
    required this.startedAt,
    required this.milestones,
    this.status = ProjectStatus.dikerjakan,
  });
}

class Order {
  final String id;
  final ServiceOffer offer;
  final DateTime date;
  OrderStatus status;

  Order({
    required this.id,
    required this.offer,
    required this.date,
    this.status = OrderStatus.diproses,
  });
}

/// Ringkasan penyedia yang pernah dipakai (dihitung dari riwayat pesanan).
class ProviderUsage {
  final ServiceProvider provider;
  final int orderCount;
  final int totalSpent;
  final DateTime lastUsed;

  const ProviderUsage({
    required this.provider,
    required this.orderCount,
    required this.totalSpent,
    required this.lastUsed,
  });
}

// ===================== HELPER FORMAT =====================

String formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp$buf';
}

String formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String formatDate(DateTime t) {
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${t.day} ${bulan[t.month - 1]} ${t.year}';
}

/// Waktu singkat untuk daftar chat: jam kalau hari ini, tanggal kalau bukan.
String formatChatTime(DateTime t) {
  final now = DateTime.now();
  final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
  return sameDay ? formatTime(t) : formatDate(t);
}

// ===================== STORE (DATA DUMMY, DI MEMORI) =====================

/// Pengganti backend sementara. Semua data hilang saat aplikasi ditutup.
/// Nanti ganti isi method-nya dengan panggilan API/Firebase.
class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore._() {
    _seed();
  }
  static final MarketplaceStore instance = MarketplaceStore._();

  final List<String> categories = const [
    'Semua', 'Mobile', 'Web', 'Graphic', 'Digital', 'Bisnis',
  ];

  final List<ServiceProvider> providers = const [
    ServiceProvider(
      id: 'p1',
      name: 'Rizky Dev Studio',
      role: 'Developer App',
      bio: 'Spesialis aplikasi Flutter untuk toko dan kasir UMKM.',
      rating: 4.8,
      icon: Icons.phone_android,
      color: Color(0xFF42A5F5),
    ),
    ServiceProvider(
      id: 'p2',
      name: 'Nadia Web Craft',
      role: 'Developer App',
      bio: 'Membuat website company profile dan toko online.',
      rating: 4.7,
      icon: Icons.language,
      color: Color(0xFF66BB6A),
    ),
    ServiceProvider(
      id: 'p3',
      name: 'Bina Usaha Konsultan',
      role: 'Pengolah Bantuan Bisnis',
      bio: 'Pendampingan izin usaha, NIB, dan pengajuan modal.',
      rating: 4.9,
      icon: Icons.account_balance,
      color: Color(0xFF9575CD),
    ),
    ServiceProvider(
      id: 'p4',
      name: 'Kreasi Pixel',
      role: 'Penyedia Solusi Digital',
      bio: 'Desain logo, kemasan, dan konten media sosial.',
      rating: 4.6,
      icon: Icons.palette,
      color: Color(0xFFFF8A65),
    ),
    ServiceProvider(
      id: 'p5',
      name: 'Sinyal Digital Marketing',
      role: 'Penyedia Solusi Digital',
      bio: 'Iklan, SEO lokal, dan pengelolaan Instagram UMKM.',
      rating: 4.5,
      icon: Icons.campaign,
      color: Color(0xFF5CC8CC),
    ),
  ];

  final List<ServiceOffer> offers = const [
    ServiceOffer(
      id: 's1',
      providerId: 'p1',
      title: 'Aplikasi Kasir (POS) Sederhana',
      description: 'Aplikasi kasir Android: katalog produk, transaksi, '
          'dan laporan penjualan harian.',
      category: 'Mobile',
      duration: '14 hari',
      price: 2500000,
    ),
    ServiceOffer(
      id: 's2',
      providerId: 'p1',
      title: 'Aplikasi Katalog & Pemesanan',
      description: 'Aplikasi katalog produk dengan pemesanan lewat WhatsApp.',
      category: 'Mobile',
      duration: '10 hari',
      price: 1800000,
    ),
    ServiceOffer(
      id: 's3',
      providerId: 'p2',
      title: 'Website Company Profile',
      description: 'Website 5 halaman responsif, domain & hosting 1 tahun.',
      category: 'Web',
      duration: '7 hari',
      price: 1500000,
    ),
    ServiceOffer(
      id: 's4',
      providerId: 'p3',
      title: 'Pengurusan NIB & Izin Usaha',
      description: 'Pendampingan pembuatan NIB, PIRT, dan sertifikat halal.',
      category: 'Bisnis',
      duration: '5 hari',
      price: 750000,
    ),
    ServiceOffer(
      id: 's5',
      providerId: 'p3',
      title: 'Pendampingan Pengajuan KUR',
      description: 'Bantu susun proposal dan dokumen pengajuan modal usaha.',
      category: 'Bisnis',
      duration: '14 hari',
      price: 1200000,
    ),
    ServiceOffer(
      id: 's6',
      providerId: 'p4',
      title: 'Desain Logo & Branding',
      description: 'Logo, palet warna, dan panduan penggunaan merek.',
      category: 'Graphic',
      duration: '5 hari',
      price: 600000,
    ),
    ServiceOffer(
      id: 's7',
      providerId: 'p5',
      title: 'Kelola Instagram 1 Bulan',
      description: '12 konten feed, 8 story, dan laporan performa bulanan.',
      category: 'Digital',
      duration: '30 hari',
      price: 1000000,
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {};
  final List<Order> _orders = [];
  final List<ServiceQuotation> _quotations = [];
  final List<TrackedProject> _projects = [];
  final Set<String> _favoriteOfferIds = {};
  int _quotationSequence = 0;
  int _projectSequence = 0;

  static const List<String> _autoReplies = [
    'Baik, terima kasih sudah menghubungi kami. Boleh ceritakan kebutuhan usahanya?',
    'Siap, untuk layanan ini bisa kami sesuaikan dengan budget kamu.',
    'Kalau cocok, silakan lanjut pesan lewat tombol Beli Layanan ya.',
    'Terima kasih! Kami akan mulai pengerjaan setelah pesanan dibuat.',
  ];

  // ---------- Lookup ----------

  ServiceProvider providerById(String id) =>
      providers.firstWhere((p) => p.id == id);

  ServiceOffer offerById(String id) => offers.firstWhere((o) => o.id == id);

  List<ServiceOffer> offersByCategory(String category) => category == 'Semua'
      ? offers
      : offers.where((o) => o.category == category).toList();

  bool isFavorite(String offerId) => _favoriteOfferIds.contains(offerId);

  void toggleFavorite(String offerId) {
    if (!_favoriteOfferIds.add(offerId)) _favoriteOfferIds.remove(offerId);
    notifyListeners();
  }

  List<ServiceQuotation> get quotations => List.unmodifiable(
      _quotations.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  List<TrackedProject> get projects => List.unmodifiable(
      _projects.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt)));

  ServiceQuotation createQuotation({
    required ServiceOffer offer,
    required String businessNeed,
    required int budget,
  }) {
    _quotationSequence++;
    // Proposal mock: nilai penawaran mengikuti harga katalog, dengan estimasi
    // waktu dan revisi yang dapat dilihat pengguna sebelum menyetujui.
    final quotation = ServiceQuotation(
      id: 'QTN-${_quotationSequence.toString().padLeft(4, '0')}',
      offer: offer,
      businessNeed: businessNeed.trim(),
      proposedPrice: offer.price,
      requestedBudget: budget,
      proposedDuration: offer.duration,
      revisions: 2,
      createdAt: DateTime.now(),
    );
    _quotations.add(quotation);
    notifyListeners();
    return quotation;
  }

  TrackedProject? acceptQuotation(ServiceQuotation quotation) {
    if (quotation.status != QuotationStatus.ditawarkan) return null;
    quotation.status = QuotationStatus.diterima;
    _projectSequence++;
    final project = TrackedProject(
      id: 'PRJ-${_projectSequence.toString().padLeft(4, '0')}',
      quotation: quotation,
      startedAt: DateTime.now(),
      milestones: [
        ProjectMilestone(title: 'Brief dikonfirmasi', description: 'Kebutuhan dan ruang lingkup pekerjaan disepakati.', isComplete: true, completedAt: DateTime.now()),
        ProjectMilestone(title: 'Pengerjaan', description: 'Penyedia mulai mengerjakan layanan.'),
        ProjectMilestone(title: 'Review hasil', description: 'Periksa hasil dan ajukan revisi bila diperlukan.'),
        ProjectMilestone(title: 'Proyek selesai', description: 'Hasil akhir disetujui dan proyek ditutup.'),
      ],
    );
    _projects.add(project);
    notifyListeners();
    return project;
  }

  void rejectQuotation(ServiceQuotation quotation) {
    if (quotation.status != QuotationStatus.ditawarkan) return;
    quotation.status = QuotationStatus.ditolak;
    notifyListeners();
  }

  void advanceProject(TrackedProject project) {
    if (project.status == ProjectStatus.selesai) return;
    if (project.status == ProjectStatus.revisi) {
      project.status = ProjectStatus.dikerjakan;
    } else if (project.status == ProjectStatus.dikerjakan) {
      project.status = ProjectStatus.review;
      if (project.milestones.length > 1) {
        project.milestones[1].isComplete = true;
        project.milestones[1].completedAt = DateTime.now();
        project.milestones[2].isComplete = true;
        project.milestones[2].completedAt = DateTime.now();
      }
    } else if (project.status == ProjectStatus.review) {
      project.status = ProjectStatus.selesai;
      for (final milestone in project.milestones) {
        milestone.isComplete = true;
        milestone.completedAt ??= DateTime.now();
      }
    }
    notifyListeners();
  }

  void requestRevision(TrackedProject project) {
    if (project.status != ProjectStatus.review) return;
    project.status = ProjectStatus.revisi;
    if (project.milestones.length > 2) {
      project.milestones[2].isComplete = false;
      project.milestones[2].completedAt = null;
    }
    notifyListeners();
  }

  // ---------- Chat ----------

  List<ChatMessage> messagesWith(String providerId) =>
      List.unmodifiable(_messages[providerId] ?? const <ChatMessage>[]);

  /// Syarat beli: pengguna sudah pernah mengirim pesan ke penyedia.
  bool hasChatted(String providerId) =>
      (_messages[providerId] ?? const <ChatMessage>[]).any((m) => m.isMe);

  /// Id penyedia yang punya percakapan, terbaru di atas.
  List<String> get conversationIds {
    final ids = _messages.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toList();
    ids.sort((a, b) =>
        _messages[b]!.last.time.compareTo(_messages[a]!.last.time));
    return ids;
  }

  void sendMessage(String providerId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _add(providerId, trimmed, isMe: true);

    // Simulasi balasan penyedia setelah 1,5 detik.
    Timer(const Duration(milliseconds: 1500), () {
      final replyCount =
          (_messages[providerId] ?? []).where((m) => !m.isMe).length;
      _add(providerId, _autoReplies[replyCount % _autoReplies.length],
          isMe: false);
    });
  }

  void _add(String providerId, String text,
      {required bool isMe, DateTime? time}) {
    _messages.putIfAbsent(providerId, () => []).add(
          ChatMessage(text: text, isMe: isMe, time: time ?? DateTime.now()),
        );
    notifyListeners();
  }

  // ---------- Pesanan ----------

  List<Order> get orders => List.unmodifiable(
      _orders.toList()..sort((a, b) => b.date.compareTo(a.date)));

  bool hasOrdered(String offerId) =>
      _orders.any((o) => o.offer.id == offerId && o.status == OrderStatus.diproses);

  /// Membuat pesanan. Hanya boleh kalau sudah chat dengan penyedianya.
  Order? buy(ServiceOffer offer) {
    if (!hasChatted(offer.providerId)) return null;
    final order = Order(
      id: 'ORD-${(_orders.length + 1).toString().padLeft(4, '0')}',
      offer: offer,
      date: DateTime.now(),
    );
    _orders.add(order);
    _add(
      offer.providerId,
      'Saya sudah memesan "${offer.title}" (${order.id}).',
      isMe: true,
    );
    return order;
  }

  void completeOrder(Order order) {
    order.status = OrderStatus.selesai;
    notifyListeners();
  }

  /// Penyedia yang pernah dipakai, dikelompokkan dari riwayat pesanan.
  List<ProviderUsage> get usedProviders {
    final Map<String, List<Order>> grouped = {};
    for (final o in _orders) {
      grouped.putIfAbsent(o.offer.providerId, () => []).add(o);
    }
    final result = grouped.entries.map((e) {
      final list = e.value..sort((a, b) => b.date.compareTo(a.date));
      return ProviderUsage(
        provider: providerById(e.key),
        orderCount: list.length,
        totalSpent: list.fold(0, (sum, o) => sum + o.offer.price),
        lastUsed: list.first.date,
      );
    }).toList();
    result.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return result;
  }

  // ---------- Data awal (riwayat contoh) ----------

  void _seed() {
    final now = DateTime.now();

    // Riwayat chat & pesanan lama dengan Kreasi Pixel (p4)
    _messages['p4'] = [
      ChatMessage(
        text: 'Halo kak, saya mau buat logo untuk usaha kuliner saya.',
        isMe: true,
        time: now.subtract(const Duration(days: 21, hours: 2)),
      ),
      ChatMessage(
        text: 'Halo! Bisa, kami kirim contoh portofolio ya.',
        isMe: false,
        time: now.subtract(const Duration(days: 21, hours: 1)),
      ),
      ChatMessage(
        text: 'Logo sudah saya terima, terima kasih banyak!',
        isMe: true,
        time: now.subtract(const Duration(days: 16)),
      ),
    ];
    _orders.add(Order(
      id: 'ORD-0000',
      offer: offerById('s6'),
      date: now.subtract(const Duration(days: 20)),
      status: OrderStatus.selesai,
    ));

    // Percakapan yang belum jadi pesanan dengan Bina Usaha (p3)
    _messages['p3'] = [
      ChatMessage(
        text: 'Selamat siang, apakah bisa bantu urus PIRT?',
        isMe: true,
        time: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      ChatMessage(
        text: 'Siang! Bisa kak, biasanya prosesnya 5 hari kerja.',
        isMe: false,
        time: now.subtract(const Duration(days: 2, hours: 2)),
      ),
    ];
  }
}
