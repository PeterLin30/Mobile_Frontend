import 'package:flutter/material.dart';

import 'user_profile.dart';
import 'ui_helpers.dart';
import 'responsive.dart';

const List<String> kBusinessCategories = [
  'Kuliner',
  'Fashion',
  'Kerajinan',
  'Jasa',
  'Pertanian',
  'Lainnya',
];

class BusinessInfoPage extends StatefulWidget {
  final UserProfile user;
  const BusinessInfoPage({super.key, required this.user});

  @override
  State<BusinessInfoPage> createState() => _BusinessInfoPageState();
}

class _BusinessInfoPageState extends State<BusinessInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _desc;
  late String _category;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.businessName);
    _address = TextEditingController(text: widget.user.address);
    _desc = TextEditingController(text: widget.user.businessDesc);
    _category = widget.user.businessCategory;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      widget.user.copyWith(
        businessName: _name.text.trim(),
        businessCategory: _category,
        address: _address.text.trim(),
        businessDesc: _desc.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Usaha'),
        actions: [TextButton(onPressed: _save, child: const Text('Simpan'))],
      ),
body: ResponsiveBody(
        maxWidth: 640,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildTextField(
              _name,
              'Nama usaha',
              Icons.storefront_outlined,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama usaha wajib diisi'
                  : null,
            ),
            const Text('Kategori usaha',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in kBusinessCategories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    selectedColor: kPrimary.withOpacity(0.25),
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            buildTextField(
              _address,
              'Alamat usaha',
              Icons.location_on_outlined,
              lines: 2,
            ),
            buildTextField(
              _desc,
              'Deskripsi usaha',
              Icons.description_outlined,
              lines: 4,
              maxLength: 200,
            ),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: kPrimary,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
