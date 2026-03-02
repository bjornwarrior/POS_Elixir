defmodule SimpleErpWeb.CartLive do
  use SimpleErpWeb, :live_view
  alias SimpleErp.InventoryCache
  alias SimpleErp.Shopping
  alias SimpleErp.Catalog
  import SimpleErpWeb.ErpUI

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SimpleErp.PubSub, "inventory_updates")
    end

    # Ambil produk sekali saja di awal
    products = Catalog.list_products()

    {:ok,
     socket
     |> assign(:products, products)
     |> assign(:selected_product_id, (List.first(products) || %{id: 0}).id)
     |> assign_data()}
  end

  @impl true
  def handle_info(:data_updated, socket) do
    # Menambahkan pengecekan agar tidak update jika socket tidak connected
    if connected?(socket) do
      {:noreply, assign_data(socket)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_item", %{"product_id" => p_id, "qty" => qty}, socket) do
    InventoryCache.add_to_cart(String.to_integer(p_id), String.to_integer(qty))
    # Setelah kirim ke cache, langsung perbarui tampilan
    {:noreply, assign_data(socket)}
  end

  defp assign_data(socket) do
    # Pastikan mengambil products dari assigns agar tidak nil
    products = socket.assigns[:products] || []
    ram_raw = InventoryCache.get_all_stock()
    db_raw = Shopping.list_cart_items()

    ram_with_names = Enum.map(ram_raw, fn {id, qty} ->
      p = Enum.find(products, &(&1.id == id))
      %{id: id, name: if(p, do: p.name, else: "Unknown Product"), qty: qty}
    end)

    db_with_names = Enum.map(db_raw, fn item ->
      p = Enum.find(products, &(&1.id == item.product_id))
      # Gunakan Map.merge agar lebih aman saat menyuntikkan data virtual
      Map.merge(item, %{
        product_name: if(p, do: p.name, else: "Unknown Product"),
        price: if(p, do: p.price, else: Decimal.new(0))
      })
    end)

    assign(socket, ram_cart: ram_with_names, db_cart: db_with_names)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto mt-10 p-6 bg-gray-50 rounded-3xl shadow-xl border border-gray-200">
      <h1 class="text-4xl font-black text-indigo-900 mb-8 flex items-center gap-3">
        🛒 Smart Marketplace Cart
      </h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-indigo-100">
          <h2 class="font-bold text-indigo-600 uppercase text-sm tracking-widest mb-4">Input Barang</h2>
          <form phx-submit="add_item" class="space-y-4">
            <div>
              <label class="block text-xs font-bold text-gray-400 mb-1">PILIH PRODUK</label>
              <select name="product_id" class="w-full rounded-lg border-gray-300 text-slate-900">
                <%= for p <- @products do %>
                  <option value={p.id} selected={p.id == @selected_product_id}>
                    {p.name} ({p.stock} unit)
                  </option>
                <% end %>
              </select>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-400 mb-1">JUMLAH (QTY)</label>
              <input type="number" name="qty" value="1" min="1" class="w-full rounded-lg border-gray-300 text-slate-900" />
            </div>

            <.erp_button type="submit" class="w-full">
              TAMBAH KE KERANJANG
            </.erp_button>
          </form>
        </div>

        <div class="bg-indigo-900 p-6 rounded-2xl shadow-sm text-white">
          <h2 class="font-bold text-indigo-300 uppercase text-sm tracking-widest mb-4 flex justify-between">
            ⚡ RAM STATE (CACHE)
            <span class="animate-pulse bg-green-500 h-2 w-2 rounded-full"></span>
          </h2>
          <div class="font-mono text-sm bg-indigo-800 p-4 rounded-lg min-h-[100px]">
            <%= if Enum.empty?(@ram_cart) do %>
              <span class="text-indigo-400 italic">Cache kosong...</span>
            <% else %>
              <%= for item <- @ram_cart do %>
                <div class="flex justify-between border-b border-indigo-700 py-1 items-center">
                  <span>{item.name}</span>
                  <.status_badge color="yellow" label={"#{item.qty} unit"} />
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <div class="mt-8 bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
        <h2 class="font-bold text-gray-600 uppercase text-sm tracking-widest mb-4">🗄️ Database Table (cart_items)</h2>
        <table class="w-full text-left">
          <thead>
            <tr class="text-gray-400 text-xs border-b">
              <th class="py-2">PRODUCT NAME</th>
              <th class="py-2 text-center">STATUS</th>
              <th class="py-2">QTY IN DB</th>
              <th class="py-2">LAST UPDATED</th>
            </tr>
          </thead>
          <tbody class="text-sm text-slate-900">
            <%= for item <- @db_cart do %>
              <tr class="border-b hover:bg-gray-50">
                <td class="py-2 font-bold">{item.product_name}</td>
                <td class="py-2 text-center">
                  <%= if item.qty > 5 do %>
                    <.status_badge color="green" label="SAFE" />
                  <% else %>
                    <.status_badge color="red" label="LOW" />
                  <% end %>
                </td>
                <td class="py-2 font-black text-indigo-600">{item.qty}</td>
                <td class="py-2 text-gray-400 text-[10px]">{item.updated_at}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
