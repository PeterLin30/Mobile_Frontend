import 'package:flutter/material.dart';

import 'chat_room_page.dart';
import 'marketplace_data.dart';
import 'service_pages.dart';
import 'ui_helpers.dart';
import 'responsive.dart';

/// Tab "Pesan": daftar percakapan (riwayat pesan) dengan penyedia layanan.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cari layanan',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ServiceListPage()),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final ids = store.conversationIds;
          if (ids.isEmpty) return const _EmptyChat();

          return ResponsiveBody(
            child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: ids.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72, endIndent: 16),
            itemBuilder: (context, i) {
              final provider = store.providerById(ids[i]);
              final last = store.messagesWith(ids[i]).last;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: provider.color.withOpacity(0.15),
                  child: Icon(provider.icon, color: provider.color),
                ),
                title: Text(
                  provider.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${last.isMe ? 'Kamu: ' : ''}${last.text}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: kTextGrey),
                ),
                trailing: Text(
                  formatChatTime(last.time),
                  style: const TextStyle(fontSize: 11, color: kTextGrey),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(providerId: provider.id),
                  ),
                ),
              );
            },
          ),
          );
        },
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFC8F1F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada pesan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Percakapan dengan penyedia layanan '
              'MikroHub akan ditampilkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
