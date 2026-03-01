defmodule SimpleErp.ShoppingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SimpleErp.Shopping` context.
  """

  @doc """
  Generate a cart_item.
  """
  def cart_item_fixture(attrs \\ %{}) do
    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        qty: 42
      })
      |> SimpleErp.Shopping.create_cart_item()

    cart_item
  end
end
