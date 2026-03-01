defmodule SimpleErp.KategoriFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SimpleErp.Kategori` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> SimpleErp.Kategori.create_category()

    category
  end
end
