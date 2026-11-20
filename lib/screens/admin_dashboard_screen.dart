import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/currency_formatter.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalOmzet = provider.semuaPesanan.fold<double>(0, (sum, p) => sum + p.grandTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Pusat Kopi Ajoe'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.brown.shade800,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pendapatan Seluruh Gerobak', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(CurrencyFormatter.formatRupiah(totalOmzet), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Total Transaksi: ${provider.semuaPesanan.length}', style: const TextStyle(color: Colors.amberAccent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Daftar Transaksi Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...provider.semuaPesanan.map((p) => Card(
            child: ListTile(
              title: Text('${p.idPesanan} • ${p.namaGerobak}'),
              subtitle: Text('Pelanggan: ${p.namaPelanggan}\nStatus: ${p.status.label}'),
              trailing: Text(CurrencyFormatter.formatRupiah(p.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
              isThreeLine: true,
            ),
          )),
        ],
      ),
    );
  }
}
