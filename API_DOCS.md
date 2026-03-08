# Dokumentasi REST API
## Sistem Informasi SD Negeri Warialau
**Oleh:** Bredcly Fransiscus Tuhuleruw (12155201220021)
**Institusi:** Universitas Kristen Indonesia Maluku (UKIM) Ambon — 2026
**Framework:** Laravel 12 + Laravel Sanctum
**Total Endpoint:** 19 endpoint

---

## Informasi Umum

| Item | Detail |
|------|--------|
| **Base URL** | `http://127.0.0.1:8000/api/v1` |
| **Format Request** | `application/json` |
| **Format Response** | `application/json` |
| **Autentikasi** | Bearer Token (Laravel Sanctum) |

### Header Wajib (semua request)
```
Accept: application/json
Content-Type: application/json
```

### Header Tambahan (endpoint yang butuh login)
```
Authorization: Bearer {token}
```

### Format Response Error Umum
```json
{ "message": "Pesan error" }
```

### Format Response Validasi Gagal (422)
```json
{
  "message": "The name field is required.",
  "errors": {
    "name": ["The name field is required."]
  }
}
```

---

## A. Autentikasi

### 1. Register
Mendaftarkan akun baru sebagai orang tua/wali murid.

```
POST /api/v1/auth/register
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `name` | string | Ya | Nama lengkap (maks. 100 karakter) |
| `email` | string | Ya | Alamat email valid dan unik |
| `password` | string | Ya | Kata sandi minimal 8 karakter |
| `password_confirmation` | string | Ya | Harus sama dengan `password` |
| `no_hp` | string | Tidak | Nomor handphone |

**Contoh Request:**
```json
{
  "name": "Maria Wattimena",
  "email": "maria@gmail.com",
  "password": "password123",
  "password_confirmation": "password123",
  "no_hp": "081234567890"
}
```

**Response Sukses (201):**
```json
{
  "message": "Registrasi berhasil.",
  "user": {
    "id": 1,
    "name": "Maria Wattimena",
    "email": "maria@gmail.com",
    "no_hp": "081234567890",
    "role": "orangtua",
    "created_at": "2026-03-08T10:00:00.000000Z",
    "updated_at": "2026-03-08T10:00:00.000000Z"
  },
  "token": "1|abcdefghijklmnopqrstuvwxyz123456"
}
```

**Response Gagal (422):**
```json
{
  "message": "The email has already been taken.",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

---

### 2. Login
Masuk ke akun yang sudah terdaftar.

```
POST /api/v1/auth/login
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `email` | string | Ya | Alamat email terdaftar |
| `password` | string | Ya | Kata sandi akun |

**Contoh Request:**
```json
{
  "email": "maria@gmail.com",
  "password": "password123"
}
```

**Response Sukses (200):**
```json
{
  "message": "Login berhasil.",
  "user": {
    "id": 1,
    "name": "Maria Wattimena",
    "email": "maria@gmail.com",
    "no_hp": "081234567890",
    "role": "orangtua",
    "created_at": "2026-03-08T10:00:00.000000Z",
    "updated_at": "2026-03-08T10:00:00.000000Z"
  },
  "token": "1|abcdefghijklmnopqrstuvwxyz123456"
}
```

**Response Gagal (401):**
```json
{
  "message": "Email atau kata sandi salah."
}
```

> **Catatan Flutter:** Simpan `token` di SharedPreferences/SecureStorage untuk digunakan pada setiap request selanjutnya.

---

### 3. Logout
Keluar dari sesi aktif dan menghapus token.

```
POST /api/v1/auth/logout
```

**Header:** `Authorization: Bearer {token}` *(wajib)*

**Body Request:** *(kosong)*

**Response Sukses (200):**
```json
{
  "message": "Logout berhasil."
}
```

**Response Gagal (401):**
```json
{
  "message": "Unauthenticated."
}
```

---

### 4. Lupa Password — Kirim OTP
Mengirimkan kode OTP 6 digit ke email pengguna.

```
POST /api/v1/auth/forgot-password
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `email` | string | Ya | Email yang terdaftar di sistem |

**Contoh Request:**
```json
{
  "email": "maria@gmail.com"
}
```

**Response Sukses (200):**
```json
{
  "message": "Kode OTP telah dikirim ke email Anda."
}
```

**Response Gagal — Email tidak ditemukan (404):**
```json
{
  "message": "Email tidak terdaftar."
}
```

> **Catatan Flutter:** Setelah sukses, arahkan user ke halaman input OTP. OTP berlaku **10 menit**.

---

### 5. Lupa Password — Verifikasi OTP
Memverifikasi kode OTP yang dikirim ke email.

```
POST /api/v1/auth/verify-otp
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `email` | string | Ya | Email yang digunakan saat kirim OTP |
| `otp` | string | Ya | Kode OTP 6 digit |

**Contoh Request:**
```json
{
  "email": "maria@gmail.com",
  "otp": "483921"
}
```

**Response Sukses (200):**
```json
{
  "message": "OTP valid. Silakan buat kata sandi baru.",
  "reset_email": "maria@gmail.com"
}
```

**Response Gagal (422):**
```json
{
  "message": "Kode OTP tidak valid atau sudah kedaluwarsa."
}
```

> **Catatan Flutter:** Simpan `reset_email` dari response untuk dikirim pada langkah reset password.

---

### 6. Lupa Password — Reset Kata Sandi
Mengubah kata sandi setelah OTP berhasil diverifikasi.

```
POST /api/v1/auth/reset-password
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `email` | string | Ya | Email yang sudah diverifikasi OTP |
| `password` | string | Ya | Kata sandi baru minimal 8 karakter |
| `password_confirmation` | string | Ya | Harus sama dengan `password` |

**Contoh Request:**
```json
{
  "email": "maria@gmail.com",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response Sukses (200):**
```json
{
  "message": "Kata sandi berhasil diperbarui."
}
```

**Response Gagal (404):**
```json
{
  "message": "Email tidak ditemukan."
}
```

---

## B. Profil Pengguna
*Semua endpoint ini membutuhkan header `Authorization: Bearer {token}`*

### 7. Lihat Profil
Mengambil data profil pengguna yang sedang login.

```
GET /api/v1/profile
```

**Response Sukses (200):**
```json
{
  "id": 1,
  "name": "Maria Wattimena",
  "email": "maria@gmail.com",
  "no_hp": "081234567890",
  "role": "orangtua",
  "created_at": "2026-03-08T10:00:00.000000Z",
  "updated_at": "2026-03-08T10:00:00.000000Z"
}
```

---

### 8. Update Informasi Akun
Mengubah nama, email, dan nomor HP pengguna.

```
PATCH /api/v1/profile/info
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `name` | string | Ya | Nama lengkap baru |
| `email` | string | Ya | Email baru (harus unik) |
| `no_hp` | string | Tidak | Nomor HP baru |

**Contoh Request:**
```json
{
  "name": "Maria Wattimena S.Pd",
  "email": "maria.baru@gmail.com",
  "no_hp": "089876543210"
}
```

**Response Sukses (200):**
```json
{
  "message": "Informasi akun berhasil diperbarui.",
  "user": {
    "id": 1,
    "name": "Maria Wattimena S.Pd",
    "email": "maria.baru@gmail.com",
    "no_hp": "089876543210",
    "role": "orangtua",
    "updated_at": "2026-03-08T11:00:00.000000Z"
  }
}
```

---

### 9. Update Kata Sandi
Mengubah kata sandi pengguna yang sedang login.

```
PATCH /api/v1/profile/password
```

**Body Request:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `current_password` | string | Ya | Kata sandi saat ini |
| `password` | string | Ya | Kata sandi baru minimal 8 karakter |
| `password_confirmation` | string | Ya | Harus sama dengan `password` |

**Contoh Request:**
```json
{
  "current_password": "password123",
  "password": "newpassword456",
  "password_confirmation": "newpassword456"
}
```

**Response Sukses (200):**
```json
{
  "message": "Kata sandi berhasil diperbarui."
}
```

**Response Gagal — Sandi Lama Salah (422):**
```json
{
  "message": "Kata sandi saat ini tidak sesuai."
}
```

---

## C. Konten Publik (Tanpa Login)

### 10. Profil Sekolah
Mengambil data identitas dan profil SD Negeri Warialau.

```
GET /api/v1/profil-sekolah
```

**Response Sukses (200):**
```json
{
  "id": 1,
  "nama_sekolah": "SD Negeri Warialau",
  "kepala_sekolah": "Yusuf Renuat, S.Pd",
  "akreditasi": "B",
  "tahun_berdiri": "1980",
  "jumlah_ruang_kelas": 6,
  "visi": "Mewujudkan peserta didik yang beriman...",
  "misi": "1. Menyelenggarakan pembelajaran yang aktif...",
  "sejarah": "SD Negeri Warialau berdiri sejak tahun 1980...",
  "alamat": "Kec. Aru Utara, Kab. Kepulauan Aru, Maluku",
  "kontak": "081234567890",
  "logo": null,
  "created_at": "2026-01-01T00:00:00.000000Z",
  "updated_at": "2026-01-01T00:00:00.000000Z"
}
```

---

### 11. Banner / Slider
Mengambil daftar gambar banner untuk halaman utama aplikasi.

```
GET /api/v1/banner
```

**Response Sukses (200):**
```json
[
  {
    "id": 1,
    "judul": "Selamat Datang di SD Negeri Warialau",
    "gambar": "banner/foto1.jpg",
    "urutan": 1,
    "status": "aktif",
    "created_at": "2026-01-01T00:00:00.000000Z",
    "updated_at": "2026-01-01T00:00:00.000000Z"
  },
  {
    "id": 2,
    "judul": "Penerimaan Siswa Baru 2026/2027",
    "gambar": "banner/foto2.jpg",
    "urutan": 2,
    "status": "aktif"
  }
]
```

> **Catatan Flutter:** URL gambar lengkap = `{BASE_URL}/storage/{gambar}`, contoh: `http://127.0.0.1:8000/storage/banner/foto1.jpg`

---

### 12. Daftar Guru
Mengambil semua guru yang berstatus aktif.

```
GET /api/v1/guru
```

**Response Sukses (200):**
```json
[
  {
    "id": 1,
    "nama": "Yusuf Renuat, S.Pd",
    "nip": "196501012000031001",
    "jabatan": "Kepala Sekolah",
    "mata_pelajaran": "Matematika",
    "no_hp": "081234567890",
    "foto": "guru/foto1.jpg",
    "status": "aktif"
  },
  {
    "id": 2,
    "nama": "Maria Letsoin, S.Pd",
    "nip": null,
    "jabatan": "Guru Kelas I",
    "mata_pelajaran": "Bahasa Indonesia",
    "no_hp": null,
    "foto": null,
    "status": "aktif"
  }
]
```

---

### 13. Daftar Berita
Mengambil daftar berita yang sudah dipublikasikan (paginated).

```
GET /api/v1/berita?per_page=10&page=1
```

**Query Parameter:**

| Parameter | Tipe | Default | Keterangan |
|-----------|------|---------|------------|
| `per_page` | integer | 10 | Jumlah berita per halaman |
| `page` | integer | 1 | Halaman yang ingin diambil |

**Response Sukses (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "judul": "Pentas Seni SD Negeri Warialau 2026",
      "isi": "<p>Pada tanggal 15 Maret 2026...</p>",
      "gambar": "berita/foto1.jpg",
      "kategori": "Kegiatan",
      "tanggal_publish": "2026-03-01",
      "status": "publish",
      "created_at": "2026-03-01T08:00:00.000000Z",
      "updated_at": "2026-03-01T08:00:00.000000Z"
    }
  ],
  "first_page_url": "http://127.0.0.1:8000/api/v1/berita?page=1",
  "from": 1,
  "last_page": 4,
  "last_page_url": "http://127.0.0.1:8000/api/v1/berita?page=4",
  "next_page_url": "http://127.0.0.1:8000/api/v1/berita?page=2",
  "per_page": 10,
  "prev_page_url": null,
  "to": 10,
  "total": 40
}
```

---

### 14. Detail Berita
Mengambil isi lengkap satu artikel berita.

```
GET /api/v1/berita/{id}
```

**Path Parameter:**

| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `id` | integer | ID berita |

**Contoh:** `GET /api/v1/berita/1`

**Response Sukses (200):**
```json
{
  "id": 1,
  "user_id": 1,
  "judul": "Pentas Seni SD Negeri Warialau 2026",
  "isi": "<p>Pada tanggal 15 Maret 2026, SD Negeri Warialau mengadakan pentas seni tahunan...</p>",
  "gambar": "berita/foto1.jpg",
  "kategori": "Kegiatan",
  "tanggal_publish": "2026-03-01",
  "status": "publish",
  "created_at": "2026-03-01T08:00:00.000000Z",
  "updated_at": "2026-03-01T08:00:00.000000Z"
}
```

**Response Gagal (404):**
```json
{
  "message": "Berita tidak ditemukan."
}
```

---

### 15. Galeri Foto
Mengambil daftar foto kegiatan sekolah (paginated).

```
GET /api/v1/galeri?per_page=12&page=1
```

**Query Parameter:**

| Parameter | Tipe | Default | Keterangan |
|-----------|------|---------|------------|
| `per_page` | integer | 12 | Jumlah foto per halaman |
| `page` | integer | 1 | Halaman yang ingin diambil |

**Response Sukses (200):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "judul": "Upacara Bendera 17 Agustus",
      "foto": "galeri/foto1.jpg",
      "keterangan": "Pelaksanaan upacara bendera dalam rangka HUT RI ke-81",
      "created_at": "2026-01-10T09:00:00.000000Z",
      "updated_at": "2026-01-10T09:00:00.000000Z"
    }
  ],
  "last_page": 4,
  "next_page_url": "http://127.0.0.1:8000/api/v1/galeri?page=2",
  "per_page": 12,
  "total": 40
}
```

