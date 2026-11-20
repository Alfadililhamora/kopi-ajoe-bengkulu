import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gerobak_model.dart';
import '../models/menu_model.dart';
import '../models/pesanan_model.dart';
import '../models/user_model.dart';

class KopiAjoeService {
  static final KopiAjoeService _instance = KopiAjoeService._internal();
  factory KopiAjoeService() => _instance;
  KopiAjoeService._internal() {
    _seedInitialData();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  final List<UserModel> _demoUsers = [];
  final List<GerobakModel> _gerobakList = [];
  final List<MenuModel> _masterMenuList = [];
  final List<StokMenuModel> _stokList = [];
  final List<PesananModel> _pesananList = [];

  void _seedInitialData() {
    _demoUsers.addAll([
      UserModel(
        idUser: 'USR-001',
        nama: 'Alfadil Ilhamora',
        email: 'pelanggan@kopiajoe.id',
        noHp: '085180518503',
        role: UserRole.pelanggan,
        alamat: 'Jl. Merapi Raya, Kota Bengkulu',
      ),
      UserModel(
        idUser: 'OP-001',
        nama: 'Bang Joe (Barista Merapi)',
        email: 'operator1@kopiajoe.id',
        noHp: '081278901122',
        role: UserRole.operator,
        idGerobak: 'GRB-01',
      ),
      UserModel(
        idUser: 'ADM-001',
        nama: 'Admin Pusat Kopi Ajoe',
        email: 'admin@kopiajoe.id',
        noHp: '08117300001',
        role: UserRole.admin,
      ),
    ]);

    _gerobakList.addAll([
      GerobakModel(
        idGerobak: 'GRB-01',
        namaGerobak: 'Gerobak 01 - Jl. Merapi Raya',
        alamatLokasi: 'Depan Modhecom Store, Jl. Merapi Raya',
        latitude: -3.8005,
        longitude: 102.2821,
        statusBuka: true,
        jamOperasional: '08:00 - 22:00 WIB',
      ),
      GerobakModel(
        idGerobak: 'GRB-02',
        namaGerobak: 'Gerobak 02 - Kampus Unived Dehasen',
        alamatLokasi: 'Jl. Meranti Raya No. 32, Sawah Lebar',
        latitude: -3.7962,
        longitude: 102.2754,
        statusBuka: true,
        jamOperasional: '07:30 - 18:00 WIB',
      ),
      GerobakModel(
        idGerobak: 'GRB-04',
        namaGerobak: 'Gerobak 04 - Simpang Lima Ratu Samban',
        alamatLokasi: 'Jl. Jenderal Sudirman, Simpang Lima',
        latitude: -3.7925,
        longitude: 102.2652,
        statusBuka: false,
        jamOperasional: '09:00 - 21:00 WIB',
      ),
    ]);

    _masterMenuList.addAll([
      MenuModel(
        idMenu: 'MNU-01',
        namaMenu: 'Kopi Ajoe Susu Gula Aren',
        kategori: 'Kopi',
        harga: 12000,
        deskripsi: 'Espresso robusta Bengkulu dengan susu segar & gula aren.',
        fotoUrl: 'kopi_aren',
      ),
      MenuModel(
        idMenu: 'MNU-02',
        namaMenu: 'Kopi Hitam Ajoe Klasik',
        kategori: 'Kopi',
        harga: 8000,
        deskripsi: 'Seduhan kopi hitam robusta khas Kepahiang Bengkulu.',
        fotoUrl: 'kopi_hitam',
      ),
      MenuModel(
        idMenu: 'MNU-04',
        namaMenu: 'Teh Tarik Ajoe Bengkulu',
        kategori: 'Teh',
        harga: 10000,
        deskripsi: 'Teh hitam pilihan dikocok berbusa dengan susu kental manis.',
        fotoUrl: 'teh_tarik',
      ),
      MenuModel(
        idMenu: 'MNU-05',
        namaMenu: 'Es Matcha Susu Ajoe',
        kategori: 'ES',
        harga: 15000,
        deskripsi: 'Minuman dingin matcha premium dengan susu full cream.',
        fotoUrl: 'es_matcha',
      ),
    ]);

    int stokCounter = 1;
    for (var gerobak in _gerobakList) {
      for (var menu in _masterMenuList) {
        _stokList.add(StokMenuModel(
          idStok: 'STK-${stokCounter++}',
          idGerobak: gerobak.idGerobak,
          idMenu: menu.idMenu,
          jumlahStok: 15,
        ));
      }
    }
  }

  /// 1. Login via Supabase Authentication (Email & Password) lalu ambil data pribadi dari DB
  Future<UserModel> loginWithSupabase(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    final authRes = await _supabase.auth.signInWithPassword(
      email: cleanEmail,
      password: password,
    );

    final authUser = authRes.user;
    if (authUser == null) {
      throw Exception('Login gagal: User tidak ditemukan.');
    }

    // Ambil informasi pribadi dari tabel profiles
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profile != null) {
      return UserModel(
        idUser: authUser.id,
        nama: profile['nama'] ?? cleanEmail.split('@').first,
        email: profile['email'] ?? authUser.email ?? cleanEmail,
        noHp: profile['no_hp'] ?? '-',
        role: UserRole.values.firstWhere(
          (e) => e.name == (profile['role'] ?? 'pelanggan'),
          orElse: () => UserRole.pelanggan,
        ),
        alamat: profile['alamat'],
        idGerobak: profile['id_gerobak'],
      );
    }

    // Jika akun dibuat langsung dari dashboard Auth Supabase dan belum ada baris di tabel profiles
    final defaultNama = authUser.userMetadata?['nama'] ?? cleanEmail.split('@').first;
    await _supabase.from('profiles').upsert({
      'id': authUser.id,
      'email': authUser.email ?? cleanEmail,
      'nama': defaultNama,
      'role': 'pelanggan',
    });

    return UserModel(
      idUser: authUser.id,
      nama: defaultNama,
      email: authUser.email ?? cleanEmail,
      noHp: '-',
      role: UserRole.pelanggan,
    );
  }

