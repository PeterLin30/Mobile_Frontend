import 'package:flutter/material.dart';

import 'user_profile.dart';
import 'ui_helpers.dart';
import 'menu_section.dart';
import 'profile_header.dart';
import 'business_info_page.dart';
import 'edit_profile_page.dart';
import 'help_center_page.dart';
import 'service_pages.dart';
import 'chat_page.dart';
import 'order_history_page.dart';
import 'project_flow_pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile _user = const UserProfile(
    name: 'Nama Pengguna',
    email: 'nama@email.com',
    phone: '081234567890',
    bio: 'Pemilik usaha kecil yang ingin go digital.',
    role: 'Pelaku UMKM',
    businessName: 'Usaha Maju Jaya',
    businessCategory: 'Kuliner',
    businessDesc: 'Menjual makanan olahan rumahan.',
    address: 'Medan, Sumatera Utara',
  );

  bool _notificationOn = true;

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => EditProfilePage(user: _user)),
    );
    if (result != null && mounted) {
      setState(() => _user = result);
      showToast(context, 'Profil berhasil disimpan');
    }
  }

  Future<void> _openBusinessInfo() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => BusinessInfoPage(user: _user)),
    );
    if (result != null && mounted) {
      setState(() => _user = result);
      showToast(context, 'Informasi usaha disimpan');
    }
  }

  void _openHelpCenter() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'MikroHub UMKM',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.hub, color: kPrimary, size: 40),
      children: const [
        Text('Menghubungkan pelaku UMKM dengan developer app, '
            'pengolah bantuan bisnis, dan solusi digital lainnya.'),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu harus masuk lagi untuk menggunakan MikroHub.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: logika logout (hapus token, kembali ke halaman login)
              showToast(context, 'Berhasil keluar');
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: ListView(
        // padding bawah besar supaya tidak tertutup tombol tengah & navbar
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          ProfileHeader(user: _user, onTap: _openEditProfile),
          const SizedBox(height: 24),
          MenuSection(
            title: 'Akun',
            items: [
              MenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: _openEditProfile,
              ),
              MenuItem(
                icon: Icons.storefront_outlined,
                title: 'Informasi Usaha',
                subtitle: _user.businessName,
                onTap: _openBusinessInfo,
              ),
            ],
          ),
          const SizedBox(height: 16),
          MenuSection(
            title: 'Layanan',
            items: [
              MenuItem(
                icon: Icons.storefront,
                title: 'Jelajahi Layanan',
                subtitle: 'Cari developer & solusi digital',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServiceListPage()),
                ),
              ),
              MenuItem(
                icon: Icons.chat_bubble_outline,
                title: 'Pesan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                ),
              ),
              MenuItem(
                icon: Icons.history,
                title: 'Riwayat Pesanan & Penyedia',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                ),
              ),
              MenuItem(
                icon: Icons.request_quote_outlined,
                title: 'Penawaran Saya',
                subtitle: 'Lihat dan kelola proposal layanan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuotationListPage()),
                ),
              ),
              MenuItem(
                icon: Icons.timeline,
                title: 'Pelacakan Proyek',
                subtitle: 'Pantau progres proyek berjalan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProjectTrackingListPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MenuSection(
            title: 'Pengaturan',
            items: [
              MenuItem(
                icon: Icons.notifications_none,
                title: 'Notifikasi',
                trailing: Switch(
                  value: _notificationOn,
                  activeTrackColor: kPrimary,
                  onChanged: (v) => setState(() => _notificationOn = v),
                ),
                onTap: () => setState(() => _notificationOn = !_notificationOn),
              ),
              MenuItem(
                icon: Icons.help_outline,
                title: 'Pusat Bantuan',
                onTap: _openHelpCenter,
              ),
              MenuItem(
                icon: Icons.info_outline,
                title: 'Tentang MikroHub',
                onTap: _showAbout,
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'MikroHub v1.0.0',
              style: TextStyle(fontSize: 12, color: kTextGrey),
            ),
          ),
        ],
      ),
    );
  }
}
