import 'package:flutter/material.dart';

import 'ui_helpers.dart';

class AvatarOption {
  final IconData icon;
  final Color color;
  const AvatarOption(this.icon, this.color);
}

const List<AvatarOption> kAvatarOptions = [
  AvatarOption(Icons.storefront, Color(0xFF5CC8CC)),
  AvatarOption(Icons.coffee, Color(0xFF8D6E63)),
  AvatarOption(Icons.restaurant, Color(0xFFFF8A65)),
  AvatarOption(Icons.checkroom, Color(0xFF9575CD)),
  AvatarOption(Icons.eco, Color(0xFF66BB6A)),
  AvatarOption(Icons.code, Color(0xFF42A5F5)),
];

class ProfileAvatar extends StatelessWidget {
  final int index; // -1 = default
  final double radius;

  const ProfileAvatar({super.key, required this.index, this.radius = 36});

  @override
  Widget build(BuildContext context) {
    final option = index >= 0 ? kAvatarOptions[index] : null;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Icon(
        option?.icon ?? Icons.person,
        size: radius * 1.05,
        color: option?.color ?? kPrimary,
      ),
    );
  }
}
