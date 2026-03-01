# 🚀 Elixir OTP Mastery: The Shopping Cart Journey

Dokumentasi ini adalah panduan lengkap membangun sistem stateful yang tangguh (resilient) menggunakan Elixir OTP, mulai dari konsep dasar hingga sinkronisasi database PostgreSQL.

---

## 📚 1. Definisi & Konsep Dasar
**OTP (Open Telecom Platform)** adalah kumpulan library Erlang yang memungkinkan kita membangun sistem yang *fault-tolerant* dan berjalan secara *concurrent*.

* **Process**: Unit eksekusi terkecil (bukan Thread OS). Sangat ringan.
* **GenServer**: "Generic Server" — Abstraksi untuk membuat proses yang memiliki state (ingatan) dan bisa berkomunikasi dua arah.
* **Supervisor**: Proses "Manajer" yang tugasnya hanya memantau proses anak. Jika anak mati, ia akan menghidupkannya kembali.

### 🎭 Analogi Dunia Nyata
Bayangkan **GenServer** adalah seorang **Kasir**. 
1. Ia punya ingatan (State) tentang apa saja yang dimasukkan ke keranjang.
2. Kamu bisa memberitahunya "Tambah Kopi" (**Cast** - tanpa menunggu balasan).
3. Kamu bisa bertanya "Berapa totalnya?" (**Call** - menunggu balasan).
4. Jika Kasir pingsan (**Crash**), **Supervisor** (Manajer Toko) akan segera menggantinya dengan kasir baru agar toko tetap buka.

---

## 🛠️ 2. Setup & Arsitektur
Sistem ini menggunakan tabel `cart_items` untuk menyimpan data secara permanen.

**Struktur Tabel:**
* `product_id` (Unique Index)
* `qty` (Integer)

**Setup Database:**
Pastikan kamu telah menjalankan migrasi dengan **Unique Index** pada `product_id` untuk mendukung fitur **Atomic Upsert**.

---

## 💻 3. Implementasi: `InventoryCache` (Shopping Cart)

```elixir
defmodule SimpleErp.InventoryCache do
  use GenServer
  require Logger
  alias SimpleErp.Repo

  # --- Client API ---
  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def add_to_cart(p_id, qty), do: GenServer.cast(__MODULE__, {:add, p_id, qty})
  def get_all_stock(), do: GenServer.call(__MODULE__, :get_all)

  # --- Server Callbacks ---
  @impl true
  def init(_state) do
    Logger.info("📦 Shopping Cart Born!")
    schedule_save()
    {:ok, %{}} # State awal berupa Map kosong
  end

  @impl true
  def handle_cast({:add, id, qty}, state) do
    new_state = Map.update(state, id, qty, &(&1 + qty))
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_all, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info(:autosave, state) do
    if map_size(state) > 0 do
      Logger.debug("💾 [AUTOSAVE] Syncing to DB: #{inspect(state)}")
      persist_to_db(state)
    end
    schedule_save()
    {:noreply, %{}} # Flush RAM setelah pindah ke DB
  end

  @impl true
  def terminate(reason, state) do
    Logger.error("💀 Emergency Save! Reason: #{inspect(reason)}")
    persist_to_db(state)
    :ok
  end

  defp persist_to_db(state) do
    Enum.each(state, fn {p_id, quantity} ->
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      data = %{product_id: p_id, qty: quantity, inserted_at: now, updated_at: now}

      Repo.insert_all("cart_items", [data],
        on_conflict: [inc: [qty: quantity]],
        conflict_target: :product_id
      )
    end)
  end

  defp schedule_save(), do: Process.send_after(self(), :autosave, 10000)
end
```
## 🔍 4. Debugging & Inspeksi
Gunakan perintah ini di **IEx** untuk mengintip isi sistem secara mendalam:

* `:sys.get_state(SimpleErp.InventoryCache)` : Melihat isi keranjang yang saat ini ada di RAM.
* `:sys.trace(SimpleErp.InventoryCache, true)` : Mengaktifkan trace untuk melihat lalu lintas pesan secara live.
* `Process.whereis(SimpleErp.InventoryCache)` : Mendapatkan PID proses yang sedang jalan.

---

## 🧪 5. Testing (ExUnit)
Poin-poin penting yang harus dites:

* **Logic Test**: Memastikan `Map.update` bekerja dengan benar dalam mengelola state.
* **Persistence Test**: Mengirim sinyal `:autosave` manual dan mengecek data di tabel `cart_items` menggunakan `Repo.one`.
* **Race Condition**: Memastikan `on_conflict` (Upsert) tidak membuat data duplikat di database.

---

## ⚠️ 6. Bagian Paling Penting (The Golden Rules)
1. **Immutability**: State tidak pernah "berubah", kita selalu menghasilkan State baru di akhir fungsi `handle_*`.
2. **Write-Behind Pattern**: Kita menulis ke RAM dulu (cepat) baru ke DB (lambat) secara berkala. Ini meningkatkan performa aplikasi secara drastis.
3. **Don't Overuse**: Gunakan GenServer hanya jika kamu butuh mengelola State yang berumur panjang (seperti Keranjang atau Sesi Game). Untuk query DB biasa, gunakan Ecto langsung.
4. **Inspect Everything**: Selalu gunakan `#{inspect(data)}` saat logging data kompleks (List/Map/Struct) untuk menghindari `ArgumentError`.

---