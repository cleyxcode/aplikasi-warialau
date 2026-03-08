class GaleriItem {
  final int id;
  final String imageUrl;
  final String title;
  final String category;
  final String date;

  const GaleriItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.date,
  });
}

const galeriCategories = ['Semua', 'Seni Budaya', 'Akademik', 'Olahraga', 'Pramuka', 'Lainnya'];

const dummyGaleriList = <GaleriItem>[
  GaleriItem(
    id: 1,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDE_oQ8gKyvc_vL1xEqOu0hU8usUB4Y0rZACoiY4MllxdmQPZ58MOWDrTUsBoxsEOrnXKmm8l1ndbTEzmnEL8TkKdiEMa9yaeT8WvcOlw17Ql9nNJh3IewvZQamPxnmasCzlTjNhDt-SaJCPYhfA27mvhnhIIKHXYa6og5pcv6FTFN0owtB0gi0p7M1PhpvOhslIby56yItioQw8ImvXkn6aLJa-NI9Wyeg6v2AInDKrvzDlOxpfrr6wxhmUSZvoVXCj2qnuP7MsNgE',
    title: 'Lomba Lukis',
    category: 'Seni Budaya',
    date: '10 Mei 2024',
  ),
  GaleriItem(
    id: 2,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA36wQPYdCNvIZ6dBh0oJck7nxv_BUkewiB-bNdF2zc-cO0QlcH1E1jntv3fybhshiWHsVlAIOnxYkSfR4hKaGNwpWDJgMP_wrP7iOkW-P3WWleTGABx1JL5Y7SlEvqX_O6UFWKcsqJShws646hD-U0iH88c2rN6WEXGn6d_3N2FvdYwY29YZ4TZXHtzR8Iz6JMwAgailiACICCRbtzm-9jCbUB4gh9rlLRiYTu6-vGh2O7ylSikSQ6CGBeCiUJFuNYR7uhUw7_JN81',
    title: 'Upacara Bendera',
    category: 'Lainnya',
    date: '2 Mei 2024',
  ),
  GaleriItem(
    id: 3,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAb8SH_ULcRhuw3aOaXXhTc6Rkf4ma6OWsFheC0P0khrIF9ib41mX1PX-_SNRr4pVcb_BXJc2ZMnACE_SlxIXzwVaKfAsw_5kI9Jju-C9eLUjJcWHu5g4iUA-z5FGLmLeCwd_9tGbtBj751W5tYjuG7rRZrqaeLdL60jM17UCjrr6ERavvMqPLO9wNZAMmXHX0ze3zn45rgRjkYGVUYgj_tIVaz2_yej7RGtNzBb4BjOKEb-UwlOZbwyp75y-OsQ-7VXNXq0VNdiwq6',
    title: 'Pentas Seni Tari',
    category: 'Seni Budaya',
    date: '17 Agustus 2023',
  ),
  GaleriItem(
    id: 4,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBFFzftO7XP4IRKaVxmnrEc2IqVvsvfLH_pWLfJX0Mi-fxzHrPQiEhBnlXf3X7wVeAYkhslqJL7Y6A2z9NKXWEQiMR2-oY8syq3T7sy1pZguaZM2miSrmZFzrq2lBEj5qqpvpUb9vTt9TKuoLIqZRI-jyZGc-hXFptjrJ6umVNx9sYwaVVvfXT-WkI5v5CVmsAJ3Diqa90xcyScZVWjdsnE01xz4gY_cOZsu1sYqs4xnyRw09e_gCgFgC_BtiwQW_3iTb4TGSqDVZgy',
    title: 'Persami Pramuka',
    category: 'Pramuka',
    date: '14 April 2024',
  ),
  GaleriItem(
    id: 5,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD4AhTGwK7fnQ8fJJ9Sa5vJwLdQHgR80tPFlZuVMamdQIRbOlMNjlV5jKf8Sdd7wUHR8mAfL7zCWMtXsL_AkY15LuymhNTeNr0ejF1vwwnuXGlEeRhvtxoImM0rZLmZeRVFNXfPsmTJpy5GB6IDGq0GxJjgTBuKOqJ2HqGXrUq0QTb0vDDDL0AGUL_G3GehNoDtJAEkEifgnZQ-AVj8Z49K7l-7QU0RQRTb-3fbsfRhL28T-y-XWByFARNPOC2Av8KzhGZjmYCCHViR',
    title: 'Literasi Pagi',
    category: 'Akademik',
    date: '8 Januari 2024',
  ),
  GaleriItem(
    id: 6,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDS7G63w6yOjRTYFJvzmrUPyIx97lGemV-gwBGktQMnQIIm_MvDzb3R98KwVA9v58Xthlpqc38h5h_n2w6DVNQYFfo-9axp39lDqrY7MT2GNOISR6L9rEwiPRtULpasA-y8EZXt8S7vdiNzByD05sRSGl6cNn_RJEZqNHc3AdDxm_OfBJlRafB0xoef8r0BR0lOynsVWoh8AKwYOwJFdLIiGNsIASH6_J1uhiXVvdALoRCeDC-BiiujMCXB4ydymbwSonjyA2xkYAq5',
    title: 'Lomba 17-an',
    category: 'Olahraga',
    date: '17 Agustus 2023',
  ),
  GaleriItem(
    id: 7,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAcgkc8MwKN7DcvPJa786E8fSCri8J2DOkY_FykLVyIdB7D3jRSmPgHD4JRLXLbreYgDxSjfgzvHimdEtw0Wb5FKZcomjEMNsYAslnKRvdhiJORDUXPp4ZkafyUs2XP9BLZYmNka16JTW-yzSLeJhv8GQMfEPMUsC9wtfMqc_cynjfqLdHOa_ceeY39uvx3akLz1KWL5fEfl60Zo_qejHQ_QuYq9UBrCWmATxrOgr01wg1Fs6YjJTHRQLUwG4HIRHUAYzYFjPUjOl5t',
    title: 'Sepak Bola Mini',
    category: 'Olahraga',
    date: '5 Maret 2024',
  ),
  GaleriItem(
    id: 8,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDgoK4EdgBus2PNJsihLy1X4jN3tt9_s08w9XmAVV82WsmMqdq578PGsSOVFPx1eWB2VxIozDIEvYZVKRm0oejQvPQtJ5YAgcpN5vB4968il6Uej1N0SJBUJytCOV3TX6K3lGgXW2tv9NY7KxM3G7Sn_LTA9curgf48sc8eKoXnkpR36ioNSv2eI0fkYvlazzYkQwZYXCMLuvn2i8qziOaA3twdg1eAEauDfwypF7TX6aLxvQ8_h7utI5cvWRTiVq9mP8uHO3ggNKvV',
    title: 'Pagelaran Tari Maluku',
    category: 'Seni Budaya',
    date: '20 Oktober 2023',
  ),
  GaleriItem(
    id: 9,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCmNW_0X-Hak6pv78v7kKiu7WFaoNfkTd2MfZQHwZ8FW2EUcRQ1mqW7OPngZVFrMTeOSLMurh0Nn_j2O9wFRCSe8mytV2rsrHJ63CAS99LU26S_VN2NKuaXzpgjzcjbui6OdVay7x7lekreg7_yfsSYWIbl9Kcu2ekJqNZtu7NNGgaWxZyeFzunKkVlygb-t-lCRCHpKh6o9COFj2TdYuUQeXu5ZfXRrAERkl5QGM2xeYDlvNCg8uC51_fOBWgyY8tWu0WihPRY5x19',
    title: 'Pameran Sains',
    category: 'Akademik',
    date: '15 November 2023',
  ),
  GaleriItem(
    id: 10,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDWrefFolJ7Re2Ho2OXNlb-dtqNn9k0-mLTxDkNw2bHs4niaNKK8ZNHp6k4jQQWfO9N9Yi8YpPOyRgn-djqoK0LmeGu06vO7S59RYd30e9niOFcSV1vQolPgnJha2L-uwEUmUvH50Zo7KK3VmuCNmKsuBYn_BqTDNxIfbPqik2A1W5QkJu11MqltKlN81sPm6O3hSQZP1_7edAMkSQRwgChAndlHcROYHKJB4BT_wbLnnTswvDzEsCL74dXK3DIVf8_FKZ9uHRdl8JH',
    title: 'Berkebun Sekolah',
    category: 'Lainnya',
    date: '22 Februari 2024',
  ),
];
