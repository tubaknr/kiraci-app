# API Sözleşmesi (REST, JSON)

> Taban: `/api/v1`. Uygulama (istemci) katmanı bu dokümana göre yazılır. Değişiklik önce burada yapılır.

## 1. Genel Kurallar
- Kimlik: `Authorization: Bearer <access_token>` (auth uç noktaları hariç).
- Gövde: `application/json`; dosya yükleme `multipart/form-data`.
- Zamanlar ISO 8601 UTC (`2026-10-24T09:30:00Z`); para **kuruş** tam sayısı (`"tutar_kurus": 2500000`).
- Yazma isteklerinde önerilen başlık: `Idempotency-Key: <uuid>`.
- Sayfalama: `?limit=20&imlec=<son_id>`; yanıt `{ "veri": [...], "sonraki_imlec": "..." }`.
- Hata biçimi (her yerde aynı):
```json
{ "hata": { "kod": "YETKISIZ", "mesaj": "Bu eve erişim yetkiniz yok." } }
```
- Durum kodları: 200/201 başarı, 400 doğrulama, 401 token yok/geçersiz, 403 yetki, 404 yok (ya da yetkisiz → varlık sızdırılmaz), 409 çakışma, 413 dosya büyük, 415 desteklenmeyen tür, 429 hız sınırı, 500 sunucu.
- Her yazma yanıtı `sunucu_zamani` döner (resmi damga).

## 2. Uç Noktalar
| Yöntem | Yol | Yetki | Açıklama |
|---|---|---|---|
| GET | /saglik | yok | Sunucu sağlık kontrolü |
| POST | /auth/kayit | yok | E-posta, parola, ad ile hesap aç |
| POST | /auth/giris | yok | Access + yenileme token'ı döner |
| POST | /auth/yenile | yenileme token'ı | Yeni access token (döndürmeli yenileme) |
| POST | /auth/cikis | token | Yenileme token'ını iptal eder |
| GET | /auth/ben | token | Kullanıcı bilgisi |
| GET | /evler | token | Üyesi olduğum evler |
| POST | /evler | token | Ev oluştur (oluşturan rolünü seçer) |
| GET | /evler/{evId} | üye | Ev detayı |
| POST | /evler/{evId}/davetler | üye | Karşı taraf için davet kodu üret |
| POST | /davetler/kabul | token | Kodla eve katıl |
| GET | /evler/{evId}/sozlesme | üye | Güncel kira & sözleşme bilgisi |
| GET | /evler/{evId}/sozlesme/surumler | üye | Tüm sürümler |
| POST | /evler/{evId}/sozlesme | üye | Yeni sürüm ekle (adres/tutar/tarih/depozito) |
| POST | /evler/{evId}/dosyalar | üye | **`/delil-yukle`**: dosya yükle (`tur`, `dosya`) |
| GET | /evler/{evId}/dosyalar?tur= | üye | Dosya listesi |
| GET | /dosyalar/{dosyaId}/indir | üye | Dosyayı indir |
| GET | /dosyalar/{dosyaId}/dogrula | üye | SHA-256 yeniden hesapla, kayıtla karşılaştır |
| POST | /evler/{evId}/dekontlar | üye | Dekont kaydı (dosya + dönem + tutar + tarih) |
| GET | /evler/{evId}/dekontlar | üye | Dekont listesi |
| POST | /evler/{evId}/demirbaslar | üye | Demirbaş kalemi ekle (fotoğraf dosya id'leriyle) |
| GET | /evler/{evId}/demirbaslar | üye | Demirbaş listesi (güncel halleri) |
| POST | /demirbaslar/{id}/duzeltme | üye | Düzeltme = yeni kayıt (`supersedes_id`) |
| POST | /demirbaslar/{id}/onay | üye (karşı taraf) | `onaylandi` / `itiraz` |
| POST | /evler/{evId}/bildirimler | üye | Talep/bildirim oluştur (zaman damgalı) |
| GET | /evler/{evId}/bildirimler | üye | Bildirim listesi |
| GET | /bildirimler/{id} | üye | Detay (okundu bilgisiyle) |
| POST | /bildirimler/{id}/okundu | üye (karşı taraf) | Okundu kaydı |
| POST | /bildirimler/{id}/yanit | üye | Yanıt bildirimi |
| POST | /evler/{evId}/mesajlar | üye | **`/mesaj-gonder`**: mesaj gönder |
| GET | /evler/{evId}/mesajlar | üye | Mesaj akışı (yalnız bu evin üyeleri) |
| GET | /evler/{evId}/loglar | üye | Değiştirilemez log akışı |
| GET | /evler/{evId}/loglar/dogrula | üye | Hash zincirini baştan sona doğrular |

## 3. Örnekler

### Giriş
```json
POST /api/v1/auth/giris
{ "eposta": "tuba@ornek.com", "parola": "********" }
→ 200 { "erisim_token": "...", "yenileme_token": "...", "kullanici": { "id": "...", "ad": "..." } }
```

### Bildirim oluştur
```json
POST /api/v1/evler/{evId}/bildirimler
{ "tur": "kira_odendi", "baslik": "Ekim kirası ödendi", "govde": "2.500 TL havale yapıldı.",
  "ek_dosya_id": null, "istemci_zamani": "2026-10-24T09:29:40Z" }
→ 201 { "id": "...", "sunucu_zamani": "2026-10-24T09:30:00Z", "icerik_hash": "ab12..." }
```
`tur` değerleri: `kira_odendi`, `tadilat_talebi`, `depozito_talebi`, `ariza_bildirimi`, `uyari`, `tahliye_bildirimi`, `diger`.

### Delil yükle
```
POST /api/v1/evler/{evId}/dosyalar   (multipart)
alanlar: tur=odeme_dekontu|sozlesme_pdf|demirbas_foto|ev_foto|mesaj_eki|bildirim_eki, dosya=<binary>
→ 201 { "id": "...", "sha256": "9f2c...", "boyut": 482113, "sunucu_zamani": "..." }
```

### Mesaj gönder
```json
POST /api/v1/evler/{evId}/mesajlar
{ "govde": "Kombi servisi yarın gelecek.", "ek_dosya_id": null }
→ 201 { "id": "...", "sunucu_zamani": "..." }
```

## 4. Güvenlik Notları
- Her uç noktada: JWT doğrula → `evId` için üyelik kontrolü → iş mantığı. Üyelik yoksa `404`.
- Dosya indirmede yol parametresi doğrudan disk yoluna çevrilmez (path traversal yok); `storage_path` DB'den okunur.
- Giriş ve kayıt uç noktalarında IP + e-posta bazlı hız sınırı.
- Yanıtlarda `password_hash`, token hash'i, depolama yolu asla dönmez.
- Test modu (Kiracı/Ev Sahibi geçişi) için **özel uç nokta yoktur**; istemci iki gerçek hesabın oturumları arasında geçiş yapar. Üretimde `tool/seed_dev.dart` çalışmaz (`APP_ENV` kontrolü).