---

## D. Pendaftaran Siswa Baru (PPDB)

### 16. Info Pendaftaran Aktif
Mengambil informasi periode PPDB yang sedang dibuka.

```
GET /api/v1/info-pendaftaran
```

**Response Sukses (200):**
```json
{
  "id": 2,
  "user_id": 1,
  "tahun_ajaran": "2026/2027",
  "tanggal_buka": "2026-01-15",
  "tanggal_tutup": "2026-03-31",
  "kuota": 30,
  "syarat": "1. Berusia 6-7 tahun\n2. Membawa akta kelahiran\n3. Membawa KK",
  "status": "aktif",
  "created_at": "2026-01-01T00:00:00.000000Z",
  "updated_at": "2026-01-01T00:00:00.000000Z"
}
```

**Response Gagal — Pendaftaran Tutup (404):**
```json
{
  "message": "Pendaftaran sedang tidak dibuka."
}
```

---

### 17. Ajukan Pendaftaran
Mengirimkan formulir pendaftaran siswa baru.

```
POST /api/v1/pendaftaran
```

**Header:** `Authorization: Bearer {token}` *(wajib)*

**Body Request:** `multipart/form-data` *(jika ada upload dokumen)*

| Field | Tipe | Wajib | Keterangan |
|-------|------|-------|------------|
| `nama_anak` | string | Ya | Nama lengkap anak |
| `tempat_lahir` | string | Tidak | Tempat lahir anak |
| `tanggal_lahir` | date | Ya | Format: `YYYY-MM-DD` |
| `jenis_kelamin` | string | Ya | `L` atau `P` |
| `agama` | string | Ya | Agama anak |
| `anak_ke` | integer | Tidak | Urutan anak dalam keluarga |
| `asal_sekolah` | string | Tidak | Nama TK/sekolah asal |
| `nik` | string | Tidak | NIK anak (16 digit) |
| `no_kk` | string | Tidak | Nomor Kartu Keluarga |
| `alamat` | string | Ya | Alamat lengkap tempat tinggal |
| `nama_ayah` | string | Tidak | Nama ayah kandung |
| `pekerjaan_ayah` | string | Tidak | Pekerjaan ayah |
| `nama_ibu` | string | Tidak | Nama ibu kandung |
| `pekerjaan_ibu` | string | Tidak | Pekerjaan ibu |
| `nama_wali` | string | Tidak | Nama wali (jika ada) |
| `no_hp` | string | Ya | Nomor HP yang bisa dihubungi |
| `dokumen` | file | Tidak | File PDF/JPG/PNG maks. 2MB |

