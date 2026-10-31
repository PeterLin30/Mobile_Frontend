import 'package:flutter/material.dart';

import 'marketplace_data.dart';
import 'ui_helpers.dart';
import 'responsive.dart';

class RequestQuotationPage extends StatefulWidget {
  final ServiceOffer offer;
  const RequestQuotationPage({super.key, required this.offer});

  @override
  State<RequestQuotationPage> createState() => _RequestQuotationPageState();
}

class _RequestQuotationPageState extends State<RequestQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final _needController = TextEditingController();
  final _budgetController = TextEditingController();
  final _store = MarketplaceStore.instance;

  @override
  void dispose() {
    _needController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _store.providerById(widget.offer.providerId);
    return Scaffold(
      appBar: AppBar(title: const Text('Minta Penawaran')),
      body: ResponsiveBody(
        maxWidth: 640,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Row(children: [
                CircleAvatar(backgroundColor: provider.color.withOpacity(.15), child: Icon(provider.icon, color: provider.color)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(provider.name, style: const TextStyle(color: kTextGrey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('Harga katalog: ${formatRupiah(widget.offer.price)}', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                ])),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Ceritakan kebutuhan usaha kamu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Informasi ini akan dimasukkan ke proposal simulasi agar alur demo terasa seperti transaksi nyata.', style: TextStyle(color: kTextGrey, height: 1.4)),
            const SizedBox(height: 18),
            TextFormField(
              controller: _needController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Kebutuhan / brief proyek', hintText: 'Contoh: Saya memiliki usaha makanan dan membutuhkan desain yang modern...', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (value) => (value == null || value.trim().length < 10) ? 'Jelaskan kebutuhan minimal 10 karakter.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Anggaran (opsional)', hintText: 'Contoh: 1000000', prefixText: 'Rp ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                if (parsed == null || parsed <= 0) return 'Masukkan anggaran yang valid.';
                return null;
              },
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFEAF8F8), borderRadius: BorderRadius.circular(12)),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: kPrimary), SizedBox(width: 10), Expanded(child: Text('Mode frontend demo: penawaran akan dibuat otomatis menggunakan harga dan durasi katalog. Tidak ada pembayaran sungguhan.', style: TextStyle(height: 1.4, fontSize: 12)))]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final parsedBudget = int.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final quotation = _store.createQuotation(offer: widget.offer, businessNeed: _needController.text, budget: parsedBudget);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuotationDetailPage(quotation: quotation)));
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Buat Penawaran Demo'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class QuotationListPage extends StatelessWidget {
  const QuotationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Penawaran Saya'), actions: [IconButton(tooltip: 'Proyek saya', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectTrackingListPage())), icon: const Icon(Icons.timeline))]),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final quotations = store.quotations;
          if (quotations.isEmpty) return const _EmptyState(icon: Icons.request_quote_outlined, title: 'Belum ada penawaran', message: 'Buka layanan yang kamu minati lalu pilih Minta Penawaran.');
          return ResponsiveCardList(
            padding: const EdgeInsets.all(16),
            itemCount: quotations.length,
            itemBuilder: (context, index) {
              final q = quotations[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuotationDetailPage(quotation: q))),
                child: Container(padding: const EdgeInsets.all(14), decoration: cardDecoration(), child: Row(children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: kPrimary.withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description_outlined, color: kPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.offer.title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('${q.id} • ${formatDate(q.createdAt)}', style: const TextStyle(color: kTextGrey, fontSize: 12)), const SizedBox(height: 5), Text(formatRupiah(q.proposedPrice), style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold))])),
                  const SizedBox(width: 8),
                  _StatusPill(label: _quotationStatus(q.status), color: _quotationColor(q.status)),
                ])),
              );
            },
          );
        },
      ),
    );
  }
}

