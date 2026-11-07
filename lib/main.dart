import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app_state.dart';
import 'pages/about_polije_page.dart';
import 'pages/home_page.dart';
import 'pages/portfolio_form_page.dart';
import 'pages/portfolio_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Mode tanpa web worker: hanya butuh sqlite3.wasm di folder web/
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await AppState.loadSettings();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'POLIJE Student Portfolio',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimary,
            brightness: Brightness.dark,
          ),
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    'Beranda',
    'Portofolio',
    'Tambah Portofolio',
    'Tentang POLIJE',
    'Profil Saya',
    'Pengaturan',
  ];

  void goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onNavigate: goTo),
      const PortfolioPage(),
      PortfolioFormPage(onSaved: () => goTo(1)),
      const AboutPolijePage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kHeaderGradient),
        ),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(gradient: kHeaderGradient),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'POLIJE Student\nPortfolio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (final item in const [
              (Icons.home, 'Beranda', 0),
              (Icons.collections_bookmark, 'Portofolio / Karya', 1),
              (Icons.add_box, 'Tambah Portofolio', 2),
              (Icons.school, 'Tentang POLIJE', 3),
              (Icons.person, 'Profil Saya', 4),
              (Icons.settings, 'Pengaturan', 5),
            ])
              ListTile(
                leading: Icon(item.$1),
                title: Text(item.$2),
                selected: _index == item.$3,
                onTap: () {
                  Navigator.pop(context);
                  goTo(item.$3);
                },
              ),
          ],
        ),
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        // Tab bawah: 5 menu utama. Pengaturan ada di Drawer / tombol di Beranda.
        selectedIndex: _index > 4 ? 0 : _index,
        onDestinationSelected: goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.collections_bookmark_outlined), selectedIcon: Icon(Icons.collections_bookmark), label: 'Karya'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'Tambah'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'POLIJE'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