**Contoh Request (JSON):**
```json
{
  "nama_anak": "Petrus Wattimena",
  "tempat_lahir": "Dobo",
  "tanggal_lahir": "2020-05-10",
  "jenis_kelamin": "L",
  "agama": "Kristen",
  "anak_ke": 1,
  "asal_sekolah": "TK Kasih Ibu",
  "nik": "8103021005200001",
  "no_kk": "8103021005200001",
  "alamat": "Jl. Merdeka No. 5, Dobo, Kab. Kepulauan Aru",
  "nama_ayah": "Yohanes Wattimena",
  "pekerjaan_ayah": "Nelayan",
  "nama_ibu": "Maria Wattimena",
  "pekerjaan_ibu": "Ibu Rumah Tangga",
  "no_hp": "081234567890"
}
```

**Response Sukses (201):**
```json
{
  "message": "Pendaftaran berhasil diajukan.",
  "pendaftaran": {
    "id": 1,
    "user_id": 1,
    "info_pendaftaran_id": 2,
    "nama_anak": "Petrus Wattimena",
    "tanggal_lahir": "2020-05-10",
    "jenis_kelamin": "L",
    "agama": "Kristen",
    "alamat": "Jl. Merdeka No. 5, Dobo, Kab. Kepulauan Aru",
    "no_hp": "081234567890",
    "status": "pending",
    "created_at": "2026-03-08T10:00:00.000000Z",
    "updated_at": "2026-03-08T10:00:00.000000Z"
  }
}
```

