import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';
import '../models/portfolio.dart';
import 'portfolio_card.dart';
import 'portfolio_form_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  String _filter = 'Semua';
  List<Portfolio> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    AppState.dataVersion.addListener(_load);
  }

  @override
  void dispose() {
    AppState.dataVersion.removeListener(_load);
    super.dispose();
  }

  String? _error;

  Future<void> _load() async {
    try {
      final list =
          await DatabaseHelper.instance.getPortfolios(category: _filter);
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _confirmDelete(Portfolio p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus karya?'),
        content: Text('"${p.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseHelper.instance.deletePortfolio(p.id!);
    AppState.notifyDataChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Karya berhasil dihapus')),
    );
  }

  Future<void> _edit(Portfolio p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Portofolio'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: kHeaderGradient),
            ),
            foregroundColor: Colors.white,
          ),
          body: Builder(
            builder: (ctx) => PortfolioFormPage(
              existing: p,
              onSaved: () => Navigator.pop(ctx),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Semua', ...kCategories];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: _filter,
            decoration: const InputDecoration(
              labelText: 'Filter kategori',
              prefixIcon: Icon(Icons.filter_list),
              border: OutlineInputBorder(),
            ),
            items: filters
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              setState(() => _filter = v ?? 'Semua');
              _load();
            },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Colors.redAccent),
                        const SizedBox(height: 8),
                        Text('Gagal memuat data:\n$_error',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            setState(() => _loading = true);
                            _load();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? const Center(child: Text('Belum ada karya pada kategori ini'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final p = _items[i];
                          return PortfolioCard(
                            item: p,
                            onTap: () => showPortfolioDetail(context, p),
                            onEdit: () => _edit(p),
                            onDelete: () => _confirmDelete(p),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
