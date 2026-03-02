defmodule SimpleErpWeb.DbCartChartComponent do
  use SimpleErpWeb, :live_component

  @impl true
  def update(assigns, socket) do
    db_cart = assigns.db_cart || []

    labels = Enum.map(db_cart, & &1.product_name)

    values = Enum.map(db_cart, fn item ->
      # Gunakan Map.get untuk mengambil field virtual :price secara aman
      price = Map.get(item, :price) || Decimal.new(0)
      qty = item.qty || 0

      Decimal.to_float(Decimal.mult(Decimal.new(qty), price))
    end)

    if connected?(socket) do
      push_event(socket, "update-db-chart", %{labels: labels, values: values})
    end

    {:ok, assign(socket, labels: labels, values: values)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-bold text-gray-800 flex items-center gap-2">
          🗄️ Nilai Inventaris di DB
        </h3>
        <span class="text-[10px] bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-mono animate-pulse">
          LIVE DB
        </span>
      </div>

      <div phx-update="ignore" id="db-chart-container" class="max-h-[300px] flex justify-center">
        <canvas
          id="db-cart-canvas"
          phx-hook="DbCartChart"
          data-labels={Jason.encode!(@labels)}
          data-values={Jason.encode!(@values)}
        ></canvas>
      </div>
    </div>
    """
  end
end
