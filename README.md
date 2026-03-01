# 🧠 Elixir OTP Mastery: Traffic Monitor Project

Dokumentasi ini merangkum perjalanan kita membangun sistem stateful menggunakan GenServer dan Supervisor dari nol hingga tahap testing.

---

## 🚀 1. Konsep Dasar (Mental Model)
* **Process**: Unit eksekusi terkecil di Elixir. Sangat ringan (kamu bisa menjalankan jutaan proses sekaligus).
* **PID (Process Identifier)**: Alamat unik atau "Nomor KTP" setiap proses. Digunakan untuk mengirim pesan antar proses. Jika proses mati dan dihidupkan ulang, ia mendapat PID baru.
* **GenServer (Generic Server)**: Standar OTP untuk membuat proses yang memiliki *state* (ingatan) di RAM.
* **Supervisor**: Proses khusus yang tugasnya hanya mengawasi proses lain. Jika ada proses anak yang crash, Supervisor akan menghidupkannya kembali (Self-healing).

---

## 💻 2. Implementasi Kode (MVP)
Kita membangun `SimpleErp.TrafficMonitor` untuk mencatat aktivitas kunjungan secara global.

### A. Client API & Server Callbacks
Struktur dasar GenServer memisahkan cara kita memanggil fungsi (Client) dan cara fungsi itu diproses (Server).
```elixir
# Client API
def add_hit(), do: GenServer.cast(__MODULE__, :increment)
def get_stats(), do: GenServer.call(__MODULE__, :get_count)

# Server Callbacks
def handle_cast(:increment, count), do: {:noreply, count + 1}
def handle_call(:get_count, _from, count), do: {:reply, count, count}
```
### B. Registrasi ke Application
Agar proses ini berjalan otomatis saat server menyala, kita mendaftarkannya di `lib/simple_erp/application.ex`:
```elixir
children = [
  # ... child lainnya
  SimpleErp.TrafficMonitor
]
```
## 🔍 3. Debugging & Logging
Karena kita menggunakan PID dan Nama Terdaftar, kita bisa mengintip isi proses melalui IEx:
* `Process.whereis(SimpleErp.TrafficMonitor)` : Mencari PID proses berdasarkan namanya.
* `:sys.get_state(PID_ATAU_NAMA)` : Melihat data/state yang sedang disimpan di RAM saat ini.
* `:sys.trace(PID_ATAU_NAMA, true)` : Melacak setiap pesan masuk dan keluar secara real-time di terminal.

## 🧪 4. Testing & Ketahanan (Fault Tolerance)
Testing dilakukan menggunakan ExUnit dengan dua skenario kritis:
1. **Skenario Fungsional**: Memastikan pengiriman pesan `:increment` benar-benar memperbarui angka di state.
2. **Skenario Resilience**: Menggunakan `Process.exit(pid, :kill)` untuk membuktikan bahwa Supervisor akan segera memberikan PID baru agar aplikasi tidak berhenti berfungsi.

## ⚠️ 5. Hal Penting (Notice)
* **Volatile Storage**: Data di GenServer disimpan di RAM. Jika aplikasi restart, data kembali ke awal. Gunakan Ecto untuk data permanen.
* **Blocking vs Non-blocking**: `call` bersifat sinkron (menunggu jawaban), sedangkan `cast` bersifat asinkron (kirim lalu lanjut).
* **Single Source of Truth**: GenServer ini bertindak sebagai satu-satunya penyimpan data hit untuk seluruh user yang terkoneksi ke server.