**Response Gagal — Pendaftaran Tutup (422):**
```json
{
  "message": "Pendaftaran sedang tidak dibuka."
}
```

---

### 18. Riwayat Pendaftaran
Mengambil semua pendaftaran milik pengguna yang sedang login.

```
GET /api/v1/pendaftaran/riwayat
```

**Header:** `Authorization: Bearer {token}` *(wajib)*

**Response Sukses (200):**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "info_pendaftaran_id": 2,
    "nama_anak": "Petrus Wattimena",
    "tanggal_lahir": "2020-05-10",
    "jenis_kelamin": "L",
    "no_hp": "081234567890",
    "status": "pending",
    "created_at": "2026-03-08T10:00:00.000000Z",
    "updated_at": "2026-03-08T10:00:00.000000Z",
    "info_pendaftaran": {
      "id": 2,
      "tahun_ajaran": "2026/2027",
      "tanggal_buka": "2026-01-15",
      "tanggal_tutup": "2026-03-31",
      "status": "aktif"
    }
  }
]
```

---

### 19. Detail Pendaftaran
Mengambil data lengkap satu pendaftaran milik pengguna.

```
GET /api/v1/pendaftaran/{id}
```

**Header:** `Authorization: Bearer {token}` *(wajib)*

**Path Parameter:**

| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `id` | integer | ID pendaftaran |

**Contoh:** `GET /api/v1/pendaftaran/1`

**Response Sukses (200):**
```json
{
  "id": 1,
  "user_id": 1,
  "info_pendaftaran_id": 2,
  "nama_anak": "Petrus Wattimena",
  "tempat_lahir": "Dobo",
  "tanggal_lahir": "2020-05-10",
  "jenis_kelamin": "L",
  "agama": "Kristen",
  "anak_ke": 1,
  "asal_sekolah": "TK Kasih Ibu",
  "nik": "8103021005200001",
  "no_kk": "8103021005200001",
  "alamat": "Jl. Merdeka No. 5, Dobo, Kab. Kepulauan Aru",
  "nama_ayah": "Yohanes Wattimena",
  "pekerjaan_ayah": "Nelayan",
  "nama_ibu": "Maria Wattimena",
  "pekerjaan_ibu": "Ibu Rumah Tangga",
  "nama_wali": null,
  "no_hp": "081234567890",
  "dokumen": null,
  "status": "pending",
  "created_at": "2026-03-08T10:00:00.000000Z",
  "updated_at": "2026-03-08T10:00:00.000000Z",
  "info_pendaftaran": {
    "id": 2,
    "tahun_ajaran": "2026/2027",
    "tanggal_buka": "2026-01-15",
    "tanggal_tutup": "2026-03-31",
    "kuota": 30,
    "status": "aktif"
  }
}
```

**Response Gagal (404):**
```json
{
  "message": "Data tidak ditemukan."
}
```

---

## Ringkasan Endpoint

| No | Method | Endpoint | Auth | Keterangan |
|----|--------|----------|------|------------|
| 1 | POST | `/auth/register` | - | Daftar akun baru |
| 2 | POST | `/auth/login` | - | Masuk ke akun |
| 3 | POST | `/auth/logout` | Bearer | Keluar dari sesi |
| 4 | POST | `/auth/forgot-password` | - | Kirim OTP ke email |
| 5 | POST | `/auth/verify-otp` | - | Verifikasi kode OTP |
| 6 | POST | `/auth/reset-password` | - | Reset kata sandi baru |
| 7 | GET | `/profile` | Bearer | Lihat profil akun |
| 8 | PATCH | `/profile/info` | Bearer | Update nama/email/no_hp |
| 9 | PATCH | `/profile/password` | Bearer | Ganti kata sandi |
| 10 | GET | `/profil-sekolah` | - | Data profil sekolah |
| 11 | GET | `/banner` | - | Daftar banner slider |
| 12 | GET | `/guru` | - | Daftar guru aktif |
| 13 | GET | `/berita` | - | Daftar berita (paginated) |
| 14 | GET | `/berita/{id}` | - | Detail satu berita |
| 15 | GET | `/galeri` | - | Daftar foto galeri (paginated) |
| 16 | GET | `/info-pendaftaran` | - | Info PPDB aktif |
| 17 | POST | `/pendaftaran` | Bearer | Ajukan pendaftaran |
| 18 | GET | `/pendaftaran/riwayat` | Bearer | Riwayat pendaftaran saya |
| 19 | GET | `/pendaftaran/{id}` | Bearer | Detail satu pendaftaran |

---

## Kode Status HTTP

| Kode | Status | Keterangan |
|------|--------|------------|
| 200 | OK | Request berhasil |
| 201 | Created | Data berhasil dibuat |
| 401 | Unauthorized | Token tidak ada atau tidak valid |
| 404 | Not Found | Data tidak ditemukan |
| 422 | Unprocessable Entity | Validasi gagal |
| 500 | Internal Server Error | Error server |

---

## Catatan Implementasi Flutter

1. **Simpan Token** setelah login/register ke `SharedPreferences` atau `flutter_secure_storage`
2. **URL Gambar** — tambahkan base URL di depan path: `http://127.0.0.1:8000/storage/{path_gambar}`
3. **Pagination** — gunakan field `next_page_url` untuk load more / infinite scroll
4. **Alur Lupa Password:**
   ```
   POST /auth/forgot-password (masukkan email)
        ↓
   POST /auth/verify-otp (masukkan OTP 6 digit)
        ↓ simpan reset_email dari response
   POST /auth/reset-password (masukkan password baru + reset_email)
   ```
5. **Upload Dokumen** — gunakan `multipart/form-data` bukan JSON saat ada file
6. **Interceptor** — tambahkan HTTP interceptor di Flutter untuk otomatis menyisipkan header `Authorization: Bearer {token}` dan `Accept: application/json`
