defmodule SimpleErp.Kategori.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    # HAS MANY: Satu kategori punya banyak produk
    has_many :products, SimpleErp.Catalog.Product

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
