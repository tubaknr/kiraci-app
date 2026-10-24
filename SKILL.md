---
name: git-workflow
description: Bir göreve başlarken branch açmak, görev bitince commit ve push yapmak için kullan.
---

# Git İş Akışı

## Amaç
İki kişilik ekipte (Tuba, Sümeyye) çakışmasız, izlenebilir commit/push akışı.

## Ne Zaman Kullan
- Yeni göreve (`progress.md` T-numarası) başlarken
- Görev bitip commit/push yapılacakken

## Ne Zaman Kullanma
- Sadece dosya okuma/inceleme yaparken

## A) Göreve Başlarken
1. `git status` → çalışma alanı temiz mi? (değilse sor)
2. `git checkout main && git pull`
3. `git checkout -b <kisi>/<T-no>-<kisa-aciklama>`
   Örnek: `tuba/T08-kayit-ekleme`, `sumeyye/T10-zaman-cizelgesi`

## B) Görev Biterken
1. `flutter analyze` → 0 uyarı/hata; `flutter test` → geçmeli
2. `git status` → yalnızca beklenen dosyalar mı?
3. `git add <dosyalar>` (mümkünse `git add .` yerine hedefli)
4. `git commit -m "<tip>: <ne yapıldı>"`
   Tipler: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
   Örnek: `feat: kayit ekleme servisi ve hash zinciri eklendi`
5. `git push -u origin <branch-adi>`
6. `progress.md` + `done.md` güncelle (`progress-update`), ayrı commit: `docs: progress ve done guncellendi`
7. PR aç; **diğer kişi** inceler, sonra main'e birleşir

## C) Sahiplik Kontrolü
| Değişen yer | Kural |
|---|---|
| `core/db`, `core/integrity`, `controller/`, `models/` | Tuba onayı |
| `core/theme`, `core/constants`, `view/`, `widget/` | Sümeyye onayı |
| Başkasının alanı | Doğrudan değiştirme, PR + onay |

## D) Kontrol Listesi
- [ ] main'de değilim
- [ ] Kullanıcı verisi, test dosyaları, `*.db` commit'te yok
- [ ] Commit mesajı formatlı
- [ ] Analiz/testler geçti
- [ ] Push başarılı
- [ ] Başkasının alanına dokunduysam PR'da belirttim

## E) Sorun Çıkarsa
| Durum | Ne yap |
|---|---|
| Merge çakışması | DUR, kullanıcıya bildir. Kendin çözmeye çalışma |
| Push reddedildi | `git pull --rebase`, tekrar dene; olmazsa sor |
| Yanlış branch'e commit | Dur, söyle. `reset --hard` kullanma |

## F) Asla
`git push --force`, `git reset --hard`, main'e doğrudan push, başkasının branch'ini silmek.
