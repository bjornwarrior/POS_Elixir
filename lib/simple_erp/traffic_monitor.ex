defmodule SimpleErp.TrafficMonitor do
  use GenServer
  # --- Membuat Client API (Fungsi yang dipanggil dari luar) ---
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def add_hit() do
    # Cast = Kirim pesan tanpa menunggu balasan (Asinkron)
    GenServer.cast(__MODULE__, :incerment)
  end

  def get_stats() do
    # Call = Kirim pesan dan tunggu balasan (Synchronous)
    GenServer.call(__MODULE__, :get_count)
  end

  # --- GenServer Callbacks (Logika dalam proses)---

  @impl true
  def init(count) do
    # Menetapkan state awal
    {:ok, count}
  end

  @impl true
  def handle_cast(:incerment, count) do
    # Update state: count + 1
    {:noreply, count + 1}
  end

  @impl true
  def handle_call(:get_count, _from, count) do
    # Kirim balasan, state tetap sama
    {:reply, count, count}
  end
end
