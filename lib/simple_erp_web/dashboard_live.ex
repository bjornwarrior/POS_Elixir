defmodule SimpleErpWeb.DashboardLive do
  use SimpleErpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SimpleErp.PubSub, "inventory_updates")
    end

    products = SimpleErp.Catalog.list_products()
    {:ok, stream(socket, :products, products)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Live POS Dashboard (DB Powered) </h1>

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
    # new_items = update_item_stock(socket.assigns.items, id)

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

end
