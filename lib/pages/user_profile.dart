const List<String> kUserRoles = [
  'Pelaku UMKM',
  'Developer App',
  'Pengolah Bantuan Bisnis',
  'Penyedia Solusi Digital',
];

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String role;
  final String businessName;
  final String businessCategory;
  final String businessDesc;
  final String address;
  final int avatarIndex; // -1 = avatar default

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.role,
    required this.businessName,
    required this.businessCategory,
    required this.businessDesc,
    required this.address,
    this.avatarIndex = -1,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? role,
    String? businessName,
    String? businessCategory,
    String? businessDesc,
    String? address,
    int? avatarIndex,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      businessDesc: businessDesc ?? this.businessDesc,
      address: address ?? this.address,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
