defmodule SimpleErpWeb.StockChartComponent do
  use SimpleErpWeb, :live_component
  alias SimpleErp.Catalog

  @impl true
  def update(assigns, socket) do
    # Ambil data terbaru setiap kali komponen dipanggil atau diupdate
    products = Catalog.list_products()
    labels = Enum.map(products, & &1.name)
    values = Enum.map(products, & &1.stock)

    # Kirim event ke JS Hook jika socket sudah terhubung
    if connected?(socket) do
      push_event(socket, "update-chart", %{labels: labels, values: values})
    end

    {:ok, assign(socket, labels: labels, values: values)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
      <h3 class="text-lg font-bold text-gray-800 mb-4">📊 Grafik Real-time Stok</h3>
      <div phx-update="ignore" id="chart-container">
        <canvas
          id="stock-canvas"
          phx-hook="StockChart"
          data-labels={Jason.encode!(@labels)}
          data-values={Jason.encode!(@values)}
        ></canvas>
      </div>
    </div>
    """
  end
end
