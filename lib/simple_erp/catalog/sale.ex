defmodule SimpleErp.Catalog.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales" do
    field :qty, :integer
    field :total_price, :decimal

    belongs_to :product, SimpleErp.Catalog.Product

    timestamps()
  end

  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:qty, :total_price, :product_id])
    |> validate_required([:qty, :total_price, :product_id])
    |> validate_number(:qty, greater_than: 0)
    |> foreign_key_constraint(:product_id)
  end
end
