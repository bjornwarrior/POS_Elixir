defmodule SimpleErp.Repo.Migrations.CreateCategoriesAndAddAssoc do
  use Ecto.Migration

  def change do
    # 2. Tambahkan kolom category_id ke tabel products (The Foreign Key)
    alter table(:products) do
      # on_delete: :nothing (jika kategori dihapus, produk tetap ada)
      # atau :delete_all (jika kategori dihapus, produk ikut musnah)
      add :category_id, references(:categories, on_delete: :nothing)
    end

    # 3. Index agar pencarian produk berdasarkan kategori jadi cepat kilat
    create index(:products, [:category_id])
  end
end
