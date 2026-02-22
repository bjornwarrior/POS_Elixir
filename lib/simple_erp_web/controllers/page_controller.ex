defmodule SimpleErpWeb.PageController do
  use SimpleErpWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
