defmodule SimpleErp.Repo.Migrations.AddUniqueIndexToCartItems do
  use Ecto.Migration

  def change do
    # Hapus index bawaan yang tidak unik
    drop_if_exists index(:cart_items, [:product_id])

    # Buat index baru yang dipastikan UNIQUE
    create unique_index(:cart_items, [:product_id])
  end
end
