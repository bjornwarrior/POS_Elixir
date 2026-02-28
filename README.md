# 🚀 Real-time Live Record with Phoenix 1.8 & Ecto

Aplikasi ini adalah laboratorium pembelajaran untuk membangun fitur **ERP/POS Real-time** menggunakan ekosistem Elixir modern. Fokus utamanya adalah sinkronisasi data instan antara database PostgreSQL dan User Interface tanpa reload halaman.

---

## 🛠️ 1. Persistensi Data (Ecto & PostgreSQL)

Dalam Phoenix 1.8, kita mengandalkan **Ecto** sebagai jembatan data. Alur kerja yang benar untuk membuat fitur Live Record dari nol adalah:

1.  **Create Database:** Membuat database di PostgreSQL sesuai konfigurasi.
    ```bash
    mix ecto.create
    ```
2.  **Generate Context:** Membuat logika bisnis (`Catalog`) dan skema data (`Product`).
    ```bash
    mix phx.gen.context Catalog Product products name:string stock:integer
    ```
3.  **Migrate:** Menerapkan skema ke tabel database nyata.
    ```bash
    mix ecto.migrate
    ```

> **Hal Penting:** Pastikan fungsi update di Context menggunakan operasi atomik database (seperti `inc: [stock: -1]`) untuk mencegah *race condition* saat banyak user klik bersamaan.

---

## 📡 2. "Sihir" Real-time (Phoenix PubSub)

Inilah yang membuat data kita menjadi **Live**. Kita menggunakan sistem *Publish-Subscribe*:

- **Topic:** Kita menggunakan channel `"inventory_updates"`.
- **Subscribe:** LiveView mendaftar ke topic ini saat `mount/3` (menggunakan `Phoenix.PubSub.subscribe/2`).
- **Broadcast:** Saat data di database berubah, kita menyiarkan pesan (menggunakan `Phoenix.PubSub.broadcast/3`).
- **Handle:** Fungsi `handle_info/2` di LiveView menangkap pesan tersebut dan langsung mengupdate layar user.



---

## 🌊 3. Efisiensi Data (Phoenix Streams)

Untuk performa terbaik, kita tidak menyimpan daftar barang di dalam memori server (Socket Assigns), melainkan menggunakan **Streams**.

### Kenapa Harus Streams?
1.  **Ringan:** Server hanya mengirimkan data yang berubah (diffs).
2.  **Efisien:** Browser hanya melakukan update pada elemen HTML dengan ID tertentu tanpa me-render ulang seluruh list.
3.  **Standard 1.8:** Menggunakan sintaks HEEx terbaru `{@streams.name}` dan atribut `:for={{dom_id, item} <- @streams.name}`.



---

## 📝 4. Setup & Running Project

Jika kamu baru pertama kali menjalankan project ini di komputer baru:

1. **Install Dependencies:** `mix deps.get`
2. **Setup Database:** `mix ecto.setup` (Ini menjalankan create, migrate, dan seed sekaligus).
3. **Data Dummy (Seeds):** Pastikan `priv/repo/seeds.exs` sudah berisi data barang, lalu jalankan:
   ```bash
   mix run priv/repo/seeds.exs
   ```
4. **Jalankan Aplikasi:** 
    ```bash
    mix phx.server
    ```
> Akses di: `http://localhost:4000/dashboard`

___

## 5. 💡 Tips & Trik Pembelajaran (Notice)
1. **Type Safety**: Di Phoenix 1.8, Elixir memiliki sistem pengecekan tipe data yang ketat. Pastikan ID dari form/click (yang berupa string) diubah ke integer dengan String.to_integer/1 sebelum masuk ke Ecto.
2. **DOM ID**: Selalu sertakan id unik pada kontainer utama (phx-update="stream") dan setiap elemen anak agar LiveView tidak bingung saat melakukan update data.
3. **Double Mount**: Phoenix akan melakukan render dua kali (statis lalu websocket). Gunakan if connected?(socket) di dalam mount untuk menghindari proses ganda pada PubSub.