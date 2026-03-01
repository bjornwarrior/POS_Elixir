alias SimpleErp.Repo
alias SimpleErp.Catalog.Product
alias SimpleErp.Kategori.Category

Repo.delete_all(Product)
Repo.delete_all(Category)

Repo.insert!(%Product{name: "Keyboard", stock: 10})
Repo.insert!(%Product{name: "Mouse", stock: 5})
Repo.insert!(%Product{name: "Monitor", stock: 2})
Repo.insert!(%Product{name: "Pad", stock: 200})

Repo.insert!(%Category{name: "Foods"})
Repo.insert!(%Category{name: "Electronics"})
Repo.insert!(%Category{name: "Drinks"})
Repo.insert!(%Category{name: "Material"})

IO.puts("The seeds file was executed successfully!")
