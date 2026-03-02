defmodule SimpleErpWeb.ErpUI do
  use Phoenix.Component

  @doc "Komponen Badge untuk status stok"
  attr :color, :string, default: "gray", values: ["gray", "green", "red", "yellow", "indigo"]
  attr :label, :string, required: true
  slot :inner_block

  def status_badge(assigns) do
    # Kita buat mapping warna yang utuh agar terdeteksi Tailwind
    assigns = assign(assigns, :color_class, color_variant(assigns.color))

    ~H"""
    <span class={["px-2 py-1 text-xs font-bold rounded-full", @color_class]}>
      {@label}
      {render_slot(@inner_block)}
    </span>
    """
  end

  # Helper function untuk mengembalikan class utuh
  defp color_variant("green"), do: "bg-green-100 text-green-700"
  defp color_variant("red"), do: "bg-red-100 text-red-700"
  defp color_variant("yellow"), do: "bg-yellow-100 text-yellow-700"
  defp color_variant("indigo"), do: "bg-indigo-100 text-indigo-700"
  defp color_variant(_), do: "bg-gray-100 text-gray-700"

  @doc "Komponen Tombol Keren"
  attr :type, :string, default: "button"
  attr :rest, :global
  slot :inner_block, required: true

  def erp_button(assigns) do
    ~H"""
    <button
      type={@type}
      {assigns_to_attributes(@rest, [:class])}
      class={[
        "px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 active:scale-95 transition-all shadow-md",
        @rest[:class] # Mengambil class="w-full" dari luar dan menggabungkannya
      ]}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
