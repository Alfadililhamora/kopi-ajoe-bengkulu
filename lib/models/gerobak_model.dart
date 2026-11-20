class GerobakModel {
  final String idGerobak;
  final String namaGerobak;
  final String alamatLokasi;
  final double latitude;
  final double longitude;
  bool statusBuka;
  final String jamOperasional;

  GerobakModel({
    required this.idGerobak,
    required this.namaGerobak,
    required this.alamatLokasi,
    required this.latitude,
    required this.longitude,
    required this.statusBuka,
    required this.jamOperasional,
  });

  factory GerobakModel.fromMap(Map<String, dynamic> map) {
    return GerobakModel(
      idGerobak: map['idGerobak'] ?? '',
      namaGerobak: map['namaGerobak'] ?? '',
      alamatLokasi: map['alamatLokasi'] ?? '',
      latitude: (map['latitude'] ?? -3.7928).toDouble(),
      longitude: (map['longitude'] ?? 102.2608).toDouble(),
      statusBuka: map['statusBuka'] ?? false,
      jamOperasional: map['jamOperasional'] ?? '08:00 - 22:00',
    );
  }
}
