# progress.md — Güncel Durum ve Plan

> Tarih formatı: GG.AA.YYYY. Ajan her görev başında burayı okur, görev bitince `skills/progress-update` ile günceller.
> Takvim varsayımsaldır (başlangıç: 26.10.2026, 5 hafta). Gerçek teslim tarihi netleşince kaydırılır.

## Şu An
| Alan | Durum |
|---|---|
| Aktif görev | T05 (Tuba) / T02 (Sümeyye) |
| Aktif kişi | Tuba |
| Engel | Yok |
| Son güncelleme | 24.10.2026 |

## Görev Planı
Durum: ⬜ Bekliyor · 🟨 Devam · ✅ Bitti. Puan: S=1, M=2, L=3.

### 1. Adım Temel
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T01 | Flutter projesi, klasör yapısı, paketler, `analysis_options.yaml` | Tuba | 1 | 27.10 | ✅ |
| T02 | `main.dart`, tema (`app_colors`, `app_theme`, `ValueNotifier<ThemeMode>`) | Sümeyye | 2 | 28.10 | ⬜ |
| T03 | SQLite şeması + `app_database.dart` (cases, records), append-only repository | Tuba | 2 | 30.10 | ✅ |
| T04 | Navigasyon + onboarding + KVKK/uyarı ekranı | Sümeyye | 2 | 01.11 | ⬜ |
| T05 | `hash_utils.dart` (SHA-256, zincir, kanonik JSON) + birim testleri | Tuba | 2 | 01.11 | ⬜ |

### 2.Adım Dosya ve kayıt
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T06 | Dosya (case) modeli + repository + controller | Tuba | 2 | 04.11 | ⬜ |
| T07 | Dosyalarım + Dosya Oluştur ekranları | Sümeyye | 2 | 06.11 | ⬜ |
| T08 | Kayıt ekleme servisi: dosyayı uygulama dizinine kopyala, hash, zincir, saat anomalisi tespiti | Tuba | 3 | 07.11 | ⬜ |
| T09 | Kayıt Ekle ekranı (tür seç, kamera/dosya seçici) | Sümeyye | 2 | 08.11 | ⬜ |

### 3.Adım Zaman çizelgesi ve ilk form
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T10 | Zaman çizelgesi ekranı | Sümeyye | 2 | 11.11 | ⬜ |
| T13 | Zincir doğrulama servisi (`verifyChain`) + test | Tuba | 1 | 12.11 | ⬜ |
| T11 | Form altyapısı (alan modeli, doğrulama, submit) + F1 (mantık + ekran) | Tuba | 3 | 14.11 | ⬜ |
| T12 | Kayıt Detayı + zincir doğrulama rozeti | Sümeyye | 1 | 14.11 | ⬜ |
| T14 | Konuşma kanıtı ekranı (ekran görüntüsü + not) | Sümeyye | 1 | 15.11 | ⬜ |

### 4.Adım Formlar ve çıktı
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T15 | F2 Teslim/Tahliye Formu (mantık + ekran) | Tuba | 3 | 18.11 | ⬜ |
| T17 | F3 Arıza + F4 Ödeme — model/doğrulama/controller | Tuba | 2 | 19.11 | ⬜ |
| T16 | PDF rapor (zaman çizelgesi + hash tablosu + saat uyarısı) | Sümeyye | 3 | 20.11 | ⬜ |
| T18 | F3 + F4 ekranları + Form Listesi | Sümeyye | 2 | 22.11 | ⬜ |
| T19 | ZIP delil paketi (`manifest.json`) + mühür kodu paylaşımı | Tuba | 2 | 22.11 | ⬜ |

### 5.adım Bitirme
| ID | Görev | Sahip | Puan | Hedef | Durum |
|---|---|---|---|---|---|
| T20 | F5 Olay Notu — model/doğrulama/controller | Tuba | 1 | 23.11 | ⬜ |
| T22 | Uygulama kilidi mantığı (PIN özeti + `local_auth`) | Tuba | 1 | 24.11 | ⬜ |
| T21 | F5 ekranı + hatırlatıcı bildirim | Sümeyye | 2 | 25.11 | ⬜ |
| T23 | Ayarlar + kilit ekranı + yedek hatırlatma | Sümeyye | 2 | 26.11 | ⬜ |
| T24 | Uçtan uca test, `analyze`/`test` temizliği | İkisi | 1+1 | 27.11 | ⬜ |
| T25 | README + demo senaryosu | İkisi | 1+1 | 29.11 | ⬜ |

## Kararlar Günlüğü
| Tarih | Karar |
|---|---|
| 24.10.2026 | Yalnızca Flutter + Dart |
| 24.10.2026 | **Backend kaldırıldı:** sunucu, PostgreSQL, JWT, davet/ortak dosya yok. Veri yerel SQLite; zaman damgası cihaz saati |
| 24.10.2026 | Zaman güvenilirliği için: hash zinciri + saat anomalisi tespiti + mühür kodunu dışarıya (e-posta) gönderme |
| 24.10.2026 | İş bölümü: Tuba = veri/mantık/formlar/ZIP; Sümeyye = tema/ekranlar/PDF/bildirim |
