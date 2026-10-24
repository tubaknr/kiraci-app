# Veritabanı Tasarımı (PostgreSQL)

> Kaynak doküman. Tablo/ilişki değişirse önce burası güncellenir, sonra migration yazılır.
> Kural: Para birimi **kuruş (bigint)**, zamanlar **timestamptz (UTC)**, id'ler **uuid**.

## 1. İlişki Özeti
```
users 1──* property_members *──1 properties
properties 1──* leases (sürümlü)
properties 1──* files
properties 1──* receipts ──1 files
properties 1──* inventory_items 1──* inventory_item_photos *──1 files
inventory_items 1──* inventory_confirmations
properties 1──* notices 1──* notice_acknowledgements
properties 1──* messages (──0..1 files)
properties 1──* audit_logs   (+ property_chain_heads: zincirin son halkası)
users 1──* refresh_tokens
```

## 2. Tablolar

### users
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| email | text UNIQUE | küçük harfe çevrilerek saklanır |
| password_hash | text | bcrypt/argon2 |
| full_name | text | |
| phone | text NULL | |
| created_at | timestamptz | sunucu zamanı |

### properties (Ev)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| title | text | ör. "Kadıköy 2+1" |
| address_line | text | |
| district, city | text | |
| created_by | uuid FK users | |
| created_at | timestamptz | |

### property_members (yetkinin temeli)
| Alan | Tip | Not |
|---|---|---|
| property_id | uuid FK | |
| user_id | uuid FK | |
| role | enum `landlord`, `tenant` | |
| joined_at | timestamptz | |
PK (property_id, user_id). Bir evde her rolden en fazla 1 üye (kısıt). Davet için `property_invites(code_hash, property_id, role, expires_at, used_at)`.

### leases (Sözleşme — sürümlü, append-only)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id | uuid FK | |
| version | int | 1'den başlar; güncel = en yüksek sürüm |
| supersedes_id | uuid NULL FK leases | önceki sürüm |
| monthly_rent_kurus | bigint | |
| deposit_kurus | bigint | |
| start_date, end_date | date | |
| payment_day | smallint | ayın günü (1–31) |
| contract_file_id | uuid NULL FK files | sözleşme PDF'i |
| created_by | uuid FK users | |
| server_time | timestamptz | |

### files
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id | uuid FK | |
| uploader_id | uuid FK users | |
| kind | enum `contract_pdf`, `receipt`, `inventory_photo`, `house_photo`, `message_attachment`, `notice_attachment` | |
| original_name | text | |
| mime_type | text | doğrulanmış |
| size_bytes | bigint | |
| sha256 | char(64) | **sunucuda** hesaplanır |
| storage_path | text | göreli yol |
| client_reported_at | timestamptz NULL | yalnızca bilgi |
| server_time | timestamptz | |

### receipts (Dekont)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id, lease_id | uuid FK | |
| file_id | uuid FK files | dekont dosyası |
| period | char(7) | "2026-10" (hangi ayın kirası) |
| amount_kurus | bigint | |
| paid_on | date | kullanıcının beyan ettiği ödeme tarihi |
| uploaded_by | uuid FK users | |
| server_time | timestamptz | |

### inventory_items (Demirbaş — append-only)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id | uuid FK | |
| phase | enum `move_in`, `move_out` | giriş / çıkış tespiti |
| room | text | |
| name | text | "Kombi", "Parke" |
| condition | enum `good`, `worn`, `damaged`, `missing` | |
| note | text | "kombi sağlam", "parke çizik" |
| supersedes_id | uuid NULL FK | düzeltme zinciri |
| recorded_by | uuid FK users | |
| server_time | timestamptz | |

### inventory_item_photos
(inventory_item_id, file_id, position) — PK (inventory_item_id, file_id)

### inventory_confirmations (karşı tarafın onayı)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| inventory_item_id | uuid FK | |
| user_id | uuid FK | onaylayan |
| decision | enum `approved`, `disputed` | |
| comment | text NULL | itiraz gerekçesi |
| server_time | timestamptz | |

### notices (Talep / Bildirim)
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id | uuid FK | |
| author_id | uuid FK users | |
| type | enum `rent_paid`, `repair_request`, `deposit_request`, `fault_report`, `warning`, `move_out_notice`, `other` | |
| title | text | |
| body | text | |
| attachment_file_id | uuid NULL FK files | |
| reply_to_id | uuid NULL FK notices | yanıt zinciri |
| client_reported_at | timestamptz NULL | |
| server_time | timestamptz | resmi zaman |
| content_hash | char(64) | başlık+gövde+ek özeti |

