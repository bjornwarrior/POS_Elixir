# 🌐 Supervisor UI Implementation Guide

Panduan integrasi visual untuk memantau sistem fault-tolerance Elixir.

## 🟢 Alur Kerja UI
1. **Mount**: LiveView mengambil PID `InventoryCache` saat pertama kali diakses.
2. **Interval**: Setiap 1 detik, LiveView menanyakan kembali PID ke sistem.
3. **Event**: Tombol Kill memicu `raise` di GenServer.
4. **Recovery**: Supervisor mendeteksi crash, mematikan proses lama, dan menjalankan `start_link` baru. LiveView menangkap PID baru pada detik berikutnya.

## 📌 Catatan Penting
Eksperimen ini membuktikan bahwa **kegagalan pada satu komponen tidak meruntuhkan seluruh aplikasi web**. User lain di halaman lain tidak akan merasakan dampak dari crash ini.

---