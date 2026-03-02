defmodule SimpleErp.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :qty, :integer, null: false
      add :total_price, :decimal, precision: 12, scale: 2, null: false
      # Hubungkan ke produk (Belongs To)
      add :product_id, references(:products, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:sales, [:product_id])
  end
end
