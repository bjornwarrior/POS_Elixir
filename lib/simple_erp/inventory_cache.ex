defmodule SimpleErp.InventoryCache do
  use GenServer
  require Logger
  alias SimpleErp.Repo
  alias SimpleErp.Shopping

  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_to_cart(product_id, qty) do
    GenServer.cast(__MODULE__, {:add, product_id, qty})
  end

  def put_stock(product_name, amount) do
    GenServer.cast(__MODULE__, {:put, product_name, amount})
  end

  def get_all_stock() do
    GenServer.call(__MODULE__, :get_all)
  end

  def reduce_stock(product_name, amount) do
    GenServer.cast(__MODULE__, {:reduce, product_name, amount})
  end

  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("📦 InventoryCache Berhasil Dilahirkan!")
    Logger.debug("Keranjang Kamu Saat ini: #{inspect(Shopping.list_cart_items())}")

    # Gae Timmer
    schedule_save()
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:add, id, qty}, state) do
    new_state = Map.update(state, id, qty, &(&1 + qty))
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:put, product_name, amount}, state) do
    # Memperbarui state
    new_state = Map.put(state, product_name, amount)
    {:noreply, new_state}
  end

  def handle_cast({:reduce, product_name, amount}, state) do
    # Memperbarui state
    new_state2 =
      Map.update(state, product_name, 0, fn
        existing_value ->
          max(existing_value - amount, 0)
      end)

    {:noreply, new_state2}
  end

  @impl true
  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:autosave, state) do
    Logger.debug("Keranjang Kamu Saat ini: #{inspect(Shopping.list_cart_items())}")
    # 2. Simulasi Logika Auto-Save (Handle Info)
    if map_size(state) > 0 do
      Logger.debug("💾 [AUTOSAVE] Menyimpan data ke 'Database': #{inspect(state)}")
      persist_to_db(state)
    else
      Logger.debug("💾 [AUTOSAVE] Cache kosong, tidak ada yang disimpan.")
    end

    # Jadwalkan ulang setiap 10 detik
    schedule_save()
    {:noreply, %{}}
  end

  @impl true
  def terminate(reason, state) do
    # 3. Last Wish (Terminate)
    Logger.error("💀 InventoryCache Wafat! Alasan: #{inspect(reason)}")
    Logger.error("💀 Data terakhir di RAM: #{inspect(state)}")
    persist_to_db(state)
    :ok
  end

  # Helper Functions

  defp persist_to_db(state) do
    if map_size(state) > 0 do
      # Kita gunakan Ecto.Multi atau Loop untuk update database

      Enum.each(state, fn {p_id, qty} ->
        now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

        data = %{
          product_id: p_id,
          qty: qty,
          inserted_at: now,
          updated_at: now
        }

        # Contoh: Mengurangi stok asli di DB berdasarkan isi keranjang
        Repo.insert_all("cart_items", [data],
          on_conflict: [inc: [qty: qty]],
          conflict_target: :product_id
        )
      end)

      Logger.info("✅ Database Berhasil Diperbarui!")
    else
      Logger.debug("ℹ️ Keranjang kosong, abaikan sinkronisasi.")
    end
  end

  defp schedule_save() do
    Process.send_after(self(), :autosave, 10_000)
  end
end
