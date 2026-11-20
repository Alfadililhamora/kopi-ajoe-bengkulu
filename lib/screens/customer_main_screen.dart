import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/gerobak_model.dart';
import '../models/menu_model.dart';
import '../models/pesanan_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_formatter.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;
  final _promoController = TextEditingController();
  final _catatanController = TextEditingController();
  String _metodeAmbil = 'Ambil di Gerobak';
  String _metodeBayar = 'QRIS';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pages = [
      _buildHome(provider),
      _buildMenu(provider),
      _buildGerobak(provider),
      _buildCart(provider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('KOPI AJOE BENGKULU', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(provider.selectedGerobak?.namaGerobak ?? 'Pilih gerobak', style: const TextStyle(fontSize: 11, color: Colors.amberAccent)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => _showTracking(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => provider.logout(),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.local_cafe), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Gerobak'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }

  Widget _buildHome(AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.coffeeBrown]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROMO MINGGU INI', style: TextStyle(color: AppTheme.accentTerracotta, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Ngopi Hemat di Seluruh Gerobak Bengkulu!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Gunakan kode AJOEBENGKULU saat checkout untuk diskon Rp 3.000.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pilih Gerobak Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...provider.daftarGerobak.map((g) => Card(
          child: ListTile(
            leading: const Icon(Icons.storefront, color: AppTheme.coffeeBrown),
            title: Text(g.namaGerobak, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(g.statusBuka ? 'Buka' : 'Tutup (Tidak bisa pesan)'),
            trailing: ElevatedButton(
              onPressed: () {
                final err = provider.pilihGerobak(g);
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                } else {
                  setState(() => _selectedIndex = 1);
                }
              },
              child: const Text('Pilih'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMenu(AppProvider provider) {
    if (provider.selectedGerobak == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedIndex = 2),
          child: const Text('Pilih Gerobak Terlebih Dahulu'),
        ),
      );
    }

    final items = provider.menuGerobakTerpilih;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, idx) {
        final item = items[idx];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              title: Text(item.menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item.menu.deskripsi}\nStok: ${item.stok.jumlahStok}'),
              isThreeLine: true,
              trailing: SizedBox(
                width: 90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatRupiah(item.menu.harga),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.add_circle, color: AppTheme.coffeeBrown, size: 22),
                        onPressed: () {
                          final err = provider.tambahKeKeranjang(item);
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGerobak(AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Lokasi Gerobak Kopi Ajoe Bengkulu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...provider.daftarGerobak.map((GerobakModel g) => Card(
          child: ListTile(
            title: Text(g.namaGerobak, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${g.alamatLokasi}\n${g.jamOperasional}'),
            isThreeLine: true,
            trailing: Text(g.statusBuka ? 'BUKA' : 'TUTUP', style: TextStyle(fontWeight: FontWeight.bold, color: g.statusBuka ? Colors.green : Colors.red)),
          ),
        )),
      ],
    );
  }

  Widget _buildCart(AppProvider provider) {
    if (provider.cart.isEmpty) {
      return const Center(child: Text('Keranjang masih kosong'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...provider.cart.map((item) => Card(
          child: ListTile(
            title: Text(item.menu.namaMenu),
            subtitle: Text('${item.jumlah}x • ${CurrencyFormatter.formatRupiah(item.subtotal)}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => provider.kurangiItemKeranjang(item.menu.idMenu),
            ),
          ),
        )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                decoration: const InputDecoration(hintText: 'Kode Promo (AJOEBENGKULU)'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final msg = provider.terapkanKodePromo(_promoController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
              child: const Text('Pakai'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _metodeAmbil,
          decoration: const InputDecoration(labelText: 'Metode Pengambilan'),
          items: ['Ambil di Gerobak', 'Antar Kurir'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _metodeAmbil = v!),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _metodeBayar,
          decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
          items: ['QRIS', 'Tunai di Gerobak'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _metodeBayar = v!),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _catatanController,
          decoration: const InputDecoration(labelText: 'Catatan (Cth: Es sedikit)'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            try {
              final order = provider.checkoutDanBayar(
                metodeAmbil: _metodeAmbil,
                metodeBayar: _metodeBayar,
                catatan: _catatanController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pesanan ${order.idPesanan} berhasil dibayar!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: const Text('CHECKOUT & BAYAR SEKARANG'),
        ),
      ],
    );
  }

  void _showTracking(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Consumer<AppProvider>(
          builder: (_, provider, __) {
            final orders = provider.semuaPesanan.where((p) => p.idPelanggan == provider.currentUser?.idUser).toList();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, idx) {
                final o = orders[idx];
                return Card(
                  child: ListTile(
                    title: Text('${o.idPesanan} - ${o.namaGerobak}'),
                    subtitle: Text('Status: ${o.status.label}\nTotal: ${CurrencyFormatter.formatRupiah(o.grandTotal)}'),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
