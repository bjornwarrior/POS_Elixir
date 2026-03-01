defmodule SimpleErp.Shopping.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :qty, :integer
    field :product_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:qty])
    |> validate_required([:qty])
  end
end
