import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _deleteAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua karya?'),
        content: const Text('Seluruh data portofolio akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus Semua')),
        ],
      ),
    );
    if (ok != true) return;
    final items = await DatabaseHelper.instance.getPortfolios();
    for (final p in items) {
      await DatabaseHelper.instance.deletePortfolio(p.id!);
    }
    AppState.notifyDataChanged();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua karya dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: AppState.themeMode,
          builder: (_, mode, __) => SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Mode gelap'),
            subtitle: const Text('Tersimpan walau aplikasi ditutup'),
            value: mode == ThemeMode.dark,
            onChanged: AppState.setDarkMode,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          title: const Text('Hapus semua karya'),
          subtitle: const Text('Mengosongkan tabel portofolio'),
          onTap: () => _deleteAll(context),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('POLIJE Student Portfolio'),
          subtitle: Text('Versi 1.0.0 · Flutter + SQLite'),
        ),
      ],
    );
  }
}
