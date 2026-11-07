# POLIJE Student Portfolio

Aplikasi portofolio mahasiswa (Flutter + SQLite): CRUD karya, profil, halaman Tentang POLIJE, mode gelap.

## Menjalankan di Chrome
```
flutter pub get
flutter run -d chrome
```
File `web/sqlite3.wasm` sudah disertakan (diperlukan SQLite di web).

## Menjalankan di Android / Windows
Folder platform belum disertakan. Jalankan sekali:
```
flutter create .
flutter pub get
flutter run -d <id-perangkat>
```
(`flutter create .` tidak menimpa `lib/`, `pubspec.yaml`, atau `web/`.)
