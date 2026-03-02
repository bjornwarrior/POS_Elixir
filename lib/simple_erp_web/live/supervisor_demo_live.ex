defmodule SimpleErpWeb.SupervisorDemoLive do
  use SimpleErpWeb, :live_view
  alias SimpleErp.InventoryCache
  # Tambahkan alias ini
  alias SimpleErp.Catalog

  @impl true
  def mount(_params, _session, socket) do
    # Melakukan refresh data setiap 1 detik
    if connected?(socket), do: :timer.send_interval(1000, :tick)
    {:ok, assign(socket, :all_products, Catalog.list_products()) |> assign_stats()}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  @impl true
  def handle_event("kill_it", _params, socket) do
    InventoryCache.die_horrible_death()
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    # Cek apakah nama modul terdaftar sebagai PID yang aktif
    pid_raw = Process.whereis(InventoryCache)
    all_products = socket.assigns[:all_products] || []

    # Logic untuk menentukan status secara eksplisit
    {status_text, pid_display} =
      if pid_raw do
        {"HIDUP", inspect(pid_raw)}
      else
        {"MATI", "nil (Restarting...)"}
      end

    # Mengambil data stock dengan aman (pasti gagal jika PID nil)
    items_raw =
      if pid_raw do
        try do
          InventoryCache.get_all_stock()
        rescue
          _ -> %{}
        end
      else
        # Jika mati, tampilkan kosong
        %{}
      end

    synchronized_items =
      Enum.map(items_raw, fn {id, qty} ->
        product = Enum.find(all_products, &(&1.id == id))
        name = if product, do: product.name, else: "ID: #{id}"
        %{name: name, qty: qty}
      end)

    assign(socket,
      pid: pid_display,
      is_alive: status_text,
      items: synchronized_items
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto mt-10 p-8 border-4 border-double border-red-500 rounded-2xl bg-white shadow-2xl">
      <h1 class="text-3xl font-black text-gray-800 mb-6 uppercase tracking-widest">
        OTP Supervisor Monitor
      </h1>

      <div class="grid grid-cols-2 gap-4 mb-8">
        <div class="p-4 bg-gray-100 rounded-lg text-left">
          <p class="text-xs text-gray-500 uppercase font-bold">Process ID (PID)</p>
          <p class="text-xl font-mono text-blue-600 font-bold">{@pid}</p>
        </div>
        <div class="p-4 bg-gray-100 rounded-lg text-left">
          <p class="text-xs text-gray-500 uppercase font-bold">Status</p>
          <p class={"text-xl font-bold #{if @is_alive == "HIDUP", do: "text-green-600", else: "text-red-600"}"}>
            {@is_alive}
          </p>
        </div>
      </div>

      <div class="mb-8 p-4 bg-yellow-50 border-l-4 border-yellow-400 text-left">
        <h3 class="font-bold text-yellow-800 mb-2 italic underline">Daftar Item di RAM (Live):</h3>
        <div class="space-y-1">
          <%= if Enum.empty?(@items) do %>
            <p class="text-sm text-yellow-600 italic">RAM sedang kosong atau proses baru saja restart...</p>
          <% else %>
            <%= for item <- @items do %>
              <div class="flex justify-between text-sm font-mono bg-yellow-100/50 px-2 py-1 rounded">
                <span class="font-bold text-gray-700">{item.name}</span>
                <span class="text-indigo-600 font-black">{item.qty} unit</span>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>

      <button
        phx-click="kill_it"
        class="w-full bg-red-600 text-white font-black py-4 rounded-xl hover:bg-red-800 active:scale-95 transition-all shadow-lg hover:shadow-red-500/50"
      >
        🧨 PICU CRASH (LET IT CRASH)
      </button>

      <p class="mt-6 text-[10px] text-gray-400 italic">
        *Perhatikan: Saat tombol diklik, daftar di atas akan kosong sejenak karena RAM direset oleh Supervisor.
      </p>
    </div>
    """
  end
end
