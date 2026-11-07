import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';
import '../models/portfolio.dart';

/// Form Tambah (existing == null) atau Edit (existing != null).
class PortfolioFormPage extends StatefulWidget {
  final Portfolio? existing;
  final VoidCallback onSaved;

  const PortfolioFormPage({super.key, this.existing, required this.onSaved});

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _image;
  late final TextEditingController _link;
  late final TextEditingController _year;
  late String _category;
  late String _technology;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _image = TextEditingController(text: e?.imageUrl ?? '');
    _link = TextEditingController(text: e?.projectUrl ?? '');
    _year = TextEditingController(text: (e?.year ?? DateTime.now().year).toString());
    _category = e?.category ?? kCategories.first;
    _technology = e?.technology ?? kTechnologies.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _image.dispose();
    _link.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = Portfolio(
      id: widget.existing?.id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      technology: _technology,
      imageUrl: _image.text.trim(),
      projectUrl: _link.text.trim(),
      year: int.parse(_year.text.trim()),
    );
    try {
      if (_isEdit) {
        await DatabaseHelper.instance.updatePortfolio(item);
      } else {
        await DatabaseHelper.instance.insertPortfolio(item);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    AppState.notifyDataChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Karya diperbarui' : 'Karya ditambahkan')),
    );
    if (!_isEdit) {
      _formKey.currentState!.reset();
      _title.clear();
      _desc.clear();
      _image.clear();
      _link.clear();
      _year.text = DateTime.now().year.toString();
    }
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Judul karya',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            items: kCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _technology,
            decoration: const InputDecoration(
              labelText: 'Teknologi',
              prefixIcon: Icon(Icons.code),
              border: OutlineInputBorder(),
            ),
            items: kTechnologies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _technology = v!),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _year,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tahun',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final y = int.tryParse((v ?? '').trim());
              if (y == null) return 'Tahun harus berupa angka';
              if (y < 2000 || y > DateTime.now().year + 1) {
                return 'Tahun tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _image,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL gambar (opsional)',
              prefixIcon: Icon(Icons.image),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return null;
              return s.startsWith('http') ? null : 'URL harus diawali http/https';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Link proyek (opsional)',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Karya'),
          ),
        ],
      ),
    );
  }
}
