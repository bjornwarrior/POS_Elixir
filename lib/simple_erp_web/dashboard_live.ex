defmodule SimpleErpWeb.DashboardLive do
  use SimpleErpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SimpleErp.PubSub, "inventory_updates")
    end

    kategori = SimpleErp.Kategori.list_categories()
    products = SimpleErp.Catalog.list_products()

    socket =
      socket
      |> stream(:kategori, kategori)
      |> stream(:products, products)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Live POS Dashboard (DB Powered) </h1>

      <div id="kategori-list" phx-update="stream" class="space-y-4">
        <div
          :for={{dom_id, kategori} <- @streams.kategori}
          id={dom_id}
          class="p-4 border rounded-lg flex gap-4 items-center shadow-sm"
        >
          <span>{kategori.name}</span>
          <%!-- Form sederhana untuk update nama secara langsung --%>
          <form phx-submit="update_category_name" class="flex flex-1 gap-2">
            <input type="hidden" name="id" value={kategori.id} />
            <input
              type="text"
              name="name"
              value={kategori.name}
              class="border rounded px-2 py-1 flex-1 focus:ring-2 focus:ring-blue-500 outline-none"
            />
            <.button phx-click="delete_category" phx-value-id={kategori.id} class="bg-red-400 hover:bg-red-700 text-sm">
              Hapus
            </.button>
            <.button type="submit" class="bg-blue-400 hover:bg-blue-700 text-sm">
              Simpan
            </.button>
          </form>

          <span class="font-mono bg-gray-100 text-gray-600 px-3 py-1 rounded">
            ID: {kategori.id}
          </span>
        </div>
      </div>

      <div id="products-list" phx-update="stream" class="grid grid-cols-1 gap-4">
        <div
          :for={{dom_id, product} <- @streams.products}
          id={dom_id}
          class="p-4 border rounded-lg flex justify-between items-center"
        >
          <span>{product.name}</span>
          <span class="font-mono bg-gray-100 text-black px-2 rounded">Stok: {product.stock}</span>
          <.button phx-click="reduce_stock" phx-value-id={product.id}>
            Jual 1
          </.button>
        </div>
      </div>


    </div>
    """
  end

  def handle_event("reduce_stock", %{"id" => id}, socket) do
    id = String.to_integer(id)
    product = SimpleErp.Catalog.reduce_stock(id)

    # Broadcast ID yang berubah
    Phoenix.PubSub.broadcast(SimpleErp.PubSub, "inventory_updates", {:stock_update, product})

    # {:noreply, assign(socket, items: new_items)}
    {:noreply, socket}
  end

  # Perbaikan di sini: Samakan atom (:stock_update) dan variabel (id)
  def handle_info({:stock_update, product}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  # Handler untuk memproses perubahan nama kategori
  def handle_event("update_category_name", %{"id" => id, "name" => name}, socket) do
    # 1. Ambil data kategori dari DB
    kategori = SimpleErp.Kategori.get_category!(id)

    # 2. Update di database menggunakan context
    case SimpleErp.Kategori.update_category(kategori, %{name: name}) do
      {:ok, updated_kategori} ->
        # 3. Broadcast agar user lain juga melihat perubahannya
        Phoenix.PubSub.broadcast(SimpleErp.PubSub, "inventory_updates", {:category_updated, updated_kategori})

        # 4. Beri notifikasi ke user (opsional)
        {:noreply, put_flash(socket, :info, "Kategori diperbarui!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Gagal memperbarui kategori.")}
    end
  end

  # Handler untuk menangkap broadcast real-time
  def handle_info({:category_updated, kategori}, socket) do
    # stream_insert akan otomatis mengupdate elemen dengan ID yang sama di browser
    {:noreply, stream_insert(socket, :kategori, kategori)}
  end

  def handle_event("delete_category", %{"id" => id}, socket) do
    kategori = SimpleErp.Kategori.get_category!(id)

    case SimpleErp.Kategori.delete_category(kategori) do
      {:ok, _} ->
        # 3. Broadcast agar user lain juga melihat perubahannya
        Phoenix.PubSub.broadcast(SimpleErp.PubSub, "inventory_updates", {:category_deleted, kategori})
        # 4. Beri notifikasi ke user (opsional)
        {:noreply, put_flash(socket, :info, "Kategori dihapus!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus kategori.")}
    end
  end

  def handle_info({:category_deleted, kategori}, socket) do
    {:noreply, stream_delete(socket, :kategori, kategori)}
  end
end
