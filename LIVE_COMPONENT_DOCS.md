## í·© LiveView: LiveComponent (Stateful Components)

* **Encapsulation**: Memisahkan logika UI dan fungsionalitas ke dalam file terpisah agar kode tetap bersih.
* **Stateful**: Memiliki siklus hidup sendiri (`mount`, `update`, `render`) dan state lokal.
* **`phx-target={@myself}`**: Atribut wajib jika ingin event diproses oleh komponen itu sendiri, bukan oleh parent LiveView.
* **Reusable Logic**: Komponen Chat atau Grafik yang sama bisa dipasang di banyak halaman berbeda dengan satu baris kode.

---
> **"Jika kamu lupa atau tidak tahu dokumentasi terbaru untuk mengajarkan saya tolong kamu meminta dokumentasi terbaru dari saya secara spesifik."**