class QuotationDetailPage extends StatelessWidget {
  final ServiceQuotation quotation;
  const QuotationDetailPage({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    final provider = store.providerById(quotation.offer.providerId);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Penawaran')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ResponsiveBody(maxWidth: 720, child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(18), decoration: cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.request_quote, color: kPrimary, size: 28), const SizedBox(width: 10), Expanded(child: Text(quotation.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), _StatusPill(label: _quotationStatus(quotation.status), color: _quotationColor(quotation.status))]),
            const SizedBox(height: 18),
            Text(quotation.offer.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(provider.name, style: const TextStyle(color: kTextGrey)),
            const Divider(height: 28),
            _DetailRow(label: 'Harga penawaran', value: formatRupiah(quotation.proposedPrice), highlight: true),
            if (quotation.requestedBudget > 0) _DetailRow(label: 'Anggaran pengguna', value: formatRupiah(quotation.requestedBudget)),
            _DetailRow(label: 'Estimasi pengerjaan', value: quotation.proposedDuration),
            _DetailRow(label: 'Jumlah revisi', value: '${quotation.revisions} kali'),
            _DetailRow(label: 'Tanggal penawaran', value: formatDate(quotation.createdAt)),
            const SizedBox(height: 16),
            const Text('Brief kebutuhan usaha', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(quotation.businessNeed.isEmpty ? 'Tidak ada catatan tambahan.' : quotation.businessNeed, style: const TextStyle(height: 1.45)),
          ])),
          const SizedBox(height: 18),
          if (quotation.status == QuotationStatus.ditawarkan) ...[
            FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size.fromHeight(48)), onPressed: () {
              final project = store.acceptQuotation(quotation);
              if (project != null) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProjectTrackingDetailPage(project: project)));
            }, icon: const Icon(Icons.check_circle_outline), label: const Text('Terima Penawaran & Mulai Proyek')),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => _confirmReject(context, store), icon: const Icon(Icons.close), label: const Text('Tolak Penawaran')),
          ] else if (quotation.status == QuotationStatus.diterima) ...[
            FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size.fromHeight(48)), onPressed: () {
              TrackedProject? project;
              for (final item in store.projects) {
                if (item.quotation.id == quotation.id) { project = item; break; }
              }
              if (project != null) Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectTrackingDetailPage(project: project!)));
            }, icon: const Icon(Icons.timeline), label: const Text('Lihat Proyek')),
          ] else const _EmptyState(icon: Icons.block, title: 'Penawaran ditolak', message: 'Penawaran ini sudah ditolak.'),
          const SizedBox(height: 12),
          const Text('Simulasi frontend: persetujuan ini tidak membuat transaksi atau pembayaran nyata.', textAlign: TextAlign.center, style: TextStyle(color: kTextGrey, fontSize: 11)),
        ])),
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, MarketplaceStore store) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Tolak penawaran?'), content: const Text('Status penawaran akan berubah menjadi ditolak.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tolak'))]));
    if (confirmed == true) store.rejectQuotation(quotation);
  }
}

class ProjectTrackingListPage extends StatelessWidget {
  const ProjectTrackingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacakan Proyek')),
      body: ListenableBuilder(listenable: store, builder: (context, _) {
        final projects = store.projects;
        if (projects.isEmpty) return const _EmptyState(icon: Icons.timeline, title: 'Belum ada proyek', message: 'Terima penawaran untuk memulai proyek pertamamu.');
        return ResponsiveCardList(padding: const EdgeInsets.all(16), itemCount: projects.length, itemBuilder: (context, index) {
          final project = projects[index];
          final complete = project.milestones.where((m) => m.isComplete).length;
          return InkWell(borderRadius: BorderRadius.circular(16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectTrackingDetailPage(project: project))), child: Container(padding: const EdgeInsets.all(14), decoration: cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(project.quotation.offer.title, style: const TextStyle(fontWeight: FontWeight.bold))), _StatusPill(label: _projectStatus(project.status), color: _projectColor(project.status))]),
            const SizedBox(height: 5),
            Text('${project.id} • ${formatDate(project.startedAt)}', style: const TextStyle(color: kTextGrey, fontSize: 12)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: complete / project.milestones.length, minHeight: 6, borderRadius: BorderRadius.circular(8), color: kPrimary, backgroundColor: kPrimary.withOpacity(.15)),
            const SizedBox(height: 6),
            Text('$complete dari ${project.milestones.length} tahapan selesai', style: const TextStyle(color: kTextGrey, fontSize: 12)),
          ])));
        });
      }),
    );
  }
}