### notice_acknowledgements (okundu / teslim kaydı)
(notice_id, user_id, server_time) — PK (notice_id, user_id)

### messages
| Alan | Tip | Not |
|---|---|---|
| id | uuid PK | |
| property_id | uuid FK | |
| sender_id | uuid FK users | |
| body | text | |
| attachment_file_id | uuid NULL FK files | |
| client_reported_at | timestamptz NULL | |
| server_time | timestamptz | |
| content_hash | char(64) | |
Görünürlük: yalnızca `property_members` içindeki iki kullanıcı. Başka evin mesajına sorgu seviyesinde bile ulaşılamaz (her sorguda `property_id` + üyelik filtresi).

### audit_logs (değiştirilemez sistem logu)
| Alan | Tip | Not |
|---|---|---|
| id | bigserial PK | ev içinde sıra |
| property_id | uuid FK | |
| actor_id | uuid FK users | |
| action | text | `notice.created`, `file.uploaded`, `message.sent`... |
| entity_type, entity_id | text, uuid | |
| payload_hash | char(64) | ilgili kaydın `content_hash`/`sha256` değeri |
| server_time | timestamptz | |
| prev_hash | char(64) | önceki satırın `entry_hash` (ilk için 64 sıfır) |
| entry_hash | char(64) | aşağıdaki formül |

`entry_hash = SHA256(prev_hash | property_id | actor_id | action | entity_type | entity_id | payload_hash | server_time_iso8601)`

### property_chain_heads
(property_id PK, last_log_id, last_hash) — yazma sırasında `SELECT ... FOR UPDATE` ile kilitlenir; böylece aynı evde zincir çatallanmaz.

### refresh_tokens
(id, user_id, token_hash, expires_at, revoked_at, created_at) — token düz metin saklanmaz. Bu tablo operasyoneldir, append-only DEĞİLDİR.

## 3. Değiştirilemezlik (DB seviyesi)
Aşağıdaki tablolarda `UPDATE`/`DELETE` trigger ile reddedilir: `leases`, `files`, `receipts`, `inventory_items`, `inventory_item_photos`, `inventory_confirmations`, `notices`, `notice_acknowledgements`, `messages`, `audit_logs`.

```sql
CREATE OR REPLACE FUNCTION forbid_mutation() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Bu tablo degistirilemez (append-only): %', TG_TABLE_NAME;
END; $$ LANGUAGE plpgsql;

-- her korunan tablo için:
CREATE TRIGGER notices_no_update BEFORE UPDATE OR DELETE ON notices
FOR EACH ROW EXECUTE FUNCTION forbid_mutation();
-- ayrıca: uygulama kullanıcısından UPDATE/DELETE/TRUNCATE yetkisi REVOKE edilir.
```
Ek önlem: uygulama DB kullanıcısı tablo sahibi olmaz (trigger'ı kaldıramasın); migration için ayrı kullanıcı kullanılır.

## 4. Yazma Akışı (her kayıt için aynı)
Tek transaction: (1) üyelik kontrolü → (2) `TimestampService.now()` ile `server_time` al → (3) varlığı ekle (hash'ini hesapla) → (4) `property_chain_heads` kilitle → (5) `audit_logs` satırını `prev_hash` ile ekle → (6) head'i ilerlet → commit. Hata olursa hepsi geri alınır (dosya yüklemede disk dosyası da temizlenir).

## 5. İndeksler
`property_members(user_id)`, `notices(property_id, server_time DESC)`, `messages(property_id, server_time DESC)`, `files(property_id, kind)`, `receipts(property_id, period)`, `audit_logs(property_id, id)`, `leases(property_id, version DESC)`.

## 6. Cihaz İçi Veri (Hive) — sunucu şemasının yansıması DEĞİL
| Box | İçerik | Not |
|---|---|---|
| `drafts` | Gönderilmemiş bildirim/demirbaş/mesaj taslakları + yerel dosya yolu | "taslak, resmi değil" etiketi |
| `cache_properties`, `cache_notices`... | Son çekilen listeler | Çevrimdışı görüntüleme; sunucu her zaman doğrudur |
| (secure storage) | access/refresh token | Hive'a YAZILMAZ |
