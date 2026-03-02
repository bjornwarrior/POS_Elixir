alias SimpleErp.Repo
alias SimpleErp.Catalog.{Product, Sale}
alias SimpleErp.Kategori.Category
alias SimpleErp.Shopping.CartItem

IO.puts "🧹 Sedang membersihkan database..."

# 1. Hapus tabel "Anak" terlebih dahulu
Repo.delete_all(CartItem)
Repo.delete_all(Sale)

# 2. Sekarang baru aman menghapus "Induk"
Repo.delete_all(Product)
Repo.delete_all(Category)

IO.puts "🌱 Menanam data baru..."

{:ok, cat} = Repo.insert(%Category{name: "Gadget"})

products = [
  %{name: "iPhone 15", price: 15000000, stock: 45, category_id: cat.id},
  %{name: "MacBook Air", price: 18000000, stock: 20, category_id: cat.id},
  %{name: "iPad Pro", price: 12000000, stock: 35, category_id: cat.id},
  %{name: "Apple Watch", price: 5000000, stock: 60, category_id: cat.id}
]

Enum.each(products, fn p ->
  Repo.insert!(Product.changeset(%Product{}, p))
end)

IO.puts "✅ Seeder berhasil!"