  /// 2. Daftar akun ke Supabase Authentication (Email & Password), lalu simpan data pribadi ke DB
  Future<UserModel?> registerWithSupabase({
    required String email,
    required String password,
    required String nama,
    required String noHp,
    required String alamat,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Tahap A: Daftarkan email & password ke Supabase Authentication
    final authRes = await _supabase.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        'nama': nama.trim(),
        'no_hp': noHp.trim(),
        'alamat': alamat.trim(),
      },
    );

    final authUser = authRes.user;
    if (authUser == null) {
      throw Exception('Pendaftaran akun di Supabase Authentication gagal.');
    }

    // Tahap B: Masukkan informasi pribadi ke tabel database (profiles)
    await _supabase.from('profiles').upsert({
      'id': authUser.id,
      'email': cleanEmail,
      'nama': nama.trim(),
      'no_hp': noHp.trim(),
      'alamat': alamat.trim(),
      'role': 'pelanggan',
    });

    // Jika Confirm Email di Supabase masih aktif, session bernilai null
    if (authRes.session == null) {
      return null;
    }

    return UserModel(
      idUser: authUser.id,
      nama: nama.trim(),
      email: cleanEmail,
      noHp: noHp.trim(),
      role: UserRole.pelanggan,
      alamat: alamat.trim(),
    );
  }

  /// Login cepat khusus tombol pengujian statis
  UserModel? loginDemo(String email) {
    try {
      return _demoUsers.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }

  List<GerobakModel> getAllGerobak() => List.unmodifiable(_gerobakList);
  List<MenuModel> getAllMasterMenu() => List.unmodifiable(_masterMenuList);
  List<PesananModel> getAllPesanan() => List.unmodifiable(_pesananList);

  List<MenuGerobakItem> getMenuByGerobak(String idGerobak) {
    final stokGerobak = _stokList.where((s) => s.idGerobak == idGerobak);
    return stokGerobak.map((stok) {
      final menu = _masterMenuList.firstWhere((m) => m.idMenu == stok.idMenu);
      return MenuGerobakItem(menu: menu, stok: stok);
    }).toList();
  }

  void toggleStatusGerobak(String idGerobak, bool statusBuka) {
    final idx = _gerobakList.indexWhere((g) => g.idGerobak == idGerobak);
    if (idx != -1) _gerobakList[idx].statusBuka = statusBuka;
  }

  void updateStokMenu(String idGerobak, String idMenu, int jumlahBaru) {
    final idx = _stokList.indexWhere(
      (s) => s.idGerobak == idGerobak && s.idMenu == idMenu,
    );
    if (idx != -1) _stokList[idx].jumlahStok = jumlahBaru < 0 ? 0 : jumlahBaru;
  }

  void tambahGerobak(GerobakModel gerobak) {
    _gerobakList.add(gerobak);
    for (var menu in _masterMenuList) {
      _stokList.add(StokMenuModel(
        idStok: 'STK-${DateTime.now().microsecondsSinceEpoch}',
        idGerobak: gerobak.idGerobak,
        idMenu: menu.idMenu,
        jumlahStok: 10,
      ));
    }
  }

  void tambahMasterMenu(MenuModel menu) {
    _masterMenuList.add(menu);
    for (var gerobak in _gerobakList) {
      _stokList.add(StokMenuModel(
        idStok: 'STK-${DateTime.now().microsecondsSinceEpoch}',
        idGerobak: gerobak.idGerobak,
        idMenu: menu.idMenu,
        jumlahStok: 10,
      ));
    }
  }

  PesananModel buatPesanan({
    required UserModel pelanggan,
    required GerobakModel gerobak,
    required List<DetailPesananModel> items,
    required String metodeAmbil,
    required String catatan,
    double diskonPromo = 0,
  }) {
    if (!gerobak.statusBuka) throw Exception('Gerobak sedang tutup');

    final total = items.fold<double>(0, (sum, e) => sum + e.subtotal);
    final pesanan = PesananModel(
      idPesanan: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      idPelanggan: pelanggan.idUser,
      namaPelanggan: pelanggan.nama,
      idGerobak: gerobak.idGerobak,
      namaGerobak: gerobak.namaGerobak,
      tanggalPesanan: DateTime.now(),
      items: items,
      totalHarga: total,
      diskonPromo: diskonPromo,
      status: StatusPesanan.dibuat,
      metodeAmbil: metodeAmbil,
      catatan: catatan,
    );

    _pesananList.insert(0, pesanan);
    return pesanan;
  }

  void prosesPembayaran(String idPesanan, String metodeBayar) {
    final idx = _pesananList.indexWhere((p) => p.idPesanan == idPesanan);
    if (idx == -1) return;

    final pesanan = _pesananList[idx];
    for (var item in pesanan.items) {
      final stokIdx = _stokList.indexWhere(
        (s) => s.idGerobak == pesanan.idGerobak && s.idMenu == item.menu.idMenu,
      );
      if (stokIdx != -1) {
        _stokList[stokIdx].jumlahStok =
            (_stokList[stokIdx].jumlahStok - item.jumlah).clamp(0, 999);
      }
    }

    pesanan.pembayaran = PembayaranModel(
      idPembayaran: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      metode: metodeBayar,
      jumlah: pesanan.grandTotal,
      statusBayar: 'Berhasil',
      waktuBayar: DateTime.now(),
    );
    pesanan.status = StatusPesanan.dibayar;
  }

  void updateStatusPesanan(String idPesanan, StatusPesanan statusBaru) {
    final idx = _pesananList.indexWhere((p) => p.idPesanan == idPesanan);
    if (idx != -1) _pesananList[idx].status = statusBaru;
  }
}
