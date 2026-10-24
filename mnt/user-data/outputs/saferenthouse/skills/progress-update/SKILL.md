---
name: progress-update
description: Bir görev bittiğinde veya durum değiştiğinde progress.md ve done.md dosyalarını güncellemek için kullan.
---

# Progress / Done Güncelleme

## Amaç
`progress.md` ve `done.md` her zaman gerçeği yansıtsın; iki kişi kimin ne yaptığını ve puan dengesini görsün.

## Ne Zaman Kullan
- Bir T-görevi bitince veya başlayınca
- Engel, karar, tarih veya sahip değişince

## Ne Zaman Kullanma
- Kod yazarken ara adımlarda

## Adımlar
1. `progress.md` → görevin durumunu ⬜/🟨/✅ yap
2. "Şu An" tablosunu doldur (aktif görev, kişi, engel, tarih)
3. Biten görevi `done.md` tablosunun **en üstüne** ekle: tarih · ID · görev · kişi · puan · branch
4. `done.md` "Puan Toplamı"nı güncelle
5. Karar alındıysa "Kararlar Günlüğü"ne tarihle ekle
6. Puan farkı 4'ü geçerse `progress.md`'ye uyarı notu ekle ve kullanıcıya bildir
7. Ayrı commit: `docs: progress ve done guncellendi`

## Kontrol Listesi
- [ ] Durum simgesi güncel
- [ ] Tarih GG.AA.YYYY
- [ ] `done.md` toplamı doğru
- [ ] Karar günlüğü güncel
- [ ] Başka dosyaya dokunulmadı

## Sık Yapılan Hatalar
| Hata | Doğrusu |
|---|---|
| Görevi bitirip `done.md`'yi unutmak | Her ✅ için `done.md` satırı şart |
| Tarihi eski bırakmak | "Son güncelleme" her seferinde yenilenir |
| Puan dengesine bakmamak | Her hafta sonu toplamlara bak |
