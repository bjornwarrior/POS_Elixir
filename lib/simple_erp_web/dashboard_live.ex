defmodule SimpleErpWeb.DashboardLive do
  use SimpleErpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SimpleErp.PubSub, "inventory_updates")
    end

    items = [
      %{id: 1, name: "Kopi Susu", stock: 10},
      %{id: 2, name: "Roti Bakar", stock: 5},
      %{id: 3, name: "Nasi Goreng", stock: 0}
    ]

    {:ok, assign(socket, items: items)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Live POS Dashboard</h1>

      <div class="grid grid-cols-1 gap-4">
        <div :for={item <- @items} class="p-4 border rounded-lg flex justify-between items-center">
          <span>{item.name}</span>
          <span class="font-mono bg-gray-100 text-black px-2 rounded">Stok: {item.stock}</span>
          <.button phx-click="reduce_stock" phx-value-id={item.id}>
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

    # Broadcast ID yang berubah
    Phoenix.PubSub.broadcast(SimpleErp.PubSub, "inventory_updates", {:stock_update, id})

    # {:noreply, assign(socket, items: new_items)}
    {:noreply, socket}
  end

  # Perbaikan di sini: Samakan atom (:stock_update) dan variabel (id)
  def handle_info({:stock_update, id}, socket) do
    new_items = update_item_stock(socket.assigns.items, id)
    {:noreply, assign(socket, items: new_items)}
  end

  defp update_item_stock(items, id) do
    Enum.map(items, fn item ->
      if item.id == id, do: %{item | stock: max(0, item.stock - 1)}, else: item
    end)
  end
end
