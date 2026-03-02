##cat << 'EOF' > LIVEVIEW_COMPONENTS_DOCS.md1.8)
$ cat << 'EOF' > LIVEVIEW_COMPONENTS_DOCS.md
## � LiveView: Function Components (Phoenix 1.8)

* **Reusable UI**: Membungkus elemen HTML yang sering dipakai (Button, Input, Table) menjadi fungsi Elixir.
* **Attributes (`attr`)**: Cara mendefinisikan parameter input untuk komponen agar aman secara tipe data.
* **Slots (`slot`)**: Fitur untuk menyuntikkan blok HTML tambahan ke dalam komponen.
* **Syntax `<.name />`**: Membedakan antara tag HTML standar dan komponen Elixir buatan kita sendiri.

---
## � UI Component Integration                                                     
                                                                  
* **Refactored Buttons**: Mengganti button manual dengan `<.erp_button />` untuk konsistensi desain.
* **Dynamic Badges**: Implementasi `<.status_badge />` dengan logika kondisional untuk status stok (SAFE/LOW).
* **Improved Readability**: Mengurangi penggunaan class Tailwind berulang di file LiveView utama dengan memindahkannya ke komponen UI.

--- 
## � Tailwind Dynamic Classes Strategy

* **No String Interpolation**: Hindari construct class seperti `bg-#{@color}-100` karena tidak akan terdeteksi oleh Tailwind JIT.
* **Class Mapping**: Gunakan fungsi helper untuk memetakan nama warna sederhana ke class Tailwind yang lengkap/utuh.
* **Attr Validation**: Gunakan opsi `values:` pada `attr` untuk membatasi input yang diperbolehkan pada komponen.

---
