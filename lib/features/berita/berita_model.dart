class BeritaModel {
  final int id;
  final String imageUrl;
  final String category;
  final String title;
  final String date;
  final String readTime;
  final String excerpt;
  final String content;
  final List<String> tags;

  const BeritaModel({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
    required this.readTime,
    required this.excerpt,
    required this.content,
    required this.tags,
  });
}

const dummyBeritaList = <BeritaModel>[
  BeritaModel(
    id: 1,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuARSb7c9Ym9EpfREfMN-1ODkbVoL5CUkb2ikzkOdTj7-v6H4w4xqm4bPbiUQVHN3udnR-W36qsnhdSxYfbpV4CPWhayA7KvQV1UP93BBUMx9YmfZ7NwoAarOvz5jb5YUWgeEXKoAiJUWghwLupe706uwZjREsk_UTA9zU9_hoVCk9naGqeibAVblWuliX64_YQALw2EyHp_gOGmAe6mhRXhzgI_Q6OS3QWIZj7zbA-JtvHJal3OjccvKjA9PoLoxnrCOQMWGf8P7vwa',
    category: 'Kegiatan',
    title: 'Upacara Bendera Memperingati Hari Pendidikan Nasional 2024',
    date: '2 Mei 2024',
    readTime: '4 menit baca',
    excerpt:
        'Seluruh siswa dan guru SD Negeri Warialau mengikuti upacara bendera dalam rangka memperingati Hari Pendidikan Nasional.',
    content:
        'SD Negeri Warialau menggelar upacara bendera yang khidmat dalam rangka memperingati Hari Pendidikan Nasional (Hardiknas) yang jatuh pada tanggal 2 Mei 2024.\n\nSeluruh siswa dari kelas I hingga VI serta para guru dan staf sekolah hadir dengan mengenakan seragam lengkap dan rapi. Kegiatan ini menjadi momen penting untuk mengingatkan kembali makna perjuangan Ki Hajar Dewantara dalam memajukan pendidikan di Indonesia.\n\nDalam amanatnya, kepala sekolah menyampaikan pesan bahwa pendidikan adalah kunci utama kemajuan bangsa. Ia mengajak seluruh siswa untuk memanfaatkan fasilitas belajar sebaik mungkin dan tidak menyia-nyiakan kesempatan yang ada.\n\nAcara dilanjutkan dengan berbagai kegiatan seni dan budaya yang menampilkan bakat-bakat terpendam para siswa, mulai dari pembacaan puisi, penampilan tari tradisional, hingga pameran karya seni rupa.',
    tags: ['#HardiKnas', '#Pendidikan', '#SDNWarialau'],
  ),
  BeritaModel(
    id: 2,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDggSjKM6De0lZk01o2ypYkusJhZymVL_IWk6nY4qHera9aGIXrfDkl2BrLh4d9AC1w-5mi-DPumOZUSsIp_kVs5NRKYqepJyXqNrY7pGo-keSMgvzInT0lnKEfk587N5hVfyYo0jKr1D059-ArY6EM0Dz2Xm2zBjWGRfT-oYpwPADZWnfnLZ4mhjr2NadfWXhtRivSrmKEpyjW1blPoYKoJt8VVhLq3K0jCqkYTUYzZqdIrslk27DO-nO5CYLqYq43j2Md_wlKFAR',
    category: 'Prestasi',
    title: 'Juara 1 Lomba Cerdas Cermat Tingkat Kabupaten Kepulauan Aru',
    date: '15 Mei 2024',
    readTime: '3 menit baca',
    excerpt:
        'Tim siswa SD Negeri Warialau berhasil meraih Juara 1 dalam ajang Lomba Cerdas Cermat tingkat Kabupaten.',
    content:
        'Sebuah prestasi gemilang berhasil ditorehkan oleh tim siswa SD Negeri Warialau dalam Lomba Cerdas Cermat tingkat Kabupaten Kepulauan Aru yang diselenggarakan pada Mei 2024.\n\nTim yang terdiri dari tiga siswa pilihan ini berhasil mengalahkan 24 tim peserta lainnya dari berbagai sekolah dasar di seluruh kabupaten. Persiapan intensif selama dua bulan terbayar lunas dengan raihan medali emas bergengsi ini.\n\nGuru pembimbing menyampaikan rasa bangganya atas dedikasi dan kerja keras para siswa. "Mereka berlatih sangat keras, bahkan rela mengorbankan waktu bermain demi mempersiapkan diri," ungkapnya dengan mata berbinar.\n\nPrestasi ini diharapkan menjadi motivasi bagi seluruh siswa SD Negeri Warialau untuk terus belajar dan berprestasi di berbagai bidang akademik maupun non-akademik.',
    tags: ['#Prestasi', '#CerdasCermat', '#Juara1'],
  ),
  BeritaModel(
    id: 3,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCjhlGY5FXin0g1Ih2VwLV73zN7fCLede-QUXHy-9B9sxXynQtgWiNH250hUvsmvIpGHhJ6XcitgSJcKfLGEhNjT_xhlA5XUn4Cq6tT4KDk51QWSsW1HGSRQxD1yqfb56MQvuv8ZECtYjBjML2WnSsbDA2UYKMybkY5CNHqmNaTahWVuJ9ROJw9EwbLeu7InnIo1BHLq022Br60FHRoOHx_ETEKgUhgj_jy9Cht3uCuLhiLgABGqK1Vohj4com-4cDr3Eu-SiwrYXsD',
    category: 'Pengumuman',
    title: 'Pengumuman Kelulusan Siswa Kelas VI Tahun Ajaran 2023/2024',
    date: '10 Juni 2024',
    readTime: '2 menit baca',
    excerpt:
        'Kami dengan bangga mengumumkan bahwa seluruh siswa kelas VI SD Negeri Warialau dinyatakan LULUS 100%.',
    content:
        'Dengan penuh rasa syukur dan bangga, pihak SD Negeri Warialau mengumumkan bahwa seluruh siswa kelas VI tahun ajaran 2023/2024 dinyatakan LULUS 100% dari jenjang pendidikan sekolah dasar.\n\nSebanyak 64 siswa kelas VI telah berhasil menyelesaikan seluruh rangkaian ujian dengan hasil yang memuaskan. Rata-rata nilai kelulusan tahun ini mengalami peningkatan signifikan dibandingkan tahun sebelumnya.\n\nUpacara penyerahan ijazah akan diselenggarakan pada tanggal 22 Juni 2024 di aula sekolah. Orang tua/wali murid diharapkan hadir untuk menyaksikan momen bersejarah bagi putra-putri mereka.\n\nSegenap guru dan staf SD Negeri Warialau mengucapkan selamat kepada seluruh siswa kelas VI dan berharap mereka dapat melanjutkan pendidikan ke jenjang yang lebih tinggi dengan semangat yang tak pernah padam.',
    tags: ['#Kelulusan', '#Pengumuman', '#KelaVI'],
  ),
  BeritaModel(
    id: 4,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBj-iaxVAIHevUj8sqou10McuH-LyTKwcw-1vwbUFRS3Pka-YGD_kgeMzsH_Ao8FhsUfGx9NZDZXDJSVl-d-Of8vF8ZV0q-OrP6MNKpxgKgsF71oUDi0bxNRTW2JGt92yNCYrnw6MLtDrHeCHxKQD6hz9h7T-hXFwfxIlfO3ER7-mrO1qcTJRRi68xukrlwv61xyz3SQptmx8A-NUNRy-GkXk2G8Y4u_34Lq9CFpKdQWqDEP6v-kn-r_EdzRDXJFoSuthQRhOohyuII',
    category: 'Info',
    title: 'Penerimaan Peserta Didik Baru (PPDB) Tahun Ajaran 2024/2025 Telah Dibuka',
    date: '1 Juni 2024',
    readTime: '3 menit baca',
    excerpt:
        'SD Negeri Warialau membuka pendaftaran peserta didik baru untuk tahun ajaran 2024/2025. Pendaftaran online dan offline tersedia.',
    content:
        'SD Negeri Warialau dengan bangga membuka Penerimaan Peserta Didik Baru (PPDB) untuk tahun ajaran 2024/2025. Pendaftaran resmi dibuka mulai 1 Juni hingga 30 Juni 2024.\n\nPersyaratan pendaftaran:\n• Usia minimal 6 tahun per 1 Juli 2024\n• Membawa fotokopi akta kelahiran (2 lembar)\n• Foto terbaru ukuran 3x4 (4 lembar)\n• Kartu Keluarga (fotokopi)\n• Surat keterangan domisili\n\nPendaftaran dapat dilakukan secara langsung di kantor sekolah pada hari kerja (Senin-Jumat, pukul 08.00-14.00) atau melalui formulir online yang tersedia.\n\nKuota penerimaan terbatas. Untuk informasi lebih lanjut, silakan hubungi kantor sekolah di nomor (0911) 123456.',
    tags: ['#PPDB', '#PendaftaranSiswa', '#2024'],
  ),
  BeritaModel(
    id: 5,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC1PqS3cEil3kyVA-HPjotC6DHemccf6KUv_3IC8hTm06sOREHqn5qJGcdp0EpG6UjT8w2tso8oq1eRWn-5D5-0gg2VtfIxB8q_iv4M15FMTS5Z-X63hKS0VhqQLJcP5R1WhpxJU84eBC-cm3WDaPIKXlsKYSOKrn2j1iTRANVu7BRTBmMsjAd7gEcKXOwwnDJeRm8UgCgiPS71MrTaK7KDzDXtnueoCY362Mv1WcrrO6CTs-CFCdyVwiFTxdHcWC8hubVtO-kDew7S',
    category: 'Prestasi',
    title: 'Juara 1 Lomba Lukis Tingkat Provinsi Maluku 2024',
    date: '12 Mei 2024',
    readTime: '3 menit baca',
    excerpt:
        'Siswa berbakat SD Negeri Warialau meraih Juara 1 dalam Lomba Seni Lukis Tingkat Provinsi Maluku.',
    content:
        'Seorang siswa berbakat dari SD Negeri Warialau berhasil menorehkan prestasi gemilang dengan meraih Juara 1 dalam Lomba Seni Lukis Tingkat Provinsi Maluku yang diselenggarakan di Kota Ambon.\n\nDengan karyanya yang menggambarkan keindahan alam kepulauan Maluku dan kearifan lokal budaya setempat, siswa tersebut berhasil memikat hati para juri dan mengalahkan puluhan peserta dari berbagai sekolah se-Provinsi Maluku.\n\nKarya tersebut dibuat selama tiga hari dengan teknik cat air dan berhasil menuangkan cerita mendalam tentang kehidupan masyarakat pesisir Maluku yang kaya budaya.\n\nGuru seni rupa menyatakan bahwa bakat ini sudah terlihat sejak kelas III dan terus dibimbing secara intensif. Prestasi ini menjadi bukti bahwa dengan bimbingan yang tepat, bakat anak-anak di daerah terpencil pun mampu bersinar di kancah yang lebih luas.',
    tags: ['#SeniLukis', '#Prestasi', '#ProvinsiMaluku'],
  ),
];
