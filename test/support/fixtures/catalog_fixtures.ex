defmodule SimpleErp.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SimpleErp.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        stock: 42
      })
      |> SimpleErp.Catalog.create_product()

    product
  end
end
