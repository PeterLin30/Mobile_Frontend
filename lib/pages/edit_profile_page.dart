import 'package:flutter/material.dart';

import 'user_profile.dart';
import 'ui_helpers.dart';
import 'profile_avatar.dart';
import 'responsive.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  late int _avatarIndex;
  late String _role;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _email = TextEditingController(text: widget.user.email);
    _phone = TextEditingController(text: widget.user.phone);
    _bio = TextEditingController(text: widget.user.bio);
    _avatarIndex = widget.user.avatarIndex;
    _role = widget.user.role;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      widget.user.copyWith(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        bio: _bio.text.trim(),
        role: _role,
        avatarIndex: _avatarIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [TextButton(onPressed: _save, child: const Text('Simpan'))],
      ),
body: ResponsiveBody(
        maxWidth: 640,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Avatar', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kAvatarOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final selected = _avatarIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _avatarIndex = i),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? kPrimary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            kAvatarOptions[i].color.withOpacity(0.15),
                        child: Icon(kAvatarOptions[i].icon,
                            color: kAvatarOptions[i].color),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Peran', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in kUserRoles)
                  ChoiceChip(
                    label: Text(r),
                    selected: _role == r,
                    selectedColor: kPrimary.withOpacity(0.25),
                    onSelected: (_) => setState(() => _role = r),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            buildTextField(
              _name,
              'Nama lengkap',
              Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            buildTextField(
              _email,
              'Email',
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Email wajib diisi';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            buildTextField(
              _phone,
              'No. telepon',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v?.trim().length ?? 0) < 9 ? 'Nomor telepon tidak valid' : null,
            ),
            buildTextField(
              _bio,
              'Bio singkat',
              Icons.edit_note,
              lines: 3,
              maxLength: 120,
            ),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: kPrimary,
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
