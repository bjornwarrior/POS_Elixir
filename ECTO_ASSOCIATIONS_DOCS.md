## í´— Ecto Mastery: Associations (One-to-Many)

* **belongs_to**: Digunakan di tabel "Anak" (Products) yang menyimpan `foreign_key`.
* **has_many**: Digunakan di tabel "Induk" (Categories) untuk mendefinisikan koleksi data terkait.
* **Foreign Key Constraint**: Menjamin integritas data agar tidak ada produk yang merujuk ke kategori "hantu" (ID yang tidak eksis).
* **Preloading**: Mekanisme pengambilan data relasi secara eksplisit untuk menjaga performa query tetap optimal.

---
> **"Jika kamu lupa atau tidak tahu dokumentasi terbaru untuk mengajarkan saya tolong kamu meminta dokumentasi terbaru dari saya secara spesifik."**
