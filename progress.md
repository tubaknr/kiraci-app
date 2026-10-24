# progress.md — Güncel Durum ve Plan

> Tarih formatı: GG.AA.YYYY. Ajan her görev başında burayı okur, görev bitince `skills/progress-update` ile günceller.
> Takvim varsayımsaldır (başlangıç: 26.10.2026, 5 hafta). Gerçek teslim tarihi netleşince kaydırılır.

## Şu An
| Alan | Durum |
|---|---|
| Aktif görev | T01 / T02 — Proje iskeleti |
| Aktif kişi | Tuba (T01) + Sümeyye (T02) |
| Engel | Yok |
| Son güncelleme | 24.10.2026 |

## Görev Planı
Durum: ⬜ Bekliyor · 🟨 Devam · ✅ Bitti. Puan: S=1, M=2, L=3.

### Hafta 1 (26.10 – 01.11): Temel
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T01 | Flutter projesi, klasör yapısı, paketler, `analysis_options.yaml` | Tuba | 1 | 27.10 | ⬜ |
| T02 | `main.dart`, tema (`app_colors`, `app_theme`, `ValueNotifier<ThemeMode>`) | Sümeyye | 2 | 28.10 | ⬜ |
| T03 | SQLite şeması + `app_database.dart` (cases, records), append-only repository | Tuba | 2 | 30.10 | ⬜ |
| T04 | Navigasyon + onboarding + KVKK/uyarı ekranı | Sümeyye | 2 | 01.11 | ⬜ |
| T05 | `hash_utils.dart` (SHA-256, zincir, kanonik JSON) + birim testleri | Tuba | 2 | 01.11 | ⬜ |

### Hafta 2 (02.11 – 08.11): Dosya ve kayıt
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T06 | Dosya (case) modeli + repository + controller | Tuba | 2 | 04.11 | ⬜ |
| T07 | Dosyalarım + Dosya Oluştur ekranları | Sümeyye | 2 | 06.11 | ⬜ |
| T08 | Kayıt ekleme servisi: dosyayı uygulama dizinine kopyala, hash, zincir, saat anomalisi tespiti | Tuba | 3 | 07.11 | ⬜ |
| T09 | Kayıt Ekle ekranı (tür seç, kamera/dosya seçici) | Sümeyye | 2 | 08.11 | ⬜ |

### Hafta 3 (09.11 – 15.11): Zaman çizelgesi ve ilk form
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T10 | Zaman çizelgesi ekranı | Sümeyye | 2 | 11.11 | ⬜ |
| T13 | Zincir doğrulama servisi (`verifyChain`) + test | Tuba | 1 | 12.11 | ⬜ |
| T11 | Form altyapısı (alan modeli, doğrulama, submit) + F1 (mantık + ekran) | Tuba | 3 | 14.11 | ⬜ |
| T12 | Kayıt Detayı + zincir doğrulama rozeti | Sümeyye | 1 | 14.11 | ⬜ |
| T14 | Konuşma kanıtı ekranı (ekran görüntüsü + not) | Sümeyye | 1 | 15.11 | ⬜ |

### Hafta 4 (16.11 – 22.11): Formlar ve çıktı
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T15 | F2 Teslim/Tahliye Formu (mantık + ekran) | Tuba | 3 | 18.11 | ⬜ |
| T17 | F3 Arıza + F4 Ödeme — model/doğrulama/controller | Tuba | 2 | 19.11 | ⬜ |
| T16 | PDF rapor (zaman çizelgesi + hash tablosu + saat uyarısı) | Sümeyye | 3 | 20.11 | ⬜ |
| T18 | F3 + F4 ekranları + Form Listesi | Sümeyye | 2 | 22.11 | ⬜ |
| T19 | ZIP delil paketi (`manifest.json`) + mühür kodu paylaşımı | Tuba | 2 | 22.11 | ⬜ |

### Hafta 5 (23.11 – 29.11): Bitirme
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T20 | F5 Olay Notu — model/doğrulama/controller | Tuba | 1 | 23.11 | ⬜ |
| T22 | Uygulama kilidi mantığı (PIN özeti + `local_auth`) | Tuba | 1 | 24.11 | ⬜ |
| T21 | F5 ekranı + hatırlatıcı bildirim | Sümeyye | 2 | 25.11 | ⬜ |
| T23 | Ayarlar + kilit ekranı + yedek hatırlatma | Sümeyye | 2 | 26.11 | ⬜ |
| T24 | Uçtan uca test, `analyze`/`test` temizliği | İkisi | 1+1 | 27.11 | ⬜ |
| T25 | README + demo senaryosu | İkisi | 1+1 | 29.11 | ⬜ |

## Puan Dengesi (planlanan)
| Kişi | Görev puanları | Ortak (T24+T25) | Toplam |
|---|---|---|---|
| Tuba | T01 1 + T03 2 + T05 2 + T06 2 + T08 3 + T11 3 + T13 1 + T15 3 + T17 2 + T19 2 + T20 1 + T22 1 = 23 | 2 | **25** |
| Sümeyye | T02 2 + T04 2 + T07 2 + T09 2 + T10 2 + T12 1 + T14 1 + T16 3 + T18 2 + T21 2 + T23 2 = 21 | 2 | **23** |

> Fark 2 puan (≈%8), kabul edilebilir. Sapma 4 puanı geçerse görev kaydırılır (ör. T22'yi Sümeyye'ye).

## Kararlar Günlüğü
| Tarih | Karar |
|---|---|
| 24.10.2026 | Yalnızca Flutter + Dart |
| 24.10.2026 | **Backend kaldırıldı:** sunucu, PostgreSQL, JWT, davet/ortak dosya yok. Veri yerel SQLite; zaman damgası cihaz saati |
| 24.10.2026 | Zaman güvenilirliği için: hash zinciri + saat anomalisi tespiti + mühür kodunu dışarıya (e-posta) gönderme |
| 24.10.2026 | İş bölümü: Tuba = veri/mantık/formlar/ZIP; Sümeyye = tema/ekranlar/PDF/bildirim |
