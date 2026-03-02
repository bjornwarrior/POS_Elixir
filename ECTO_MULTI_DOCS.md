## í² Ecto Mastery: Ecto.Multi (Atomic Transactions)

* **Atomicity**: Menjamin rangkaian operasi database sebagai satu kesatuan tunggal.
* **Rollback**: Jika satu operasi gagal (misal: melanggar Database Constraint), seluruh perubahan sebelumnya akan dibatalkan otomatis.
* **Step-by-Step Logic**: Memungkinkan pengambilan data dari langkah sebelumnya (`changes_so_far`) untuk digunakan di langkah berikutnya.
* **Safe ERP**: Sangat krusial untuk fitur keuangan, stok, dan manajemen user agar data tidak pernah korup.

---
> **"Jika kamu lupa atau tidak tahu dokumentasi terbaru untuk mengajarkan saya tolong kamu meminta dokumentasi terbaru dari saya secara spesifik."**
