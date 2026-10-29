import 'package:flutter/material.dart';

import 'create_request_page.dart';

const Color _primary = Color(0xFF5CC8CC);
const Color _textDark = Color(0xFF202124);

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.onTap);
}

/// Bottom sheet "Aksi Cepat" untuk tombol tengah navbar.
class QuickActionSheet {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onFindDeveloper,
    required VoidCallback onBusinessHelp,
    required VoidCallback onConsult,
    required VoidCallback onVoucher,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final actions = <_QuickAction>[
          _QuickAction(Icons.search, 'Cari\nDeveloper', onFindDeveloper),
          _QuickAction(
              Icons.account_balance_outlined, 'Bantuan\nBisnis', onBusinessHelp),
          _QuickAction(Icons.forum_outlined, 'Konsultasi', onConsult),
          _QuickAction(
              Icons.confirmation_number_outlined, 'Voucher', onVoucher),
        ];

        // Tutup sheet dulu, baru jalankan aksinya.
        void run(VoidCallback action) {
          Navigator.pop(sheetContext);
          action();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mau ngapain hari ini?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Aksi utama ----
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => run(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateRequestPage(),
                      ),
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5CC8CC), Color(0xFF8EDDE0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: _primary),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buat Permintaan Proyek',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ceritakan kebutuhanmu, developer akan mengirim penawaran',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Aksi lainnya ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final a in actions)
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => run(a.onTap),
                        child: SizedBox(
                          width: 72,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _primary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(a.icon, color: _primary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
