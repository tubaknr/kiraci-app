---
name: git-workflow
description: Bir göreve başlarken branch açmak, görev bitince analiz, test, commit ve push yapmak için kullan. İki kişilik ekipte (Tuba: sunucu + belirlenen ekranlar, arkadaş: arayüz kabuğu) çakışmayı önler. Konum: skills/git-workflow/SKILL.md
---

# Git İş Akışı

## A) Göreve başlarken
1. `git status` → çalışma alanı temiz mi kontrol et (değilse bana sor)
2. `git checkout main && git pull`
3. `git checkout -b <tip>/<gorev-id>-<kisa-aciklama>`
   Örnek: `feature/t-04-sunucu-iskeleti`, `feature/t-19-demirbas-formu`, `fix/t-14-bildirim-saat`

## B) Görev biterken
1. Analiz ve test:
   - İstemci: `cd app && flutter analyze && flutter test`
   - Sunucu: `cd server && dart analyze && dart test`
   Hata/uyarı varsa düzelt.
2. `git status` → sadece beklenen dosyalar değişmiş mi bak. Arkadaşın klasörlerine (`app/lib/core/theme`, `auth`, `home`, `messages`, `timeline`) dokunulduysa DUR, bana sor.
3. `git add <dosyalar>` (mümkünse tek tek; `git add .` yalnızca `git status` kontrolünden sonra)
4. `git commit -m "<tip>: <ne yapıldı>"`
   Tipler: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
   Örnek: `feat: bildirim olusturma ucnoktasi eklendi (T-14)`
5. `git push -u origin <branch-adi>`
6. `progress.md` → `done.md` güncelle, ayrı commit at: `docs: progress ve done guncellendi`
7. Bana özetle: ne yapıldı, hangi dosyalar değişti, sıradaki görev ne

## C) Kontrol Listesi
- [ ] main'de değilim
- [ ] `.env`, JWT sırrı, anahtar, `server/storage/` içeriği, test PDF/fotoğrafları eklenmedi
- [ ] Commit mesajı formatlı ve görev ID'si var
- [ ] `flutter analyze` / `dart analyze` ve testler geçti
- [ ] Şema/API değiştiyse `docs/` güncellendi
- [ ] Arkadaşın dosyalarına dokunmadım
- [ ] Push başarılı

## D) Sorun Çıkarsa
| Durum | Ne yap |
|---|---|
| Merge çakışması | DUR, bana bildir. Kendin çözmeye çalışma |
| Push reddedildi | `git pull --rebase`, sonra tekrar dene; olmazsa bana sor |
| Yanlış branch'e commit | Dur, bana söyle. `reset --hard` kullanma |
| Ortak dosyada (tema, router, `docs/api.md`) değişiklik gerekiyor | Dokunma, bana yaz; arkadaşla konuşulacak |
| Yanlışlıkla sır commit'lendi | Dur, bana söyle; sır döndürülmeli (rotate), geçmiş temizliğini ben yönetirim |

## E) Asla
`git push --force`, `git reset --hard`, main'e doğrudan push, başkasının branch'ini silmek, sır içeren dosyayı commit etmek.
