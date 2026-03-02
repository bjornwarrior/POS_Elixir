defmodule SimpleErp.Repo.Migrations.AddPriceToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      # Menambahkan kolom price dengan tipe decimal (cocok untuk uang)
      # default: 0 agar data lama tidak error/null
      add :price, :decimal, precision: 12, scale: 2, default: 0
    end

    # --- PROTEKSI LEVEL DEWA (DATABASE CHECK) ---
    # Selain di Elixir (Changeset), kita kunci juga di Database
    # agar stok tidak mungkin minus meskipun ada bug di kode.
    create constraint(:products, :stock_must_be_positive, check: "stock >= 0")
    create constraint(:products, :price_must_be_positive, check: "price >= 0")
  end
end
