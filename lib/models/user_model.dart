enum UserRole { pelanggan, operator, admin }

class UserModel {
  final String idUser;
  final String nama;
  final String email;
  final String noHp;
  final UserRole role;
  final String? alamat;
  final double? latitude;
  final double? longitude;
  final String? idGerobak;

  UserModel({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
    this.alamat,
    this.latitude,
    this.longitude,
    this.idGerobak,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['idUser'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      noHp: map['noHp'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.pelanggan,
      ),
      alamat: map['alamat'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      idGerobak: map['idGerobak'],
    );
  }
}
