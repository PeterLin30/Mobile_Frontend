import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color primaryColor = Color(0xFF5CC8CC);
const Color lightCyan = Color(0xFFC8F1F3);
const Color darkTeal = Color(0xFF397E82);
const Color textColor = Color(0xFF202124);

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  static const List<Map<String, String>> vouchers = [
    {
      'title': 'Promo UMKM',
      'discount': '20%',
      'description': 'Diskon untuk layanan digital UMKM.',
      'code': 'UMKM20',
      'validity': '31 Desember 2026',
      'minimum': 'Minimal transaksi Rp50.000',
    },
    {
      'title': 'Paket Hemat',
      'discount': '15%',
      'description': 'Hemat untuk kebutuhan digital bisnis.',
      'code': 'HEMAT15',
      'validity': '31 Desember 2026',
      'minimum': 'Minimal transaksi Rp30.000',
    },
    {
      'title': 'Promo Desain',
      'discount': '10%',
      'description': 'Diskon untuk layanan desain grafis.',
      'code': 'DESAIN10',
      'validity': '30 November 2026',
      'minimum': 'Minimal transaksi Rp25.000',
    },
    {
      'title': 'Pelanggan Baru',
      'discount': '25%',
      'description': 'Penawaran khusus untuk pengguna baru.',
      'code': 'MULAI25',
      'validity': '31 Desember 2026',
      'minimum': 'Minimal transaksi Rp50.000',
    },
  ];

  Future<void> _copyVoucher(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Kode voucher $code berhasil disalin.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  void _useVoucher(BuildContext context, Map<String, String> voucher) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.confirmation_number_rounded,
            color: darkTeal,
            size: 42,
          ),
          title: Text(voucher['title']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Diskon ${voucher['discount']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkTeal,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gunakan kode berikut saat melakukan '
                'pemesanan layanan MikroHub.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: lightCyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  voucher['code']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: darkTeal,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                voucher['minimum']!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _copyVoucher(context, voucher['code']!);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Salin Kode'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoucherCard(BuildContext context, Map<String, String> voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: lightCyan,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    size: 32,
                    color: darkTeal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Diskon ${voucher['discount']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkTeal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        voucher['description']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: darkTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KODE VOUCHER',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            voucher['code']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Salin kode voucher',
                      onPressed: () => _copyVoucher(context, voucher['code']!),
                      icon: const Icon(Icons.copy_rounded, color: darkTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Berlaku hingga ${voucher['validity']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        voucher['minimum']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _useVoucher(context, voucher),
                    child: const Text(
                      'Gunakan Voucher',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Voucher Coupon',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [lightCyan, Color(0xFFE9FAFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.redeem_rounded, size: 44, color: darkTeal),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher untuk Bisnismu!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pilih voucher dan nikmati penawaran '
                        'menarik untuk kebutuhan usahamu.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Voucher Tersedia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${vouchers.length} voucher tersedia untuk kamu',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...vouchers.map((voucher) => _buildVoucherCard(context, voucher)),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Voucher ini merupakan data contoh aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