class ProjectTrackingDetailPage extends StatelessWidget {
  final TrackedProject project;
  const ProjectTrackingDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceStore.instance;
    final provider = store.providerById(project.quotation.offer.providerId);
    return Scaffold(
      appBar: AppBar(title: const Text('Progres Proyek')),
      body: ListenableBuilder(listenable: store, builder: (context, _) {
        final completed = project.milestones.where((m) => m.isComplete).length;
        return ResponsiveBody(maxWidth: 720, child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(padding: const EdgeInsets.all(18), decoration: cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(project.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), _StatusPill(label: _projectStatus(project.status), color: _projectColor(project.status))]),
            const SizedBox(height: 10),
            Text(project.quotation.offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 5),
            Text(provider.name, style: const TextStyle(color: kTextGrey)),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progres keseluruhan', style: TextStyle(fontWeight: FontWeight.w600)), Text('${(completed / project.milestones.length * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary))]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: completed / project.milestones.length, minHeight: 8, borderRadius: BorderRadius.circular(8), color: kPrimary, backgroundColor: kPrimary.withOpacity(.15)),
            const SizedBox(height: 10),
            Text('${formatRupiah(project.quotation.proposedPrice)} • ${project.quotation.proposedDuration} • ${project.quotation.revisions} revisi', style: const TextStyle(color: kTextGrey, fontSize: 12)),
          ])),
          const SizedBox(height: 22),
          const Text('Timeline pengerjaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(project.milestones.length, (index) {
            final milestone = project.milestones[index];
            final isLast = index == project.milestones.length - 1;
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 32, child: Column(children: [Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: milestone.isComplete ? kPrimary : Colors.white, border: Border.all(color: milestone.isComplete ? kPrimary : const Color(0xFFD5D9DE), width: 1.5)), child: Icon(milestone.isComplete ? Icons.check : Icons.circle_outlined, size: 16, color: milestone.isComplete ? Colors.white : kTextGrey)), if (!isLast) Container(width: 2, height: 66, color: milestone.isComplete ? kPrimary : const Color(0xFFE0E4E8))])),
              const SizedBox(width: 12),
              Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 22, top: 2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(milestone.title, style: TextStyle(fontWeight: FontWeight.w600, color: milestone.isComplete ? kTextDark : kTextGrey)), const SizedBox(height: 4), Text(milestone.description, style: const TextStyle(fontSize: 12, height: 1.4, color: kTextGrey)), if (milestone.completedAt != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Selesai ${formatDate(milestone.completedAt!)}', style: const TextStyle(fontSize: 11, color: kPrimary)))]))),
            ]);
          }),
          if (project.status != ProjectStatus.selesai) ...[
            if (project.status == ProjectStatus.review) OutlinedButton.icon(onPressed: () => _showRevisionDialog(context, store), icon: const Icon(Icons.edit_note), label: const Text('Minta Revisi')),
            const SizedBox(height: 8),
            FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size.fromHeight(48)), onPressed: () => _advanceWithFeedback(context, store), icon: Icon(project.status == ProjectStatus.review ? Icons.check_circle_outline : Icons.arrow_forward), label: Text(project.status == ProjectStatus.review ? 'Setujui Hasil & Selesaikan' : project.status == ProjectStatus.revisi ? 'Mulai Pengerjaan Ulang' : 'Simulasikan Progres Berikutnya')),
          ] else Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Expanded(child: Text('Proyek selesai. Terima kasih telah menggunakan MikroHub!', style: TextStyle(fontWeight: FontWeight.w600)))])),
          const SizedBox(height: 12),
          const Text('Catatan: tombol progres hanya untuk demonstrasi frontend; status tidak dikirim ke penyedia sungguhan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: kTextGrey)),
        ]));
      }),
    );
  }

  void _advanceWithFeedback(BuildContext context, MarketplaceStore store) {
    store.advanceProject(project);
    final message = project.status == ProjectStatus.review ? 'Proyek masuk tahap review.' : project.status == ProjectStatus.selesai ? 'Proyek ditandai selesai.' : 'Progres proyek diperbarui.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _showRevisionDialog(BuildContext context, MarketplaceStore store) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Ajukan revisi?'), content: const Text('Proyek akan kembali ke tahap pengerjaan dalam simulasi ini.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajukan'))]));
    if (confirmed == true) {
      store.requestRevision(project);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permintaan revisi dicatat.')));
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow({required this.label, required this.value, this.highlight = false});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: const TextStyle(color: kTextGrey))), const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w600, color: highlight ? kPrimary : kTextDark)))]));
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: kTextGrey), const SizedBox(height: 14), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: kTextGrey, height: 1.4))])));
}

String _quotationStatus(QuotationStatus status) => switch (status) {
  QuotationStatus.ditawarkan => 'Menunggu keputusan',
  QuotationStatus.diterima => 'Diterima',
  QuotationStatus.ditolak => 'Ditolak',
};
Color _quotationColor(QuotationStatus status) => switch (status) {
  QuotationStatus.ditawarkan => Colors.orange.shade800,
  QuotationStatus.diterima => Colors.green.shade700,
  QuotationStatus.ditolak => Colors.red.shade700,
};
String _projectStatus(ProjectStatus status) => switch (status) {
  ProjectStatus.dikerjakan => 'Dikerjakan',
  ProjectStatus.review => 'Review hasil',
  ProjectStatus.revisi => 'Revisi',
  ProjectStatus.selesai => 'Selesai',
};
Color _projectColor(ProjectStatus status) => switch (status) {
  ProjectStatus.dikerjakan => Colors.blue.shade700,
  ProjectStatus.review => Colors.orange.shade800,
  ProjectStatus.revisi => Colors.deepPurple.shade600,
  ProjectStatus.selesai => Colors.green.shade700,
};
