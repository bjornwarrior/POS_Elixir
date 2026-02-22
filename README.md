# SimpleERP - Real-time POS Dashboard 🚀

Aplikasi prototype **ERP & Point of Sale (POS)** sederhana yang dibangun untuk mempelajari ekosistem **Elixir** dan **Phoenix Framework 1.8**. Project ini fokus pada efisiensi pengelolaan stok barang secara real-time tanpa memerlukan framework JavaScript eksternal yang kompleks.



## 🛠️ Stack Teknologi
- **Bahasa Pemrograman:** Elixir
- **Framework:** Phoenix v1.8.3 (Latest)
- **Engine:** Phoenix LiveView (Real-time SSR)
- **Komunikasi:** Phoenix PubSub (WebSockets)
- **Styling:** Tailwind CSS & Phoenix Core Components

---

## 📚 Materi yang Telah Dipelajari (Progress Report)

Sampai titik ini, saya (sebagai mahasiswa S1 Sistem Informasi) telah menguasai beberapa konsep fundamental Phoenix melalui project ini:

### 1. Deklarasi View dengan HEEx (Phoenix 1.8 Syntax)
Menggunakan sintaks terbaru Phoenix 1.8 untuk rendering data secara deklaratif.
- Menggunakan kurawal `{@variable}` sebagai pengganti tag `<%= @variable %>`.
- Implementasi atribut `:for` untuk perulangan data koleksi.
- Pemanfaatan `CoreComponents` seperti `<.button>` untuk standarisasi UI.

### 2. State Management Server-Side
Memahami bahwa state aplikasi (seperti daftar stok barang) dikelola di dalam memori server (GenServer/LiveView Process), bukan di browser. Hal ini mengurangi beban client-side secara signifikan.

### 3. Event Handling (Client-to-Server)
Menangkap interaksi user melalui atribut `phx-click` dan memprosesnya di fungsi `handle_event/3` pada server.

### 4. Real-time Broadcasting dengan PubSub
Implementasi sinkronisasi data antar user secara instan:
- **Subscription:** Mendaftarkan proses LiveView ke topik tertentu saat `mount`.
- **Broadcasting:** Mengirim sinyal perubahan data ke semua subscriber.
- **Handling Info:** Menangkap pesan internal server melalui `handle_info/2` untuk mengupdate UI semua admin secara serentak.



---

## ⚙️ Cara Menjalankan Project

### Prasyarat
- Elixir 1.16 atau terbaru
- Erlang 26 atau terbaru
- PostgreSQL (sudah terkonfigurasi)

### Instalasi & Menjalankan
1. **Clone & Masuk ke Folder**
   ```bash
   git clone [https://github.com/bjornwarrior/simple_erp.git](https://github.com/bjornwarrior/simple_erp.git)
   cd simple_erp
   ```
2. **Install Dependencies**
   ```bash
    mix deps.get   
    ```
3. **Setup Database**
    ```bash
    mix ecto.setup

    ```
4. **Jalankan Server**
    ```bash
    mix phx.server

    ```
Akses di: http://localhost:4000/dashboard

### 📝 Catatan Milestone
[x] Setup Project Phoenix 1.8.3
[x] Implementasi LiveView Dashboard
[x] Fitur Real-time PubSub (Sync antar Browser)
[ ] Integrasi Database Ecto (Next Step)
[ ] Fitur Validasi Stok (Mencegah stok minus)