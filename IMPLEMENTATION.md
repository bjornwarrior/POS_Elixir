# 🚀 OTP Fault-Tolerance & Real-time Sync Documentation
**Project:** Simple ERP (Inventory & Shopping Cart)
**Date:** 2026-03-01
**Stack:** Elixir 1.8+, Phoenix LiveView, OTP GenServer, PostgreSQL

---

## 🏗️ 1. Backend: InventoryCache (GenServer)
File: `lib/simple_erp/inventory_cache.ex`

Engine utama yang mengelola keranjang belanja di RAM. Memiliki fitur *self-healing* (Supervisor) dan *auto-save* ke database.

```elixir
defmodule SimpleErp.InventoryCache do
  use GenServer
  require Logger
  alias SimpleErp.Repo
  alias SimpleErp.Shopping

  # --- Client API ---
  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def add_to_cart(p_id, qty), do: GenServer.cast(__MODULE__, {:add, p_id, qty})
  def get_all_stock(), do: GenServer.call(__MODULE__, :get_all)
  def die_horrible_death(), do: GenServer.cast(__MODULE__, :kill)

  # --- Server Callbacks ---
  @impl true
  def init(_state) do
    Logger.info("⏳ InventoryCache sedang masa pemulihan (2 detik)...")
    Process.sleep(2000) # Jeda dramatis agar status 'MATI' terlihat di UI
    Logger.info("📦 InventoryCache Berhasil Dilahirkan!")
    schedule_save()
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:add, id, qty}, state) do
    {:noreply, Map.update(state, id, qty, &(&1 + qty))}
  end

  @impl true
  def handle_cast(:kill, _state) do
    Logger.error("🧨 Seseorang menekan tombol peledak!")
    raise "KABOOM!"
  end

  @impl true
  def handle_call(:get_all, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info(:autosave, state) do
    if map_size(state) > 0, do: persist_to_db(state)
    schedule_save()
    {:noreply, %{}} # Flush RAM setelah sinkronisasi ke DB
  end

  @impl true
  def terminate(reason, state) do
    Logger.error("💀 InventoryCache Wafat! Alasan: #{inspect(reason)}")
    persist_to_db(state) # Last Wish: Amankan data ke DB sebelum mati
    :ok
  end

  # --- Helpers ---
  defp persist_to_db(state) do
    Enum.each(state, fn {p_id, qty} ->
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      data = %{product_id: p_id, qty: qty, inserted_at: now, updated_at: now}
      Repo.insert_all("cart_items", [data], 
        on_conflict: [inc: [qty: qty]], 
        conflict_target: :product_id
      )
    end)
    Logger.info("✅ Database Berhasil Diperbarui!")
  end

  defp schedule_save(), do: Process.send_after(self(), :autosave, 10_000)
end
```
___

## 📺 2. Monitoring: Supervisor Monitor (LiveView)
File: `lib/simple_erp_web/live/supervisor_demo_live.ex`
Interface untuk memantau siklus hidup proses secara visual.
```Elixir
defmodule SimpleErpWeb.SupervisorDemoLive do
  use SimpleErpWeb, :live_view
  alias SimpleErp.InventoryCache
  alias SimpleErp.Catalog

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, :tick)
    {:ok, assign(socket, :all_products, Catalog.list_products()) |> assign_stats()}
  end

  @impl true
  def handle_info(:tick, socket), do: {:noreply, assign_stats(socket)}

  @impl true
  def handle_event("kill_it", _, socket) do
    InventoryCache.die_horrible_death()
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    pid_raw = Process.whereis(InventoryCache)
    all_products = socket.assigns[:all_products] || []

    {status, pid_text} = if pid_raw, do: {"HIDUP", inspect(pid_raw)}, else: {"MATI", "nil (Restarting...)"}
    
    items_raw = if pid_raw, do: (try do InventoryCache.get_all_stock() rescue _ -> %{} end), else: %{}

    sync_items = Enum.map(items_raw, fn {id, qty} ->
      p = Enum.find(all_products, &(&1.id == id))
      %{name: if(p, do: p.name, else: "ID: #{id}"), qty: qty}
    end)

    assign(socket, pid: pid_text, is_alive: status, items: sync_items)
  end
end
```
___

## 🛒 3. Frontend: Smart Marketplace Cart (LiveView)
File: `lib/simple_erp_web/live/cart_live.ex`
Halaman transaksi yang mensinkronkan data RAM dan Database secara cerdas.
```Elixir
defmodule SimpleErpWeb.CartLive do
  use SimpleErpWeb, :live_view
  alias SimpleErp.InventoryCache
  alias SimpleErp.Shopping
  alias SimpleErp.Catalog

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, :tick)
    products = Catalog.list_products()
    {:ok, assign(socket, products: products, selected_product_id: List.first(products).id || 0) |> assign_data()}
  end

  @impl true
  def handle_event("add_item", %{"product_id" => p_id, "qty" => qty}, socket) do
    InventoryCache.add_to_cart(String.to_integer(p_id), String.to_integer(qty))
    {:noreply, assign_data(socket)}
  end

  defp assign_data(socket) do
    products = socket.assigns.products
    ram_raw = InventoryCache.get_all_stock()
    db_raw = Shopping.list_cart_items()

    ram_sync = Enum.map(ram_raw, fn {id, q} -> 
      p = Enum.find(products, &(&1.id == id))
      %{id: id, name: if(p, do: p.name, else: "Unknown"), qty: q}
    end)

    db_sync = Enum.map(db_raw, fn item ->
      p = Enum.find(products, &(&1.id == item.product_id))
      Map.put(item, :product_name, if(p, do: p.name, else: "Unknown"))
    end)

    assign(socket, ram_cart: ram_sync, db_cart: db_sync)
  end
end
```
___

## 💡 Key Highlights

* **Mekanisme "Let it Crash"**: Sistem tidak takut mati karena Supervisor akan menghidupkannya kembali dalam milidetik.
* **Visual Delay**: `Process.sleep` di `init` digunakan untuk sinkronisasi feedback visual ke manusia.
* **Data Enrichment**: Menggabungkan data dari `GenServer` (ID & Qty) dengan `Database` (Product Names) di level LiveView untuk UX yang optimal.
* **Auto-Save Reliability**: Menggunakan `terminate/2` untuk menjamin data tersimpan meskipun terjadi crash tak terduga.