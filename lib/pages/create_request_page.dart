import 'package:flutter/material.dart';
import 'responsive.dart';

const Color _primary = Color(0xFF5CC8CC);
const Color _textDark = Color(0xFF202124);
const Color _textGrey = Color(0xFF6B7280);

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _budget = TextEditingController();
  final _desc = TextEditingController();

  static const _categories = ['Mobile', 'Web', 'Cyber', 'Graphic', 'Digital', 'Bisnis'];
  String _category = 'Mobile';
  DateTime? _deadline;

  @override
  void dispose() {
    _title.dispose();
    _budget.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      _toast('Pilih target selesai terlebih dahulu');
      return;
    }
    // TODO: kirim data ke backend / simpan ke store (judul, kategori, budget, deadline, deskripsi)
    final title = _title.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Permintaan "$title" berhasil dikirim'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Permintaan')),
body: ResponsiveBody(
        maxWidth: 640,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: _decoration('Judul proyek', Icons.title),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Judul minimal 5 karakter'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    selectedColor: _primary.withOpacity(0.25),
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: _decoration('Budget', Icons.payments_outlined)
                  .copyWith(prefixText: 'Rp '),
              validator: (v) {
                final n = int.tryParse((v ?? '').replaceAll('.', '').trim());
                if (n == null || n <= 0) return 'Masukkan budget yang valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDeadline,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _decoration('Target selesai', Icons.event_outlined),
                child: Text(
                  _deadline == null ? 'Pilih tanggal' : _formatDate(_deadline!),
                  style: TextStyle(
                    color: _deadline == null ? _textGrey : _textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              maxLines: 5,
              maxLength: 500,
              decoration: _decoration('Deskripsi kebutuhan', Icons.description_outlined),
              validator: (v) => (v == null || v.trim().length < 20)
                  ? 'Jelaskan kebutuhanmu minimal 20 karakter'
                  : null,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: _primary,
              ),
              child: const Text('Kirim Permintaan'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
