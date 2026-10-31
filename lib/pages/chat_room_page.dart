import 'package:flutter/material.dart';

import 'marketplace_data.dart';
import 'purchase_flow.dart';
import 'ui_helpers.dart';
import 'responsive.dart';

class ChatRoomPage extends StatefulWidget {
  final String providerId;

  /// Kalau dibuka dari halaman detail layanan, tampilkan kartu layanan + tombol beli.
  final ServiceOffer? offer;

  const ChatRoomPage({super.key, required this.providerId, this.offer});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _store = MarketplaceStore.instance;
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _store.removeListener(_scrollToBottom);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    _store.sendMessage(widget.providerId, _controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _store.providerById(widget.providerId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: provider.color.withOpacity(0.15),
              child: Icon(provider.icon, color: provider.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    provider.role,
                    style: const TextStyle(fontSize: 12, color: kTextGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final messages = _store.messagesWith(widget.providerId);
          return ResponsiveBody(
            maxWidth: 800,
            child: Column(
            children: [
              if (widget.offer != null) _buildOfferBar(widget.offer!),
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Mulai percakapan dengan penyedia layanan',
                          style: TextStyle(color: kTextGrey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _Bubble(message: messages[i]),
                      ),
              ),
              _buildInput(),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _buildOfferBar(ServiceOffer offer) {
    final canBuy = _store.hasChatted(offer.providerId);
    final ordered = _store.hasOrdered(offer.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  canBuy
                      ? formatRupiah(offer.price)
                      : 'Kirim pesan dulu untuk bisa membeli',
                  style: TextStyle(
                    fontSize: 12,
                    color: canBuy ? kPrimary : kTextGrey,
                    fontWeight: canBuy ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed:
                (canBuy && !ordered) ? () => confirmPurchase(context, offer) : null,
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            child: Text(ordered ? 'Dipesan' : 'Beli'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: kPrimary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // 75% lebar layar, tapi tidak lebih dari 75% area chat (maks 800)
          maxWidth: (MediaQuery.sizeOf(context).width > 800
                  ? 800
                  : MediaQuery.sizeOf(context).width) *
              0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? kPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe ? null : Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatTime(message.time),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : kTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
