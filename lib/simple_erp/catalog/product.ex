defmodule SimpleErp.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset # Mengimpor fungsi validasi

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :stock, :integer

    belongs_to :category, SimpleErp.Catalog.Category

    timestamps()
  end

  @doc "Fungsi QC (Changeset)"
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock, :category_id]) # 1. Casting data
    |> validate_required([:name, :price, :stock]) # 2. Wajib diisi
    |> validate_length(:name, min: 3, message: "Nama produk terlalu pendek, minimal 3 huruf!")
    |> validate_number(:price, greater_than_or_equal_to: 0, message: "Harga tidak boleh gratisan atau minus!")
    |> validate_number(:stock, greater_than_or_equal_to: 0, message: "Stok gudang tidak bisa negatif!")
    |> foreign_key_constraint(:category_id)
  end
end
