defmodule SimpleErpWeb.ChatComponent do
  use SimpleErpWeb, :live_component # <--- Berbeda dengan :live_view

  @impl true
  def mount(socket) do
    # State lokal hanya untuk chat ini
    {:ok, assign(socket, :messages, ["Selamat datang di bantuan ERP!"])}
  end

  @impl true
  def handle_event("send_msg", %{"msg" => msg}, socket) do
    # Menangani pesan secara mandiri tanpa mengganggu LiveView utama
    new_messages = socket.assigns.messages ++ [msg]
    {:noreply, assign(socket, :messages, new_messages)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-slate-800 text-white p-4 rounded-2xl shadow-lg w-full">
      <h3 class="font-bold text-xs text-slate-400 mb-2 uppercase tracking-widest">Internal Support Chat</h3>
      <div class="h-32 overflow-y-auto mb-4 space-y-2 text-sm font-mono">
        <%= for m <- @messages do %>
          <div class="bg-slate-700 p-2 rounded-lg">> {m}</div>
        <% end %>
      </div>
      <form phx-submit="send_msg" phx-target={@myself} class="flex gap-2">
        <input name="msg" placeholder="Ketik pesan..." class="bg-slate-900 border-none rounded-lg text-xs w-full focus:ring-indigo-500" />
        <button class="bg-indigo-600 px-3 py-1 rounded-lg text-xs font-bold">KIRIM</button>
      </form>
    </div>
    """
  end
end
