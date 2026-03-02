## í³Š Sales Tracking & Automated Testing

* **Sales Schema**: Mencatat history transaksi (`qty`, `total_price`) yang terhubung ke `products`.
* **Atomic Transaction**: Menggunakan `Ecto.Multi` untuk memastikan stok berkurang DAN penjualan tercatat dalam satu siklus aman.
* **ExUnit Testing**: Menggunakan `DataCase` untuk melakukan pengetesan database yang terisolasi (sandbox), sehingga data test tidak mengotori database asli.
* **Assertion**: Menggunakan `assert` untuk memvalidasi kebenaran logika bisnis secara otomatis.

---
> **"Jika kamu lupa atau tidak tahu dokumentasi terbaru untuk mengajarkan saya tolong kamu meminta dokumentasi terbaru dari saya secara spesifik."**
