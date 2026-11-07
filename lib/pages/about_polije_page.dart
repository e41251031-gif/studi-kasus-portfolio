import 'package:flutter/material.dart';

import '../app_state.dart';
import '../db/database_helper.dart';
import '../models/portfolio.dart';

/// Sumber informasi: situs resmi POLIJE (https://www.polije.ac.id).
/// Periksa kembali dan perbarui isinya sebelum dikumpulkan.
class AboutPolijePage extends StatefulWidget {
  const AboutPolijePage({super.key});

  @override
  State<AboutPolijePage> createState() => _AboutPolijePageState();
}

class _AboutPolijePageState extends State<AboutPolijePage> {
  static const _departments = <String, String>{
    'Produksi Pertanian': 'Bidang produksi tanaman pangan, hortikultura, dan perkebunan.',
    'Teknologi Pertanian': 'Bidang teknologi dan rekayasa untuk pertanian dan pengolahan hasil pertanian.',
    'Peternakan': 'Bidang produksi dan pengelolaan peternakan.',
    'Manajemen Agribisnis': 'Bidang manajemen dan bisnis di sektor agribisnis.',
    'Teknologi Informasi': 'Bidang pengembangan perangkat lunak, jaringan, dan teknologi informasi.',
    'Bahasa, Komunikasi & Pariwisata': 'Bidang bahasa, komunikasi, dan pariwisata.',
    'Kesehatan': 'Bidang pendidikan vokasi kesehatan.',
    'Teknik': 'Bidang teknik terapan.',
    'Bisnis': 'Bidang bisnis dan manajemen terapan.',
  };

  static const _highlights = [
    (Icons.build, 'Teaching Factory', 'Pembelajaran berbasis praktik dengan model teaching factory untuk mendukung inovasi dan kewirausahaan.'),
    (Icons.emoji_events, 'Prestasi Mahasiswa', 'Mahasiswa meraih prestasi di kompetisi agribisnis nasional dan pendanaan PKM serta P2MW.'),
    (Icons.account_balance, 'Status Kampus', 'Berstatus PTN Badan Layanan Umum sejak 2022 dan ditunjuk sebagai calon PTN Badan Hukum pada 2023.'),
    (Icons.location_city, 'Kampus Cabang', 'Memiliki kampus di Bondowoso, Nganjuk, Sidoarjo, Ngawi, dan Sabu Raijua (NTT).'),
  ];

  String _selectedDept = 'Teknologi Informasi';
  final PageController _pager = PageController(viewportFraction: 0.9);
  int _page = 0;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    AppState.dataVersion.addListener(_loadProfile);
  }

  @override
  void dispose() {
    _pager.dispose();
    AppState.dataVersion.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await DatabaseHelper.instance.getProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {
      // Profil gagal dimuat: kartu program studi tetap menampilkan "...".
    }
  }

  Widget _section(String title, IconData icon) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Icon(icon, color: kPrimary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: kHeaderGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: const Column(
            children: [
              Icon(Icons.school, color: Colors.white, size: 52),
              SizedBox(height: 8),
              Text(
                'Politeknik Negeri Jember',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text('Pendidikan Vokasi · 60% Praktik, 40% Teori', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),

        _section('Profil POLIJE', Icons.info),
        const Card(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              ListTile(leading: Icon(Icons.badge), title: Text('Nama'), subtitle: Text('Politeknik Negeri Jember (POLIJE)')),
              ListTile(leading: Icon(Icons.place), title: Text('Lokasi'), subtitle: Text('Jl. Mastrip PO BOX 164, Jember, Jawa Timur')),
              ListTile(leading: Icon(Icons.menu_book), title: Text('Karakteristik'), subtitle: Text('Pendidikan vokasi dengan porsi praktik 60% dan teori 40%, menerapkan model teaching factory.')),
              ListTile(leading: Icon(Icons.workspace_premium), title: Text('Jenjang'), subtitle: Text('Diploma Tiga, Sarjana Terapan, dan Magister Terapan.')),
              ListTile(leading: Icon(Icons.apartment), title: Text('Cakupan'), subtitle: Text('9 jurusan dengan 38 program studi.')),
              ListTile(leading: Icon(Icons.mail), title: Text('Kontak'), subtitle: Text('politeknik@polije.ac.id · +62 331 333533')),
            ],
          ),
        ),

        _section('Jurusan / Program Studi', Icons.account_tree),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDept,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Pilih jurusan',
                  prefixIcon: Icon(Icons.list),
                  border: OutlineInputBorder(),
                ),
                items: _departments.keys
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDept = v!),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text('Jurusan $_selectedDept'),
                  subtitle: Text(
                    '${_departments[_selectedDept]}\n'
                    'Daftar program studi lengkap ada di polije.ac.id.',
                  ),
                  isThreeLine: true,
                ),
              ),
            ],
          ),
        ),

        _section('Program Studi Saya', Icons.person_pin),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.badge),
            title: Text(profile?.studyProgram ?? '...'),
            subtitle: Text(
              'Jurusan ${profile?.department ?? '...'}\n'
              'Ubah lewat menu Profil Saya.',
            ),
            isThreeLine: true,
          ),
        ),

        _section('Fasilitas & Kegiatan Kampus', Icons.stars),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pager,
            itemCount: _highlights.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final h = _highlights[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: kHeaderGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(h.$1, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(h.$2, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(h.$3, style: const TextStyle(color: Colors.white70), overflow: TextOverflow.fade),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _highlights.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.all(4),
              width: _page == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? kPrimary : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Sumber: www.polije.ac.id',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
