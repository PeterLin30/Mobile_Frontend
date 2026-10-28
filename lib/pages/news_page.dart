import 'package:flutter/material.dart';

const Color _primary = Color(0xFF5CC8CC);
const Color _lightCyan = Color(0xFFC8F1F3);
const Color _darkTeal = Color(0xFF397E82);

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  static const List<Map<String, String>> _news = [
    {
      'category': 'Bisnis',
      'title': 'Tips Mengembangkan Bisnis UMKM di Era Digital',
      'date': '28 Oktober 2026',
      'description':
          'Pelaku UMKM dapat memanfaatkan teknologi digital '
          'untuk memperluas jangkauan pasar, mempermudah '
          'komunikasi dengan pelanggan, dan meningkatkan '
          'efisiensi operasional bisnis. Mulailah dengan '
          'memilih platform yang sesuai dengan target pasar '
          'dan kebutuhan usaha.',
    },
    {
      'category': 'Teknologi',
      'title': 'Pentingnya Website untuk Bisnis Lokal',
      'date': '25 Oktober 2026',
      'description':
          'Website dapat menjadi tempat bagi pelanggan untuk '
          'mengenal produk, melihat informasi usaha, dan '
          'menghubungi pemilik bisnis. Website yang informatif '
          'dapat membantu meningkatkan kepercayaan pelanggan.',
    },
    {
      'category': 'Branding',
      'title': 'Strategi Branding agar UMKM Lebih Dikenal',
      'date': '22 Oktober 2026',
      'description':
          'Identitas merek yang konsisten membantu usaha '
          'lebih mudah dikenali. Gunakan nama, warna, logo, '
          'dan gaya komunikasi yang sesuai dengan karakter '
          'bisnis serta kebutuhan pelanggan.',
    },
    {
      'category': 'Pemasaran',
      'title': 'Cara Memanfaatkan Media Sosial untuk Promosi',
      'date': '20 Oktober 2026',
      'description':
          'Media sosial dapat membantu bisnis menjangkau '
          'pelanggan baru. Buat konten yang relevan, tampilkan '
          'produk dengan jelas, dan tanggapi pertanyaan '
          'pelanggan secara konsisten.',
    },
    {
      'category': 'Keuangan',
      'title': 'Pentingnya Mengelola Keuangan UMKM',
      'date': '18 Oktober 2026',
      'description':
          'Catat pemasukan dan pengeluaran secara rutin, '
          'pisahkan uang pribadi dari uang usaha, dan '
          'evaluasi biaya secara berkala agar kondisi '
          'keuangan bisnis lebih mudah dipantau.',
    },
  ];

  void _openNews(BuildContext context, Map<String, String> news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailPage(news: news)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Semua Berita'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final news = _news[index];

          return Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openNews(context, news),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 76,
                      height: 86,
                      decoration: BoxDecoration(
                        color: _lightCyan,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForCategory(news['category']!),
                        size: 34,
                        color: _darkTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _lightCyan,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              news['category']!,
                              style: const TextStyle(
                                color: _darkTeal,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news['title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            news['date']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Baca selengkapnya',
                                style: TextStyle(
                                  color: _darkTeal,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: _darkTeal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Bisnis':
        return Icons.trending_up_rounded;
      case 'Teknologi':
        return Icons.language_rounded;
      case 'Branding':
        return Icons.lightbulb_outline_rounded;
      case 'Pemasaran':
        return Icons.campaign_rounded;
      case 'Keuangan':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}

class NewsDetailPage extends StatelessWidget {
  final Map<String, String> news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
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
                color: _lightCyan,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                NewsPage._iconForCategory(news['category']!),
                size: 72,
                color: _darkTeal,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _lightCyan,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                news['category']!,
                style: const TextStyle(
                  color: _darkTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              news['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              news['date']!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 32),
            Text(
              news['description']!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Berita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
