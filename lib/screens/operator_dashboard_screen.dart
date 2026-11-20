import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/pesanan_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_formatter.dart';

class OperatorDashboardScreen extends StatelessWidget {
  const OperatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final gerobak = provider.daftarGerobak.firstWhere((g) => g.idGerobak == 'GRB-01');
    final menuGerobak = provider.getMenuUntukOperator('GRB-01');
    final pesananMasuk = provider.semuaPesanan.where((p) => p.idGerobak == 'GRB-01').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Operator: ${gerobak.namaGerobak}'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout()),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pesanan Masuk'),
              Tab(text: 'Stok & Gerobak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesananMasuk.length,
              itemBuilder: (_, idx) {
                final p = pesananMasuk[idx];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.idPesanan} - ${p.namaPelanggan}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Status: ${p.status.label}'),
                        Text('Total: ${CurrencyFormatter.formatRupiah(p.grandTotal)}'),
                        const SizedBox(height: 8),
                        if (p.status == StatusPesanan.dibayar)
                          ElevatedButton(
                            onPressed: () => provider.updateStatusPesanan(p.idPesanan, StatusPesanan.diproses),
                            child: const Text('Proses Pesanan'),
                          ),
                        if (p.status == StatusPesanan.diproses)
                          ElevatedButton(
                            onPressed: () => provider.updateStatusPesanan(p.idPesanan, StatusPesanan.siapDiambilDiantar),
                            child: const Text('Tandai Siap Diambil'),
                          ),
                        if (p.status == StatusPesanan.siapDiambilDiantar)
                          ElevatedButton(
                            onPressed: () => provider.updateStatusPesanan(p.idPesanan, StatusPesanan.selesai),
                            child: const Text('Selesaikan Pesanan'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Status Buka / Tutup Gerobak'),
                  value: gerobak.statusBuka,
                  onChanged: (v) => provider.toggleStatusGerobak('GRB-01', v),
                ),
                const Divider(),
                const Text('Kelola Stok Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                ...menuGerobak.map((item) => Card(
                  child: ListTile(
                    title: Text(item.menu.namaMenu),
                    subtitle: Text('Stok: ${item.stok.jumlahStok}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => provider.updateStokGerobak('GRB-01', item.menu.idMenu, item.stok.jumlahStok - 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => provider.updateStokGerobak('GRB-01', item.menu.idMenu, item.stok.jumlahStok + 1),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
