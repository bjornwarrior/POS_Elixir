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

  def die_horrible_death(), do: GenServer.cast(__MODULE__, :kill)

  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("📦 InventoryCache Berhasil Dilahirkan!")
    Logger.debug("Keranjang Kamu Saat ini: #{inspect(Shopping.list_cart_items())}")

    # Gae Timmer
    schedule_save()
    {:ok, %{}}
  end

  @topic "inventory_updates"

  @impl true
  def handle_cast({:add, id, qty}, state) do
    new_state = Map.update(state, id, qty, &(&1 + qty))

    Phoenix.PubSub.broadcast(SimpleErp.PubSub, @topic, :data_updated)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:kill, _state) do
    Logger.error("🧨 Seseorang menekan tombol peledak! Good bye world...")
    # Ini akan membuat proses crash
    raise "KABOOM!"
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
    # 2. Simulasi Logika Auto-Save (Handle Info)
    if map_size(state) > 0 do
      Logger.debug("💾 [AUTOSAVE] Menyimpan data ke 'Database'")
      persist_to_db(state)
    else
      Logger.debug("💾 [AUTOSAVE] Cache kosong, tidak ada yang disimpan.")
    end

    # Jadwalkan ulang setiap 10 detik
    Phoenix.PubSub.broadcast(SimpleErp.PubSub, @topic, :data_updated)
    schedule_save()
    {:noreply, %{}}
  end

  @impl true
  def terminate(reason, state) do
    # 3. Last Wish (Terminate)
    Logger.error("💀 InventoryCache Wafat! Alasan: #{inspect(reason)}")
    Logger.error("💀 Data terakhir di RAM: #{inspect(state)}")

    if map_size(state) > 0 do
      Logger.warn("💾 [LAST WISH] Menyimpan data secara sinkron sebelum proses benar-benar musnah...")
      do_persist_work(state)
    end
    :ok
  end

  # Helper Functions

  defp persist_to_db(state) do
    if map_size(state) > 0 do
      # Kita gunakan Ecto.Multi atau Loop untuk update database

      Task.Supervisor.start_child(SimpleErp.TaskSupervisor, fn ->
        Logger.info("🛰️ [ROBUST TASK] Memulai sinkronisasi aman via Task.Supervisor...")

        # 1. Simulasi Logika Sinkronisasi (Task)
        do_persist_work(state)


        Logger.info("✅ [ROBUST TASK] Sinkronisasi Berhasil!")
      end)
    else
      Logger.debug("ℹ️ Keranjang kosong, abaikan sinkronisasi.")
    end
  end

  # Fungsi inti ekstraksi logika penyimpanan agar bisa dipakai di dua tempat
  defp do_persist_work(state) do
    Enum.each(state, fn {p_id, qty} ->
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      data = %{product_id: p_id, qty: qty, inserted_at: now, updated_at: now}

      Repo.insert_all("cart_items", [data],
        on_conflict: [inc: [qty: qty]],
        conflict_target: :product_id
      )
    end)
    Logger.info("✅ Database Sinkron!")
  end

  defp schedule_save() do
    Process.send_after(self(), :autosave, 10_000)
  end
end
