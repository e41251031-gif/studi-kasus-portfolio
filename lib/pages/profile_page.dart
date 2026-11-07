import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';
import '../models/portfolio.dart';
import 'profile_photo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? _profile;
  int _count = 0;

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
      final p = await DatabaseHelper.instance.getProfile();
      final list = await DatabaseHelper.instance.getPortfolios();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _count = list.length;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _edit() async {
    final p = _profile!;
    final name = TextEditingController(text: p.name);
    final nim = TextEditingController(text: p.nim);
    final prodi = TextEditingController(text: p.studyProgram);
    final dept = TextEditingController(text: p.department);
    final email = TextEditingController(text: p.email);
    final bio = TextEditingController(text: p.bio);
    final skills = TextEditingController(text: p.skills);
    final formKey = GlobalKey<FormState>();

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nama'), validator: required),
                TextFormField(controller: nim, decoration: const InputDecoration(labelText: 'NIM'), validator: required),
                TextFormField(controller: prodi, decoration: const InputDecoration(labelText: 'Program Studi'), validator: required),
                TextFormField(controller: dept, decoration: const InputDecoration(labelText: 'Jurusan'), validator: required),
                TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email'), validator: required),
                TextFormField(controller: bio, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio'), validator: required),
                TextFormField(controller: skills, decoration: const InputDecoration(labelText: 'Skill (pisahkan koma)'), validator: required),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await DatabaseHelper.instance.saveProfile(Profile(
        name: name.text.trim(),
        nim: nim.text.trim(),
        studyProgram: prodi.text.trim(),
        department: dept.text.trim(),
        email: email.text.trim(),
        bio: bio.text.trim(),
        skills: skills.text.trim(),
      ));
      AppState.notifyDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    if (_error != null && p == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
              const SizedBox(height: 8),
              Text('Gagal memuat profil:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    if (p == null) return const Center(child: CircularProgressIndicator());
    final skillList = p.skills
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: const BoxDecoration(
            gradient: kHeaderGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const ProfilePhoto(radius: 46),
              const SizedBox(height: 12),
              Text(
                p.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(p.nim, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                '$_count karya',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.school), title: const Text('Program Studi'), subtitle: Text(p.studyProgram)),
              ListTile(leading: const Icon(Icons.apartment), title: const Text('Jurusan'), subtitle: Text(p.department)),
              ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(p.email)),
              ListTile(leading: const Icon(Icons.info), title: const Text('Tentang Saya'), subtitle: Text(p.bio)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [for (final s in skillList) Chip(label: Text(s))],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
          ),
        ),
      ],
    );
  }
}
